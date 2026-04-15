local vector3d = require("vector3d")

local BitStream = {
	IO = {}
}

local IO = BitStream.IO
local bitStream = bitStream or {}

-- funcs
BitStream.new = raknetNewBitStream or bitStream.new
BitStream.delete = raknetDeleteBitStream or function() end
BitStream.emul = raknetEmulPacketReceiveBitStream or function() end
BitStream.send = raknetSendBitStream or bitStream.sendPacket
BitStream.ignoreBits = raknetBitStreamIgnoreBits or bitStream.ignoreBits
BitStream.setReadOffset = raknetBitStreamSetReadOffset or bitStream.setReadOffset
BitStream.setWriteOffset = raknetBitStreamSetWriteOffset or bitStream.setWriteOffset
BitStream.getNumberOfUnreadBits = raknetBitStreamGetNumberOfUnreadBits or bitStream.getNumberOfUnreadBits

-- types
IO.bool = {
	read = raknetBitStreamReadBool or bitStream.readBool,
	write = raknetBitStreamWriteBool or bitStream.writeBool
}

IO.uint8 = {
	read = raknetBitStreamReadInt8 or bitStream.readUInt8,
	write = raknetBitStreamWriteInt8 or bitStream.writeUInt8
}

IO.uint16 = {
	read = raknetBitStreamReadInt16 or bitStream.readUInt16,
	write = raknetBitStreamWriteInt16 or bitStream.writeUInt16
}

IO.uint32 = {
	read = raknetBitStreamReadInt32 and (function(bs)
		local v = raknetBitStreamReadInt32(bs)
		return v < 0 and 0x100000000 + v or v
	end) or bitStream.readUInt32,
	write = raknetBitStreamWriteInt32 or bitStream.writeUInt32
}

IO.int8 = {
	read = raknetBitStreamReadInt8 and (function(bs)
		local v = raknetBitStreamReadInt8(bs)
		return v >= 0x80 and v - 0x100 or v
	end) or bitStream.readInt8,
	write = raknetBitStreamWriteInt8 or bitStream.writeInt8
}

IO.int16 = {
	read = raknetBitStreamReadInt16 and (function(bs)
		local v = raknetBitStreamReadInt16(bs)
		return v >= 0x8000 and v - 0x10000 or v
	end) or bitStream.readInt16,
	write = raknetBitStreamWriteInt16 or bitStream.writeInt16
}

IO.int32 = {
	read = raknetBitStreamReadInt32 or bitStream.readInt32,
	write = raknetBitStreamWriteInt32 or bitStream.writeInt32
}

IO.float = {
	read = raknetBitStreamReadFloat or bitStream.readFloat,
	write = raknetBitStreamWriteFloat or bitStream.writeFloat
}

IO.string8 = {
	read = function(bs)
		local len = IO.uint8.read(bs)
		if len <= 0 then return "" end
		return IO.string.read(bs, len)
	end,
	write = function(bs, value)
		IO.uint8.write(bs, #value)
		IO.string.write(bs, value)
	end
}

IO.string16 = {
	read = function(bs)
		local len = IO.uint16.read(bs)
		if len <= 0 then return "" end
		return IO.string.read(bs, len)
	end,
	write = function(bs, value)
		IO.uint16.write(bs, #value)
		IO.string.write(bs, value)
	end
}

IO.string32 = {
	read = function(bs)
		local len = IO.uint32.read(bs)
		if len <= 0 then return "" end
		return IO.string.read(bs, len)
	end,
	write = function(bs, value)
		IO.uint32.write(bs, #value)
		IO.string.write(bs, value)
	end
}

IO.bool8 = {
	read = function(bs)
		return IO.uint8.read(bs) ~= 0
	end,
	write = function(bs, value)
		IO.uint8.write(bs, value == true and 1 or 0)
	end
}

IO.bool32 = {
	read = function(bs)
		return IO.uint32.read(bs) ~= 0
	end,
	write = function(bs, value)
		IO.uint32.write(bs, value == true and 1 or 0)
	end
}

IO.int1 = {
	read = function(bs)
		return IO.bool.read(bs) and 1 or 0
	end,
	write = function(bs, value)
		IO.bool.write(bs, value ~= 0 and true or false)
	end
}

IO.vector3d = {
	read = function(bs)
		local x, y, z = IO.float.read(bs), IO.float.read(bs), IO.float.read(bs)
		return vector3d(x, y, z)
	end,
	write = function(bs, value)
		IO.float.write(bs, value.x)
		IO.float.write(bs, value.y)
		IO.float.write(bs, value.z)
	end
}

IO.vector2d = {
	read = function(bs)
		return {
			x = IO.float.read(bs),
			y = IO.float.read(bs)
		}
	end,
	write = function(bs, value)
		IO.float.write(bs, value.x)
		IO.float.write(bs, value.y)
	end
}

-- extra types
IO.encodedString = (function()
	local this = {}
	local meta = {}

	this.read = raknetBitStreamDecodeString or bitStream.readEncoded
	this.write = raknetBitStreamEncodeString or bitStream.writeEncoded

	function meta:__index(size)
		return {
			read = function(bs) return this.read(bs, size) end,
			write = this.write
		}
	end

	return setmetatable(this, meta)
end)()

IO.string = (function()
	local this = {}
	local meta = {}

	this.read = raknetBitStreamReadString or bitStream.readString
	this.write = raknetBitStreamWriteString or bitStream.writeString

	function meta:__index(size)
		return {
			read = function(bs) return this.read(bs, size) end,
			write = this.write
		}
	end

	return setmetatable(this, meta)
end)()

IO.byteArray = (function()
	local this = {}
	local meta = {}

	function this.read(bs, size)
		local t = {}
		for i = 1, size do
			t[i] = IO.uint8.read(bs)
		end
		return t
	end

	function this.write(bs, value)
		for i, v in ipairs(value) do
			IO.uint8.write(bs, v)
		end
	end

	function meta:__index(size)
		return {
			read = function(bs)
				local t = {}
				for i = 1, size do
					t[i] = IO.uint8.read(bs)
				end
				return t
			end,
			write = this.write
		}
	end

	return setmetatable(this, meta)
end)()

IO.maybeEncoded = (function()
	local this = {}

	function this.read(bs)
		local length = IO.uint16.read(bs)
		local encoded = IO.uint8.read(bs)
		return (encoded == 0) and IO.string.read(bs, length) or IO.encodedString.read(bs, length + 1)
	end

	function this.write(bs, str)
		IO.uint16.write(bs, #str)
		IO.uint8.write(bs, 0)
		IO.string.write(bs, str)
	end

	return this
end)()

IO.stringUnread = (function()
	local this = {}

	function this.read(bs)
		local size = math.ceil(BitStream.getNumberOfUnreadBits(bs) / 8)
		return (size > 0) and IO.string.read(bs, size) or ""
	end

	function this.write(bs, value)
		IO.string.write(bs, value)
	end

	return this
end)()

IO.byteUnread = (function()
	local this = {}

	function this.read(bs)
		local data = {}
		local size = math.ceil(BitStream.getNumberOfUnreadBits(bs) / 8)
		for i = 1, size do
			data[i] = IO.uint8.read(bs)
		end
		return data
	end

	function this.write(bs, value)
		for i, v in ipairs(value) do
			IO.uint8.write(bs, v)
		end
	end

	return this
end)()

return BitStream