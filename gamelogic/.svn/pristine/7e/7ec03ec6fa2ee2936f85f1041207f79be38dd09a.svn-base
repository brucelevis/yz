
local DEFAULT_SWICH = {
	gm = skynet.getenv("servermode") == "DEBUG" and true or false,
	friend = false,
	automatch = true,
	costdexp = true,		-- 默认开启:消耗双倍点
}

cswitch = class("cswitch",cbasicattr)

function cswitch:init(conf)
	cbasicattr.init(self,conf)
end

function cswitch:onlogin(player)
	local pid = player.pid
	sendpackage(pid,"player","switch",self:allswitch())
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
	sendpackage(self.pid,"player","switch",{
		[switchtype] = state,
	})
end

function cswitch:allswitch()
	local data = {}
	for k,v in pairs(DEFAULT_SWICH) do
		data[k] = self:isopen(k)
	end
	return data
end

