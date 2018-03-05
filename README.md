# lua-iptools

A lua ip tools library.

[![Build Status](https://travis-ci.org/serverzone/lua-iptools.svg?branch=master)](https://travis-ci.org/serverzone/lua-iptools)

## Dependences

Following library in dependented:

* [Lua Bit Operations Module](http://bitop.luajit.org/index.html)
* [Unit Testing Framework for Lua](https://www.mroth.net/lunit/)

## Usage

```lua
local ip = require("iptools")

// return true when is IP (v4 or v6) address valid, otherwise false
result = ip.isValidAddr('192.168.1.1')
result = ip.isValidAddr('::1')

// return true when is IPv4 address valid, otherwise false
result = ip.isValidAddrV4('192.168.1.1')

// return true when is IPv6 address valid, otherwise false
result = ip.isValidAddrV6('::1')

// return true when is true if mask is valid for IPv4, otherwise false
result = ip.isValidMaskV4(24)

// return true when is true if mask is valid for IPv6, otherwise false
result = ip.isValidMaskV6(64)

// return true if IP (v4 or v6) and mask are valid, otherwise false
result = ip.isValid('192.168.1.1', 16)

// return true if IP (v4 or v6) and mask are valid, otherwise false
result = ip.isValid('192.168.1.1', 16)
result = ip.isValid('2001:0db8:85a3:08d3:1319:8a2e:0370:7334', 64)

// return true if IPv4 and mask are valid, otherwise false
result = ip.isValidV4('192.168.1.1', 16)

// return true if IPv6 and mask are valid, otherwise false
result = ip.isValidV6('2001:0db8:85a3:08d3:1319:8a2e:0370:7334', 64)

// return metatable with IPv4 instance if IPv4 and mask are valid, otherwise nil
ipv4 = ip.v4('192.168.1.1', 16)

// return metatable with IPv6 instance if IPv4 and mask are valid, otherwise nil
ipv6 = ip.v6('::1')

// check if address is in subnet
subnet = ip.v4('192.168.5.128', 26)
addr = ip.v4('192.168.5.130')
result = ip.isInSubnet(addr, subnet)
```

## Testing

```bash
lua test/testiptools.lua
```
-----
Project at GitHub: https://github.com/serverzone/lua-iptools

