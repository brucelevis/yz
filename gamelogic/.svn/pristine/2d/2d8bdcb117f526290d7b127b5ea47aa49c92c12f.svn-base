-- 开关设置
cswitch = class("cswitch",cbasicattr)

function cswitch:init(conf)
	cbasicattr.init(self,conf)
end

function cswitch:onlogin(player)
	net.player.S2C.switch(self.pid,self:allswitch())
end

function cswitch:isopen(flag)
	local isopen = self:query(flag)
	if state == nil then
		for _,switch in pairs(data_1601_Switch) do
			if switch.flag == flag then
				isopen = switch.default == 1 and true or false
				break
			end
		end
	end
	return isopen
end

function cswitch:setswitch(switchs)
	for _,switch in ipairs(switchs) do
		if data_1601_Switch[switch.id] then
			local flag = data_1601_Switch[switch.id].flag
			self:set(flag,switch.state)
		end
	end
	net.player.S2C.switch(self.pid,switchs)
end

function cswitch:allswitch()
	local data = {}
	for id,switch in pairs(data_1601_Switch) do
		local state = self:isopen(switch.flag)
		table.insert(data,{ id = id, state = state })
	end
	return data
end

