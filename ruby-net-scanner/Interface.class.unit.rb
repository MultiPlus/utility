require_relative "Interface.class"
require "test/unit"
 
module Network
	class TestInterface < Test::Unit::TestCase
		def test_mask_CIDRtoIP()
			assert_equal("255.255.255.255", Interface.CIDRtoIP(32) )
			assert_equal("255.255.255.252", Interface.CIDRtoIP(30) )
			assert_equal("255.255.255.0", Interface.CIDRtoIP(24) )
			assert_equal("255.255.224.0", Interface.CIDRtoIP(19) )
			assert_equal("255.255.0.0", Interface.CIDRtoIP(16) )
			assert_equal("255.192.0.0", Interface.CIDRtoIP(10) )
			assert_equal("255.0.0.0", Interface.CIDRtoIP(8) )
			assert_equal("254.0.0.0", Interface.CIDRtoIP(7) )
			assert_equal("128.0.0.0", Interface.CIDRtoIP(1) )
			assert_equal("0.0.0.0", Interface.CIDRtoIP(0) )
		end
		def test_mask_IPtoCIDR()
			assert_equal(32, Interface.IPtoCIDR("255.255.255.255") )
			assert_equal(30, Interface.IPtoCIDR("255.255.255.252") )
			assert_equal(24, Interface.IPtoCIDR("255.255.255.0") )
			assert_equal(19, Interface.IPtoCIDR("255.255.224.0") )
			assert_equal(16, Interface.IPtoCIDR("255.255.0.0") )
			assert_equal(10, Interface.IPtoCIDR("255.192.0.0") )
			assert_equal(8, Interface.IPtoCIDR("255.0.0.0") )
			assert_equal(7, Interface.IPtoCIDR("254.0.0.0") )
			assert_equal(1, Interface.IPtoCIDR("128.0.0.0") )
			assert_equal(0, Interface.IPtoCIDR("0.0.0.0") )
		end
		#def test_initalize
		#	assert_throws( ArgumentError ) { Inteface.new( :ipv4 => "no_ip" ) }
		#	assert_throws( ArgumentError ) { Inteface.new( :ipv4 => "255.181.185.120" ) }
		#	assert_throws( ArgumentError ) { Inteface.new( :ipv4 => "555.181.185.120" ) }
		#	assert_throws( ArdgumentError ) { Inteface.new( :ipv4 => "010.181.185.120" ) }
		#end
		def test_ipv4
			assert(Interface.isValideIPv4("192.168.0.1") )
			assert(!Interface.isValideIPv4("no_ip") )
			assert(!Interface.isValideIPv4("555.181.185.120") )
			assert(!Interface.isValideIPv4("010.181.185.120") )
		end
	end
end
