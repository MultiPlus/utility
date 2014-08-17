require_relative 'mod-OS'

def getInterfaces
	interfaces = Array.new

	#On windows get interfaces informations with WMI connector
	if OS.windows?
		require 'win32ole'
		wmi = WIN32OLE.connect("winmgmts://")

		#http://msdn.microsoft.com/en-us/library/aa394217%28v=vs.85%29.aspx
		connections = wmi.ExecQuery("SELECT * FROM Win32_NetworkAdapterConfiguration Where IPEnabled = True")
		for connection in connections do
			interface = Hash.new
			interface[:ip] = connection.IPAddress.first
			interface[:mask] = connection.IPSubnet.first
		    interfaces.push(interface)
		end

		#======= Parse command 'ipconfig'
		#interfaces = Array.new
		#`ipconfig`.split(" :\n").each{|connection|
		#	info = connection.split("\n")
		#	if info.count>5
		#		interface = Hash.new
		#		interface[:ip] = info[3].split(": ")[1]
		#		interface[:mask] = info[4].split(": ")[1]
		#		interface[:gateway] = info[5].split(": ")[1]
		#		interfaces.push(interface)
		#	end
		#}
		
	#On linux get interfaces informations with command 'ip' and parse result
	elsif OS.linux?
		`ip -o addr show | grep -v ": lo" | awk '/inet/ {print $4}'`.split("\n").each{|connection|
			interface = Hash.new
			interface[:ip] = connection.split("/")[0]
			interface[:mask] = connection.split("/")[1]
		    interfaces.push(interface)
		}
	end
	return interfaces
end

def scanNet
	interfaces = getInterfaces()
	require 'ipaddr'
	interfaces.each{|i|
		interface = IPAddr.new i[:ip]
		interface = interface.mask(i[:mask])

		range = interface.to_range().to_a
		range.shift #delete first IP (0.0) (No valid)
		range.pop #Delete last IP broadcast (No valid)
		puts "Scan local network for #{range.first} to #{range.last}:"

		# Create and push threads into thread array
		threads = Array.new
		range.each{|ip|
			threads.push(Thread.new{getInfoFromIp(ip.to_s)})
		}

		# Exec. all threads
		threads.each{|t|
			t.join
		}
	}
end

def getInfoFromIp(ip)
	#gem install net-ping
	require 'net/ping'
	count = 1 #Stop after sending count ECHO_REQUEST packets. With deadline option, ping waits for count ECHO_REPLY packets, until the timeout expires. 
	timeout = 1 #Time to wait for a response, in seconds. The option affects only timeout in absense of any responses, otherwise ping waits for two RTTs.
	if OS.windows?
		pingOk = system("ping -w #{timeout} -n #{count} #{ip}",
                   [:err, :out] => "NUL")
	elsif OS.linux?
		#-q: Quiet output. Nothing is displayed except the summary lines at startup time and when finished. 
		pingOk = system("ping -q -W #{timeout} -c #{count} #{ip}",
                   [:err, :out] => "/dev/null")
	end
	if pingOk
		# Finding name for given IP and catch "no name" error
		require 'resolv'
		begin
			name = Resolv.getname(ip)
		rescue Resolv::ResolvError => error_txt
			puts "Successfull ping ip #{ip} (Resolved name: #{error_txt})"
		else
			puts "Successfull ping ip #{ip} (Resolved name: #{name})"
		end
	end
end

def main
	scanNet()
end
main()