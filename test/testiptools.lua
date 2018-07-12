--
-- IP address lua module tester
--
package.path = package.path .. ';./src/init.lua'

-- Unit testing starts
require('luaunit')

TestIPModule = {} 

    local ip = require("iptools")

    function TestIPModule:testIsIPv4Valid()
        result = ip.isValidAddr('192.168.1.1')
        assertEquals(result, true)

        result = ip.isValidAddr('192.168.1.255')
        assertEquals(result, true)

        result = ip.isValidAddr('127.000.000.001')
        assertEquals(result, true)

        result = ip.isValidAddr('foo')
        assertEquals(result, false)

    end

    function TestIPModule:testIsMaskv4Valid()
        result = ip.isValidMaskV4(1)
        assertEquals(result, true)

        result = ip.isValidMaskV4(24)
        assertEquals(result, true)

        result = ip.isValidMaskV4(32)
        assertEquals(result, true)

        result = ip.isValidMaskV4(33)
        assertEquals(result, false)
    end

    function TestIPModule:testIpV4ToString()
        addr = ip.v4('192.168.1.1')
        assertEquals(tostring(addr), '192.168.1.1/24')

        addr = ip.v4('192.168.1.255', 32)
        assertEquals(tostring(addr), '192.168.1.255/32')

        addr = ip.v4('127.000.000.001')
        assertEquals(tostring(addr), '127.0.0.1/24')

        addr = ip.v4('192.168.1.256')
        assertEquals(addr, nil)

        addr = ip.v4('127.-1.0.1')
        assertEquals(addr, nil)

        addr = ip.v4('127.128.256.1')
        assertEquals(addr, nil)
    end

    function TestIPModule:testIsIPv6Valid()
        result = ip.isValidAddr('2001:0db8:85a3:08d3:1319:8a2e:0370:7334')
        assertEquals( result, true )

        result = ip.isValidAddr('::1')
        assertEquals( result, true )

        result = ip.isValidAddr('::ffff:0:0')
        assertEquals( result, true )

        result = ip.isValidAddr('foo')
        assertEquals( result, false )
    end

    function TestIPModule:testIsMaskv6Valid()
        result = ip.isValidMaskV6(1)
        assertEquals(result, true)

        result = ip.isValidMaskV6(64)
        assertEquals(result, true)

        result = ip.isValidMaskV6(128)
        assertEquals(result, true)

        result = ip.isValidMaskV6(129)
        assertEquals(result, false)
    end

    function TestIPModule:testIpV6ToString()
        addr = ip.v6('2001:0db8:85a3:08d3:1319:8a2e:0370:7334', 128)
        assertEquals(tostring(addr), '2001:0db8:85a3:08d3:1319:8a2e:0370:7334/128')

        addr = ip.v6('2001:0db8:0000:0000:0000:0000:1428:57ab')
        assertEquals(tostring(addr), '2001:0db8:0000:0000:0000:0000:1428:57ab/64')

        addr = ip.v6('2001:0db8:0000:0000:0000::1428:57ab')
        assertEquals(tostring(addr), '2001:0db8:0000:0000:0000:0000:1428:57ab/64')
        
        addr = ip.v6('2001:0db8:0:0:0:0:1428:57ab')
        assertEquals(tostring(addr), '2001:0db8:0000:0000:0000:0000:1428:57ab/64')

        addr = ip.v6('2001:0db8:0:0::1428:57ab')
        assertEquals(tostring(addr), '2001:0db8:0000:0000:0000:0000:1428:57ab/64')

        addr = ip.v6('2001:0db8::1428:57ab')
        assertEquals(tostring(addr), '2001:0db8:0000:0000:0000:0000:1428:57ab/64')

        addr = ip.v6('2001:db8::1428:57ab')
        assertEquals(tostring(addr), '2001:0db8:0000:0000:0000:0000:1428:57ab/64')

        addr = ip.v6('::1')
        assertEquals(tostring(addr), '0000:0000:0000:0000:0000:0000:0000:0001/64')

        addr = ip.v6('::ffff:0:0')
        assertEquals(tostring(addr), '0000:0000:0000:0000:0000:ffff:0000:0000/64')

        addr = ip.v6('2001::FFD3::57ab')
        assertEquals(addr, nil)

        addr = ip.v6('2001:0db8:85a3:08d3:1319:8a2e:0370:733432')
        assertEquals(addr, nil)
    end

    function TestIPModule:testIsInSubnet()
        subnet = ip.v4('192.168.5.128', 26)
        addr = ip.v4('192.168.5.130')
        result = ip.isInSubnet(addr, subnet)
        assertEquals(result, true)

        addr = ip.v4('192.164.5.130')
        result = ip.isInSubnet(addr, subnet)
        assertEquals(result, false)

        subnet = ip.v4('192.168.5.0', 24)
        addr = ip.v4('192.168.5.130')
        result = ip.isInSubnet(addr, subnet)
        assertEquals(result, true)

        subnet = ip.v4('127.0.0.0', 24)
        addr = ip.v4('127.0.0.1')
        result = ip.isInSubnet(addr, subnet)
        assertEquals(result, true)

        subnet = ip.v4('127.0.0.1', 24)
        addr = ip.v4('127.0.0.1')
        result = ip.isInSubnet(addr, subnet)
        assertEquals(result, true)

        subnet = ip.v4('127.8.4.1', 1)
        addr = ip.v4('127.0.0.1')
        result = ip.isInSubnet(addr, subnet)
        assertEquals(result, true)

        subnet = ip.v4('127.0.0.0', 24)
        addr = ip.v4('127.1.5.1')
        result = ip.isInSubnet(addr, subnet)
        assertEquals(result, false)

        -- combination ip v4 a v6
        addr = ip.v6('::1')
        result = ip.isInSubnet(addr, subnet)
        assertEquals(result, false)

        -- ip v6 subnet
        subnet = ip.v6('2001:0db8:85a3:08d3:0:0:0:0', 64)
        addr = ip.v6('2001:0db8:85a3:08d3:0:0:1234:0')
        result = ip.isInSubnet(addr, subnet)
        assertEquals(result, true)

        subnet = ip.v6('2001:0db8:85a3:08d3:3268::0', 64)
        addr = ip.v6('2001:0db8:85a3:08d3::1234:0')
        result = ip.isInSubnet(addr, subnet)
        assertEquals(result, true)

        subnet = ip.v6('2001:0db8:85a3:08d3:3268::0', 64)
        addr = ip.v6('2001:2db8:85a3:08d3::1234:0')
        result = ip.isInSubnet(addr, subnet)
        assertEquals(result, false)
    end

LuaUnit:run()