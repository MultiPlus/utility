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
        @@MASK_IP   = 1
        @@MASK_ICDR = 2

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
                @ipv6 = ipv6
            end

            def gateway=(gateway)
                raise(ArgumentError, 'Argument gateway must be a valid IP V4 address.') if !Interface.ipv4?(gateway)
                @gateway = gateway
            end

            def mask=(mask)
                if (mask.is_a? Integer)
                    raise(ArgumentError, 'Argument mask must be a valid ICDR mask.') if !Interface.mask?(mask, Interface.MASK_ICDR)
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
                        return (mask<1 || mask>32)
                end
               
            end

            #Valide a string is a MAC format
            def self.mac?(mac)
                return (mac =~ /^([0-9A-F]{2}[:-]){5}([0-9A-F]{2})$/)==0
            end

        #================ METHODS ==================

            #Convert a mask IP to CIDR format (255.255.255.0 => 24)
            def self.ip_to_cidr(ip)
                return ip.split(".").collect!{|i|i.to_i.to_s(2)}.join().count('1')
            end

            #Convert a mask CIDR IP to  format (24 => 255.255.255.0)
            def self.cidr_to_ip(cidr)
                return "".ljust(cidr, "1").ljust(32, "0").scan(/\d{8}/).collect!{|b| b.to_i(2).to_s}.join(".")
            end
    end
end
