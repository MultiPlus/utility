require_relative "Interface.class"

#======================= Test =======================
i = Network::Interface.new(
   :ipv4 => "129.181.185.120",
   :mask => "255.255.255.0",
   :mac => "D4:BE:D9:98:C4:73",
   :gateway => "129.181.185.254"
)

#puts i.inspect

#puts Network::Interface.isValideIPv4("5.168.0.1")

#Network::Interface.get_local_interfaces()[0].print_network_device()

# Lance le Interface.to_s mais aussi le puts de l'objet (j'ai l'impression)
puts Network::Interface.get_local_interfaces()[0]
puts "==============================================="

# Lance le Interface.to_s mais aussi le print de l'objet (j'ai l'impression)
print Network::Interface.get_local_interfaces()[0]
puts "==============================================="

# Force le lancement de Interface.to_s, le puts natif n'est plus affiché
puts Network::Interface.get_local_interfaces()[0].to_s
puts "==============================================="

# Force le lancement de Interface.to_s, le print natif n'est plus affiché
print Network::Interface.get_local_interfaces()[0].to_s
puts "==============================================="