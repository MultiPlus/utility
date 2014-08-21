require_relative "Interface.class"
require "test/unit"
 
class TestInterface < Test::Unit::TestCase
    def test_mask()
		i1 = Network::Interface.new(
			:ipv4 => "192.168.0.1",
			:mask => "255.255.255.0",
		)
		i2 = Network::Interface.new(
			:ipv4 => "192.168.0.1",
			:mask => "24",
		)
		i3 = Network::Interface.new(
			:ipv4 => "192.168.0.1/24",
		)
		i4 = Network::Interface.new(
			:ipv4 => "192.168.0.1/255.255.255.0",
		)
        assert_equal(i1, i2)
        assert_equal(i1, i3)
        assert_equal(i1, i4)
        assert_equal(i2, i3)
        assert_equal(i2, i4)
        assert_equal(i3, i4)
    end
end