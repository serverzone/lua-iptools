--
-- IP address lua module
--
local iptools = {}

local IPv4_REG_EXP = "^(%d+).(%d+).(%d+).(%d+)$"
local IPv6_REG_EXP = "^([:%dxXa-fA-F]-::?)(([%dxXa-fA-F]*)[%.%dxXa-fA-F]*)$"

local bit = require("bit")

-- IP metatable
--
local ip_metatable = {

    --
    -- IP table to string
    --
    -- @return string
    --
    __tostring = function(self)
        if (#self.addr == 2) then
            return string.format("%d.%d.%d.%d/%d", 
                bit.rshift(self.addr[1], 8), bit.band(self.addr[1], 0xFF),
                bit.rshift(self.addr[2], 8), bit.band(self.addr[2], 0xFF), self.mask)
        elseif (#self.addr == 8) then
            return string.format("%04x:%04x:%04x:%04x:%04x:%04x:%04x:%04x/%d", 
                self.addr[1], self.addr[2], self.addr[3], self.addr[4], 
                self.addr[5], self.addr[6], self.addr[7], self.addr[8], 
                self.mask)
        end

        return "not ip address"
    end
}

-- 
-- Create new IP metatable
--
-- @param table addr IP address
-- @param number mask Mask
-- @return metatable
-- 
local function new(addr, mask)
  return setmetatable({ addr=addr, mask=mask }, ip_metatable)
end

local function __mask16(bits)
	return bit.lshift( bit.rshift( 0xFFFF, 16 - bits % 16 ), 16 - bits % 16 )
end

local function createSubnetMask(subnet)
    local data = { }

    for i = 1, math.floor( subnet.mask / 16 ) do
        data[#data+1] = 0xFFFF
    end

    if #data < #subnet.addr then
        data[#data+1] = __mask16(subnet.mask)

	for i = #data + 1, #subnet.addr do
            data[#data+1] = 0
	end
    end

    return data
end

--
-- Checks if an IP is valid IPv4 format.
-- 
-- @param string addr IP address
-- @return boolean true if IP is valid IPv4, otherwise false.
--
function iptools.isValidAddrV4(addr)
    return string.find(addr, IPv4_REG_EXP) ~= nil
end

--
-- Checks if an IP is valid IPv6 format.
-- 
-- @param string addr IP address
-- @return boolean true if IP is valid IPv6, otherwise false.
--
function iptools.isValidAddrV6(addr)
    return string.find(addr, IPv6_REG_EXP) ~= nil
end


--
-- Checks if an IP (v4 or v6) is valid.
--
-- @param string addr IP address
-- @return boolean true if IP is valid, otherwise false.
-- 
function iptools.isValidAddr(addr)
    return iptools.isValidAddrV4(addr) or iptools.isValidAddrV6(addr)
end


--
-- Checks if a mask is valid for IPv4 format.
-- 
-- @param number mask Mask value
-- @return boolean true if mask is valid for IPv4, otherwise false.
--
function iptools.isValidMaskV4(mask)
    return (type(mask) == "number") and (mask > 0) and (mask <= 32)
end


--
-- Checks if a mask is valid for IPv6 format.
-- 
-- @param number mask Mask value
-- @return boolean true if mask is valid IPv6, otherwise false.
--
function iptools.isValidMaskV6(mask)
    return (type(mask) == "number") and (mask > 0) and (mask <= 128)
end


--
-- Checks if an IP address and mask are valid IPv4 format.
-- 
-- @param string addr IP address
-- @param number mask Mask value
-- @return boolean true if IP and mask are valid IPv4, otherwise false.
--
function iptools.isValidV4(addr, mask)
    return iptools.isValidAddrV4(addr) and iptools.isValidMaskV4(mask)
end


--
-- Checks if an IP address and mask are valid IPv6 format.
-- 
-- @param string addr IP address
-- @param number mask Mask value
-- @return boolean true if IP and mask are valid IPv6, otherwise false.
--
function iptools.isValidV6(addr, mask)
    return iptools.isValidAddrV6(addr) and iptools.isValidMaskV6(mask)
end


--
-- Checks if an IP (v4 or v6) address and mask are valid.
--
-- @param string addr IP address
-- @param number mask Mask
-- @return boolean true if IP and mask are valid, otherwise false.
-- 
function iptools.isValid(addr, mask)
    return iptools.isValidV4(addr, mask) or iptools.isValidV6(addr, mask)
end

--
-- Assert IPv4 and create it's metatable
--
-- @param string addr IP address
-- @param number mask Mask
-- @return metatable
--
function iptools.v4(addr, mask)

    mask = mask or 24
    
    if (iptools.isValidV4(addr, mask) == true) then
        local b1, b2, b3, b4 = string.match(addr, "^(%d+)%.(%d+)%.(%d+)%.(%d+)$")

        b1 = tonumber(b1)
        b2 = tonumber(b2)
        b3 = tonumber(b3)
        b4 = tonumber(b4)
        
        if b1 and b1 <= 255 and b2 and b2 <= 255 and
           b3 and b3 <= 255 and b4 and b4 <= 255 then
            return new({b1 * 256 + b2, b3 * 256 + b4}, mask)
        end
    end

    return nil
end

--
-- Assert IPv6 and create it"s metatable
--
-- @param string addr IP address
-- @param number mask Mask
-- @return metatable
--
function iptools.v6(addr, mask)
    
    mask = mask or 64

    if (iptools.isValidV6(addr, mask) ~= true) or (#addr > 45) then
        return nil
    end

    local data = {}
    local borderl = addr:sub(1, 1) == ":" and 2 or 1
    local borderh, zeroh, block

    repeat
        borderh = addr:find(":", borderl, true)
        if not borderh then
            break
        end
        
        block = tonumber(addr:sub(borderl, borderh - 1), 16)
        if block and block <= 0xFFFF then
            data[#data+1] = block
	else
            if zeroh or (borderh - borderl > 1) then
                return nil
            end
            zeroh = #data + 1
        end

        borderl = borderh + 1
    until #data == 7

    local chunk = addr:sub(borderl)
    block = tonumber(chunk, 16)
    data[#data+1] = block

    if zeroh then
        local i
        while #data < 8 do
            for i = #data, zeroh, -1 do
                data[i+1] = data[i]
            end
            data[zeroh] = 0
        end
    end

    if #data == 8 and
       data[1] >= 0 and data[1] < 0x10000 and data[2] >= 0 and data[2] < 0x10000 and
       data[3] >= 0 and data[3] < 0x10000 and data[4] >= 0 and data[4] < 0x10000 and
       data[5] >= 0 and data[5] < 0x10000 and data[6] >= 0 and data[6] < 0x10000 and
       data[7] >= 0 and data[7] < 0x10000 and data[8] >= 0 and data[8] < 0x10000 then
        return new(data, mask)
    end
    
    return nil
end

--
-- Check if is address in subnet
--
-- @param table addr IP address
-- @param table subnet Subnet address
-- @return boolean
--
function iptools.isInSubnet(addr, subnet)
    if (#subnet.addr ~= #addr.addr) then
        return false -- different IP version
    end

    subnet_mask = createSubnetMask(subnet)   
    
    local prefix = {}
    for i = 1, #subnet.addr do
        prefix[i] = bit.band(subnet.addr[i], subnet_mask[i])
    end

    for i = 1, #prefix do
        if (bit.band(addr.addr[i], subnet_mask[i]) ~= prefix[i]) then
            return false;
        end
    end

    return true
end

return iptools