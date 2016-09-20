-- 开关设置
cswitch = class("cswitch",cbasicattr)

function cswitch:init(conf)
	cbasicattr.init(self,conf)
end

function cswitch:onlogin(player)
	net.player.S2C.switch(self.pid,self:allswitch())
end

function cswitch:isopen(flag)
	local player = playermgr.getplayer(self.pid)
	if flag == "gm" then
		return  player:isgm()
	elseif flag == "friend" then
		return globalmgr.server:isopen(flag)
	end
	local isopen = self:query(flag)
	if isopen == nil then
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
	local valid_switchs = {}
	for _,switch in ipairs(switchs) do
		local data = data_1601_Switch[switch.id]
		if data and data.setbyclient == 1 then
			local flag = data.flag
			self:set(flag,switch.state)
			table.insert(valid_switchs,switch)
		end
	end
	local changelst = {}
	for _,switch in ipairs(valid_switchs) do
		if self:domutex(switch,changelst) then
			table.insert(changelst,switch)
		end
	end
	net.player.S2C.switch(self.pid,changelst)
end

--互斥开关
function cswitch:domutex(switch,changelst)
	local data = data_1601_Switch[switch.id]
	if table.isempty(data.mutex) then
		return true
	end
	--关闭其他互斥开关
	if switch.state then
		for _,id in ipairs(data.mutex) do
			if id ~= switch.id then
				local flag = data_1601_Switch[id].flag
				if self:isopen(flag) == true then
					self:set(flag,false)
					table.insert(changelst,{ id = id, state = false })
				end
			end
		end
		return true
	end
	--关闭唯一开启的，则恢复默认
	for _,id in ipairs(data.mutex) do
		local flag = data_1601_Switch[id].flag
		self:delete(flag)
		table.insert(changelst,{ id = id, state = self:isopen(flag) })
	end
	return false
end

function cswitch:allswitch()
	local data = {}
	for id,switch in pairs(data_1601_Switch) do
		local state = self:isopen(switch.flag)
		table.insert(data,{ id = id, state = state })
	end
	return data
end

