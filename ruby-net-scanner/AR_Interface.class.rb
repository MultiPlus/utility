require "active_record"

module Network

   # Project scan network
   #
   # Author::    MultiPlus (mailto:daft_ghost@hotmail.com)
   # Copyright:: Copyright (c) 2014 The Pragmatic Programmers, LLC
   # License::   Distributes under the same terms as Ruby

   # Represent a simple network interface mapped on (ipconfi/ifcong)

   # Using RDOC - Ruby Documentation System
   #    http://rdoc.sourceforge.net/doc/index.html

    class Interface < ActiveRecord::Base
        @@MASK_IP = 1
        @@MASK_ICDR = 2

        validates :ipv4, presence: true, format: { with: /\A(([01]?\d\d?|2[0-4]\d|25[0-5])\.){3}([01]?\d\d?|2[0-4]\d|25[0-5])\z/,
            message: "Argument ipv4 must be a valid IP V4 address" }
        validates :ipv6, format: { with: /\A(((?=.*(::))(?!.*\3.+\3))\3?|[\dA-F]{1,4}:)([\dA-F]{1,4}(\3|:\b)|\2){5}(([\dA-F]{1,4}(\3|:\b|$)|\2){2}|(((2[0-4]|1\d|[1-9])?\d|25[0-5])\.?\b){4})\z/i,
            message: "Argument ipv6 must be a valid IP V6 address" }
        validates :mac, presence: true, format: { with: /\A([0-9A-F]{2}[:-]){5}([0-9A-F]{2})\z/,
            message: "Argument ipv4 must be a valid IP V4 address" }
        validates :mask_ip, presence: true
        validates :mask_icdr, presence: true, :inclusion => {:in => [1..32]}
        validates :gateway, presence: true, format: { with: /\A(([01]?\d\d?|2[0-4]\d|25[0-5])\.){3}([01]?\d\d?|2[0-4]\d|25[0-5])\z/,
            message: "Argument gateway must be a valid IP V4 address" }

        #def initialize(params = {})
        #    if (params[:ipv4].count('/') == 1)
        #        params[:ipv4], params[:mask] = params[:ipv4].split('/')
        #    end

        #    self.mask       = params[:mask]
        #end

        #================================== SETTER ==================================#

            def mask=(mask)
                if (mask.is_a? Integer)
                    raise(ArgumentError, 'Argument mask must be a valid ICDR mask.') if (mask<0 || mask>32)
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
            #Valide a string is a IPv4 Mask format
            def self.isValidIPv4Mask(mask)
                return mask.split(".").collect!{|i| i.to_i.to_s(2)}.join().index('01').nil? && Interface.isValideIPv4(mask)
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
    end
end
