module Network

   # Project scan network
   #
   # Author::    MultiPlus (mailto:daft_ghost@hotmail.com)
   # Copyright:: Copyright (c) 2014 The Pragmatic Programmers, LLC
   # License::   Distributes under the same terms as Ruby

   # Represent a simple network interface mapped on (ipconfi/ifcong)

   # Using RDOC - Ruby Documentation System
   #    http://rdoc.sourceforge.net/doc/index.html

    class Interface
        MASK_IP   = 1
        MASK_ICDR = 2

        attr_accessor :ipv4, :ipv6, :mac, :mask_ip, :mask_icdr, :gateway

        def initialize(params = {})
            if (params[:ipv4].count('/') == 1)
                params[:ipv4], params[:mask] = params[:ipv4].split('/')
            end

            self.ipv4       = params[:ipv4]
            self.ipv6       = params[:ipv6] if !params[:ipv6].nil?
            self.mac        = params[:mac]
            self.gateway    = params[:gateway]
            self.mask       = params[:mask]
        end

        #================================== SETTER ==================================#

            def ipv4=(ipv4)
                raise(ArgumentError, 'Argument ipv4 must be a valid IP V4 address.') if !Interface.ipv4?(ipv4)
                @ipv4 = ipv4
            end

            def ipv6=(ipv6)
                raise(ArgumentError, 'Argument ipv6 must be a valid IP V6 address.') if !Interface.ipv6?(ipv6)
                @ipv6 = ipv6
            end if

            def mac=(mac)
                raise(ArgumentError, 'Argument mac must be a valid MAC address (Tolered delimiter :,-).') if !Interface.mac?(mac)
                @mac = mac
            end

            def gateway=(gateway)
                raise(ArgumentError, 'Argument gateway must be a valid IP V4 address.') if !Interface.ipv4?(gateway)
                @gateway = gateway
            end

            def mask=(mask)
                if (mask.is_a? Integer) || (mask==mask.to_i.to_s)
                    raise(ArgumentError, 'Argument mask must be a valid ICDR mask.') if !Interface.mask?(mask.to_i, Interface.MASK_ICDR)
                    @mask_icdr = mask
                    @mask_ip = Interface.cidr_to_ip(mask)
                else
                    raise(ArgumentError, 'Argument mask must be a valid IP V4 mask.') if !Interface.mask?(mask)
                    @mask_ip = mask
                    @mask_icdr = Interface.ip_to_cidr(mask)
                end
            end

        #================================== GETTER ==================================#

            #Get mask of interface with specifed format 
            # Inteface::MASK_IP = 1 (default)
            # Inteface::MASK_ICDR = 2
            def mask(type = MASK_IP)
                case :type
                    when MASK_IP
                        return @mask_ip
                    else
                        return @mask_icdr
                end
            end

        #================ VALIDATOR ==================

            #Valide a string is a IPv4 format
            def self.ipv4?(ipv4)
                return (ipv4 =~ /^(([01]?\d\d?|2[0-4]\d|25[0-5])\.){3}([01]?\d\d?|2[0-4]\d|25[0-5])$/)==0
            end

            #Valide a string is a IPv6 format
            def self.ipv6?(ipv6)
                return (ipv6 =~ /^(((?=.*(::))(?!.*\3.+\3))\3?|[\dA-F]{1,4}:)([\dA-F]{1,4}(\3|:\b)|\2){5}(([\dA-F]{1,4}(\3|:\b|$)|\2){2}|(((2[0-4]|1\d|[1-9])?\d|25[0-5])\.?\b){4})$/i)==0
            end

            #Valide a string is a IPv4 Mask format
            def self.mask?(mask, type = MASK_IP)
                case :type
                    when MASK_IP
                         return Interface.ipv4?(mask) && mask.split(".").collect!{|i| i.to_i.to_s(2)}.join().index('01').nil?
                    else
                        return (mask.to_i<1 || mask.to_i>32)
                end
               
            end

            #Valide a string is a MAC format
            def self.mac?(mac)
                return (mac =~ /^([0-9A-F]{2}[:-]){5}([0-9A-F]{2})$/)==0
            end

        #================ METHODS ==================

            # to-s function for Instance object
            def to_s
                puts "ipv4 : #{self.ipv4}"
                puts "mask : #{self.mask}"
                puts "mac : #{self.mask}"
                puts "gateway : #{self.gateway}"
            end

            #Convert a mask IP to CIDR format (255.255.255.0 => 24)
            def self.ip_to_cidr(ip)
                return ip.split(".").collect!{|i|i.to_i.to_s(2)}.join().count('1')
            end

            #Convert a mask CIDR IP to  format (24 => 255.255.255.0)
            def self.cidr_to_ip(cidr)
                return "".ljust(cidr, "1").ljust(32, "0").scan(/\d{8}/).collect!{|b| b.to_i(2).to_s}.join(".")
            end

            def self.get_local_interfaces()
                require_relative 'mod-OS'
                if OS.windows?
                    return get_local_interfaces_windows()
                elsif OS.linux?
                    return get_local_interfaces_linux()
                end
            end

            def self.get_local_interfaces_windows()
                require 'win32ole'
                interfaces = Array.new
                wmi = WIN32OLE.connect("winmgmts://")

                #http://msdn.microsoft.com/en-us/library/aa394217%28v=vs.85%29.aspx
                connections = wmi.ExecQuery("SELECT * FROM Win32_NetworkAdapterConfiguration Where IPEnabled = True")
                for connection in connections do
                        # Check if all parameters are not null
                        ipv4 = connection.IPAddress.first if not connection.IPAddress.nil?
                        mask = connection.IPSubnet.first if not connection.IPSubnet.nil?
                        mac = connection.MACAddress if not connection.MACAddress.nil?
                        gateway = connection.DefaultIPGateway.first if not connection.DefaultIPGateway.nil?
                    interface = Network::Interface.new(
                        :ipv4 => ipv4,
                        :mask => mask,
                        :mac => mac,
                        :gateway => gateway
                    )
                    interfaces.push(interface)
                end
                return interfaces
            end

            def self.get_local_interfaces_linux()
                interfaces = Array.new
                `ip -o addr show | grep -v ": lo" | awk '/inet/ {print $4}'`.split("\n").each{|connection|
                    interface = Network::Interface.new(
                        :ipv4 => connection,
                        :mac => "D4:BE:D9:98:C4:73",
                        :gateway => "129.181.185.254"
                    )
                    interfaces.push(interface)
                }
                return interfaces
            end

            def self.get_info_from_ip(ip)
                require_relative 'mod-OS'
                if OS.windows?
                    return get_info_from_ip_windows(ip)
                elsif OS.linux?
                    return get_info_from_ip_linux(ip)
                end
                return nil
            end

            def self.get_info_from_ip_windows(ip)
                info = Hash.new
                count = 1   #Stop after sending count ECHO_REQUEST packets. With deadline option, ping waits for count ECHO_REPLY packets, until the timeout expires. 
                timeout = 1 #Time to wait for a response, in seconds. The option affects only timeout in absense of any responses, otherwise ping waits for two RTTs.
                info[:ping] = system("ping -w #{timeout} -n #{count} #{ip}",
                               [:err, :out] => "NUL")
                if info[:ping]
                    require 'resolv'
                    info[:name] = Resolv.getname(ip) rescue nil
                end
                return info
            end

            def self.get_info_from_ip_linux(ip)
                info = Hash.new
                count = 1   #Stop after sending count ECHO_REQUEST packets. With deadline option, ping waits for count ECHO_REPLY packets, until the timeout expires. 
                timeout = 1 #Time to wait for a response, in seconds. The option affects only timeout in absense of any responses, otherwise ping waits for two RTTs.
                #-q: Quiet output. Nothing is displayed except the summary lines at startup time and when finished. 
                info[:ping] = system("ping -q -W #{timeout} -c #{count} #{ip}",
                   [:err, :out] => "/dev/null")
                if info[:ping]
                    require 'resolv'
                    info[:name] = Resolv.getname(ip) rescue nil
                end
                return info
            end

            def print_network_device()
                require 'ipaddr'
                used_ip = IPAddr.new "#{self.ipv4}/#{self.mask}"
                range = used_ip.to_range().to_a
                range.shift #delete first IP (0.0) (No valid)
                range.pop   #Delete last IP broadcast (No valid)
                puts "Scan local network for #{range.first} to #{range.last}:"

                #Create a thread by ping/ip
                results = Hash.new
                threads = Array.new
                range.each{|ip|
                    threads.push(Thread.new{
                        results[ip.to_s] = Interface.get_info_from_ip(ip.to_s)
                    })
                }
                #Wait End of all Threads to continue
                threads.each{|t|t.join}

                results = results.reject{|k,v| !v[:ping]}

                puts "You have actualy #{results.count} device(s) with a IP on your network: "
                results.each{|ip, info|
                    if info[:ping]
                        puts "\t- #{ip} [#{info[:name]}]"
                    end
                }
            end
    end
end
