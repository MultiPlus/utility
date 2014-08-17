require_relative 'mod-OS'

def getInterfaces
	#Sur Windows, utilisation de WMI
	nets = Array.new
	if OS.windows?
		require 'win32ole'
		wmi = WIN32OLE.connect("winmgmts://")

		interfaces = wmi.ExecQuery("SELECT * FROM Win32_NetworkAdapterConfiguration Where IPEnabled = True")
		for interface in interfaces do
			net = Hash.new
			net['ip'] = interface.IPAddress
			net['mask'] = interface.IPSubnet
			net['domain'] = interface.DNSDomain
			net['hostname'] = interface.DNSHostName
			net['gateway'] = interface.DefaultIPGateway
		    nets.push(net)
		end
	elsif OS.linux?
		interfaces = `ip -o addr show | grep -v ": lo" | awk '/inet/ {print $4}'`.split("\n")
		for interface in interfaces do
			net = Hash.new
			# Cast de l'IP et du masque en Array pour respecter le format Microsoft
			net['ip'] = Array.new(1,interface.split("/")[0])
			net['mask'] = Array.new(1,interface.split("/")[1])
		    nets.push(net)
		end
	end
	return nets
end

def scanNet
	interfaces = getInterfaces()
	require 'ipaddr'
	interfaces.each{|i|
		interface = IPAddr.new i['ip'].first
		interface = interface.mask(i['mask'].first)

		range = interface.to_range().to_a
		range.shift #delete first IP (0.0) (No valid)
		range.pop #Delete last IP broadcast (No valid)
		puts "Scan local network for #{range.first} to #{range.last}:"

		require 'resolv'

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
	if OS.windows?
		pingOk = Net::Ping::WMI.new(ip).ping?
	elsif OS.linux?
		pingOk = system("ping -q -W 1 -c 1 #{ip}",
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