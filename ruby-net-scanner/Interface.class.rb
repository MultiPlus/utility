require 'ipaddr'

module Network
    class Interface
        attr_accessor  :ipv4, :ipv6, :mac, :mask, :gateway

        def initialize(params = {})
            if (params[:ipv4].count('/') == 1)
                i = IPAddr.new(params[:ipv4])
            else
                i = IPAddr.new("#{params[:ipv4]}/#{params[:mask]}")
            end

            raise(ArgumentError, 'Argument ipv4 must be a valid IP V4 address.') if !isValideIPv4(params[:ipv4]) 
            raise(ArgumentError, 'Argument ipv6 must be a valid IP V6 address.') if !params[:ipv6].nil? && !isValideIPv6(params[:ipv6])
            raise(ArgumentError, 'Argument mac must be a valid MAC address (Tolered delimiter :,-).') if !isValideMAC(params[:mac])

            @ipv4       = i.to_s
            @ipv6       = params[:ipv6]
            @mac        = params[:mac]
            @mask       = params[:mask]
            @gateway    = params[:gateway]
        end

        def isValideIPv4(ipv4)
            return (ipv4 =~ /^([0-9]{1,3}\.){3}([0-9]{1,3})$/)
        end

        def isValideIPv6(ipv6)
            return (ipv6 =~ /^((([0-9A-Fa-f]{1,4}:){7}[0-9A-Fa-f]{1,4})|(([0-9A-Fa-f]{1,4}:){6}:[0-9A-Fa-f]{1,4})|(([0-9A-Fa-f]{1,4}:){5}:([0-9A-Fa-f]{1,4}:)?[0-9A-Fa-f]{1,4})|(([0-9A-Fa-f]{1,4}:){4}:([0-9A-Fa-f]{1,4}:){0,2}[0-9A-Fa-f]{1,4})|(([0-9A-Fa-f]{1,4}:){3}:([0-9A-Fa-f]{1,4}:){0,3}[0-9A-Fa-f]{1,4})|(([0-9A-Fa-f]{1,4}:){2}:([0-9A-Fa-f]{1,4}:){0,4}[0-9A-Fa-f]{1,4})|(([0-9A-Fa-f]{1,4}:){6}((b((25[0-5])|(1d{2})|(2[0-4]d)|(d{1,2}))b).){3}(b((25[0-5])|(1d{2})|(2[0-4]d)|(d{1,2}))b))|(([0-9A-Fa-f]{1,4}:){0,5}:((b((25[0-5])|(1d{2})|(2[0-4]d)|(d{1,2}))b).){3}(b((25[0-5])|(1d{2})|(2[0-4]d)|(d{1,2}))b))|(::([0-9A-Fa-f]{1,4}:){0,5}((b((25[0-5])|(1d{2})|(2[0-4]d)|(d{1,2}))b).){3}(b((25[0-5])|(1d{2})|(2[0-4]d)|(d{1,2}))b))|([0-9A-Fa-f]{1,4}::([0-9A-Fa-f]{1,4}:){0,5}[0-9A-Fa-f]{1,4})|(::([0-9A-Fa-f]{1,4}:){0,6}[0-9A-Fa-f]{1,4})|(([0-9A-Fa-f]{1,4}:){1,7}:))$/)
        end

        def isValideMAC(mac)
            return (mac =~ /^([0-9A-F]{2}[:-]){5}([0-9A-F]{2})$/)
        end

        def IPtoCIDR(ip)
            return ip.split(".").collect!{|i|i.to_i.to_s(2)}.join().count('1')
        end

        def getOnWindowsWMI
    	end
    end
end
#======================= Test =======================
i = Network::Interface.new(
    :ipv4 => "129.181.185.120",
    :mask => "255.255.255.0",
    :mac => "D4:BE:D9:98:C4:73",
    :gateway => "129.181.185.254"
)
puts i.inspect