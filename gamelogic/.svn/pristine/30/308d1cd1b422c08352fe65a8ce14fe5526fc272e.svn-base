
local DEFAULT_SWICH = {
	gm = false,
	friend = true,
	automatch = true,
}

cswitch = class("cswitch",cbasicattr)

function cswitch:init(conf)
	cbasicattr.init(self,conf)
end

function cswitch:isopen(switchtype)
	if DEFAULT_SWICH[switchtype] == nil then
		return false
	end
	local result = self:get(switchtype,DEFAULT_SWICH[switchtype])
	return result
end

function cswitch:setswitch(switchtype,state)
	if DEFAULT_SWICH[switchtype] == nil then
		return
	end
	self:set(switchtype,state)
end

function cswitch:allswitch()
	local data = {}
	for k,v in pairs(DEFAULT_SWICH) do
		data[k] = self:isopen(k)
	end
	return data
end

