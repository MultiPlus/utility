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
        MASK_IP = 1
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
                puts "init ipv4"
                raise(ArgumentError, 'Argument ipv4 must be a valid IP V4 address.') if !Interface.isValideIPv4(ipv4)
                @ipv4 = ipv4
            end

            def ipv6=(ipv6)
                raise(ArgumentError, 'Argument ipv6 must be a valid IP V6 address.') if !Interface.isValideIPv6(ipv6)
                @ipv6 = ipv6
            end if

            def mac=(mac)
                raise(ArgumentError, 'Argument mac must be a valid MAC address (Tolered delimiter :,-).') if !Interface.isValideMAC(mac)
                @ipv6 = ipv6
            end

            def gateway=(gateway)
                raise(ArgumentError, 'Argument gateway must be a valid IP V4 address.') if !Interface.isValideIPv4(gateway)
                @gateway = gateway
            end

            def mask=(mask)
                if (mask.is_a? Integer)
                    raise(ArgumentError, 'Argument mask must be a valid ICDR mask.') if !Interface.isValidIPv4Mask(mask)
                    @mask_icdr = mask
                    @mask_ip = Interface.CIDRtoIP(mask)
                else
                    raise(ArgumentError, 'Argument mask must be a valid IP V4 mask.') if !Interface.isValidIPv4Mask(mask)
                    @mask_ip = mask
                    @mask_icdr = Interface.IPtoCIDR(mask)
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
            def self.isValideIPv4(ipv4)
                return (ipv4 =~ /^([0-9]{1,3}\.){3}([0-9]{1,3})$/)
            end

            #Valide a string is a IPv6 format
            def self.isValideIPv6(ipv6)
                return (ipv6 =~ /^((([0-9A-Fa-f]{1,4}:){7}[0-9A-Fa-f]{1,4})|(([0-9A-Fa-f]{1,4}:){6}:[0-9A-Fa-f]{1,4})|(([0-9A-Fa-f]{1,4}:){5}:([0-9A-Fa-f]{1,4}:)?[0-9A-Fa-f]{1,4})|(([0-9A-Fa-f]{1,4}:){4}:([0-9A-Fa-f]{1,4}:){0,2}[0-9A-Fa-f]{1,4})|(([0-9A-Fa-f]{1,4}:){3}:([0-9A-Fa-f]{1,4}:){0,3}[0-9A-Fa-f]{1,4})|(([0-9A-Fa-f]{1,4}:){2}:([0-9A-Fa-f]{1,4}:){0,4}[0-9A-Fa-f]{1,4})|(([0-9A-Fa-f]{1,4}:){6}((b((25[0-5])|(1d{2})|(2[0-4]d)|(d{1,2}))b).){3}(b((25[0-5])|(1d{2})|(2[0-4]d)|(d{1,2}))b))|(([0-9A-Fa-f]{1,4}:){0,5}:((b((25[0-5])|(1d{2})|(2[0-4]d)|(d{1,2}))b).){3}(b((25[0-5])|(1d{2})|(2[0-4]d)|(d{1,2}))b))|(::([0-9A-Fa-f]{1,4}:){0,5}((b((25[0-5])|(1d{2})|(2[0-4]d)|(d{1,2}))b).){3}(b((25[0-5])|(1d{2})|(2[0-4]d)|(d{1,2}))b))|([0-9A-Fa-f]{1,4}::([0-9A-Fa-f]{1,4}:){0,5}[0-9A-Fa-f]{1,4})|(::([0-9A-Fa-f]{1,4}:){0,6}[0-9A-Fa-f]{1,4})|(([0-9A-Fa-f]{1,4}:){1,7}:))$/)
            end

            #Valide a string is a IPv4 Mask format
            def self.isValidIPv4Mask(mask)
                return mask.split(".").collect!{|i|i.to_i.to_s(2)}.join().index('01').nil? && Interface.isValideIPv4(mask)
            end

            #Valide a string is a MAC format
            def self.isValideMAC(mac)
                return (mac =~ /^([0-9A-F]{2}[:-]){5}([0-9A-F]{2})$/)
            end

        #================ METHODS ==================

            #Convert a mask IP to CIDR format (255.255.255.0 => 24)
            def self.IPtoCIDR(ip)
                return ip.split(".").collect!{|i|i.to_i.to_s(2)}.join().count('1')
            end

            #Convert a mask CIDR IP to  format (24 => 255.255.255.0)
            def self.CIDRtoIP(cidr)
                return "".ljust(cidr, "1").ljust(32, "0").match(/([0-1]{8})([0-1]{8})([0-1]{8})([0-1]{8})/)[1..4].collect!{|b| b.to_i(2).to_s}.join(".")
            end

        #================ DATA ACCESS ==================

            def getOnWindowsWMI
        	end
    end
end