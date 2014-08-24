require_relative "Interface.class"

#======================= Test =======================
i = Network::Interface.new(
   :ipv4 => "129.181.185.120",
   :mask => "255.255.255.0",
   :mac => "D4:BE:D9:98:C4:73",
   :gateway => "129.181.185.254"
)

puts i.inspect

puts Network::Interface.isValideIPv4("5.168.0.1")