local BitStream = require("arizona-events.bitstream")
local subprocess = require("arizona-events.subprocess")

local PACKET_ID_ARIZONA_CEF = 220
local PACKET_ID_ARIZONA_CEF_EX = 221

local module = {}
module.INTERFACE = {}
module.INTERFACE.BitStream = BitStream

local packet_io_t = (function()
	local this = {}

	local function pair_read(bs, pair)
		if pair[1].read then
			return pair[1].read(bs)
		else
			local t = {}
			for _, jpair in ipairs(pair[1]) do
				t[(jpair[2])] = pair_read(bs, jpair)
			end
			return t
		end
	end

	local function pair_write(bs, pair, packet)
		if pair[1].write then
			pair[1].write(bs, packet[(pair[2])])
		else
			for _, jpair in ipairs(pair[1]) do
				pair_write(bs, jpair, packet[(pair[2])])
			end
		end
	end

	function this:read(bs, packet)
		if self.sizeof == 0 then
			local size = math.ceil(BitStream.getNumberOfUnreadBits(bs) / 8)
			packet.bytes = {}
			for i = 1, size do
				packet.bytes[i] = BitStream.IO.uint8.read(bs)
			end
			BitStream.setReadOffset(bs, 8)
			packet.bs = bs
		else
			for _, pair in ipairs(self.struct) do
				packet[(pair[2])] = pair_read(bs, pair)
			end
		end
	end
 
	function this:write(bs, packet)
		if self.sizeof == 0 then
			for i, v in ipairs(packet.bytes) do
				BitStream.IO.uint8.write(bs, v)
			end
		else
			for _, pair in ipairs(self.struct) do
				pair_write(bs, pair, packet)
			end
		end
	end
	
	local function constructor(_, event, struct)
		local t = {}
		t.event = event
		t.struct = struct or {}
		t.sizeof = #t.struct
		return setmetatable(t, { __index = this })
	end

	return setmetatable(this, { __call = constructor })
end)()

local packet_pool = (function()
	local this = {}
	this.data = {}

	function this:push(id, event, base)
		self.data[event] = { id = id, base = base }
	end

	function this:get(event)
		return self.data[event]
	end

	return this
end)()

local function create_packet_handler(id, first_field, default_event)
	local this = {}
	local meta = {}
	setmetatable(this, meta)

	this.id = id
	this.first_field = first_field
	this.default_io = packet_io_t(default_event)

	function this.read(bs)
		local packet = {}
		packet.id = this.first_field.read(bs)
		local packet_io = this[packet.id] or this.default_io
		packet_io:read(bs, packet)
		return packet_io.event, { packet }
	end

	function this.write(bs, data)
		local packet = data[1]
		local packet_io = this[packet.id] or this.default_io
		this.first_field.write(bs, packet.id)
		packet_io:write(bs, packet)
	end

	function meta:__newindex(k, v)
		local packet_io
		if v.event then
			packet_io = v
		else
			local event = v[1]
			table.remove(v, 1)
			packet_io = packet_io_t(event, v)
		end
		rawset(self, k, packet_io)
		packet_pool:push(k, packet_io.event, this)
	end

	this[-1] = this.default_io

	return this
end

function module.emul(event, packet)
	local t = packet_pool:get(event)
	if t then
		packet.id = packet.id or t.id
		local bs = BitStream.new()
		t.base.write(bs, { packet })
		BitStream.emul(t.base.id, bs)
		BitStream.delete(bs)
	end
end

function module.send(event, packet)
	local t = packet_pool:get(event)
	if t then
		packet.id = packet.id or t.id
		local bs = BitStream.new()
		BitStream.IO.uint8.write(bs, t.base.id)
		t.base.write(bs, { packet })
		BitStream.send(bs)
		BitStream.delete(bs)
	end
end

function module.eval(code, server_id)
	local text = ("(() => {%s})();"):format(code)
	return module.emul("onArizonaDisplay", {
		server_id = server_id or 0,
		text = text
	})
end

function module.decode(packet, decoder)
	if packet.id ~= 17 then
		return false
	end
	local event, json = packet.text:match("^window.executeEvent%('(.-)', .(.+).%);$")
	local result, tbl = pcall(decoder or decodeJson, json)
	if not result then
		return false
	end
	packet.json = tbl
	packet.event = event
	return true
end

function module.encode(packet, encoder)
	if packet.id ~= 17 then
		return false
	end
	local result, json = pcall(encoder or encodeJson, packet.json)
	if not result then
		return false
	end
	packet.text = ("window.executeEvent('%s', `%s`);"):format(packet.event, json:gsub("%s+", " "))
	return true
end

module.INTERFACE.INCOMING = create_packet_handler(PACKET_ID_ARIZONA_CEF, BitStream.IO.uint8, "onArizonaAnyIn")
module.INTERFACE.OUTGOING = create_packet_handler(PACKET_ID_ARIZONA_CEF, BitStream.IO.uint8, "onArizonaAnyOut")
module.INTERFACE.INCOMING_EX = create_packet_handler(PACKET_ID_ARIZONA_CEF_EX, BitStream.IO.uint16, "onArizonaAnyInEx")
module.INTERFACE.OUTGOING_EX = create_packet_handler(PACKET_ID_ARIZONA_CEF_EX, BitStream.IO.uint16, "onArizonaAnyOutEx")

local handlers = {
	INCOMING = {
		[PACKET_ID_ARIZONA_CEF] = module.INTERFACE.INCOMING,
		[PACKET_ID_ARIZONA_CEF_EX] = module.INTERFACE.INCOMING_EX
	},
	OUTGOING = {
		[PACKET_ID_ARIZONA_CEF] = module.INTERFACE.OUTGOING,
		[PACKET_ID_ARIZONA_CEF_EX] = module.INTERFACE.OUTGOING_EX
	}
}

local function process_packet(id, bs, handlers)
	local handler = handlers[id]
	if handler then
		BitStream.ignoreBits(bs, 8)
		local event, data = handler.read(bs)
		if module[event] then
			local result = module[event](data[1])
			if result == false then
				return false
			elseif type(result) == "table" then
				if id == 220 and result[1].id == 17 then
					subprocess.push(id, result, handler.write)
				else
					BitStream.setWriteOffset(bs, 8)
					handler.write(bs, result)
				end
			end
		end
	end
end

local add_handler = addEventHandler or registerHandler

add_handler("onReceivePacket", function(id, bs)
	return process_packet(id, bs, handlers.INCOMING)
end)

add_handler("onSendPacket", function(id, bs)
	return process_packet(id, bs, handlers.OUTGOING)
end)

return module