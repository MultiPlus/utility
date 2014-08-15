require_relative 'mod-OS'

def getInterfaces
	#Sur Windows, utilisation de WMI
	if OS.windows?
		require 'win32ole'
		wmi = WIN32OLE.connect("winmgmts://")

		interfaces = wmi.ExecQuery("SELECT * FROM Win32_NetworkAdapterConfiguration Where IPEnabled = True")
		nets = Array.new
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
		interfaces = `ip -o addr show | awk '/inet/ {print $4}'`.split("\n")
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

		range.each{|ip|
			getInfoFromIp(ip)
		}
	}
end

def getInfoFromIp(ip)
	#gem install net-ping
	require 'net/ping'
	pingOk = Net::Ping::WMI.new(ip).ping?
	if pingOk
		require 'Resolv'
		name = Resolv.getname(ip)
		puts "Successfull ping ip #{ip} (Resolved name: #{name})"
	else
		puts "Failed ping ip #{ip}"
	end
end

def main
	scanNet()
	#getInfoFromIp('192.168.0.175')
end
main()