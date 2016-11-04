-- 所有签到的容器
csignindb = class("csignindb")

function csignindb:init(pid)
	self.pid = pid
	self.name_signin = {}
	for name,data in pairs(data_1100_SignInCtrl) do
		local cls = self:getclass(data.classname)
		local signin = cls.new({
			pid = self.pid,
			name = name,
			starttime = os.time(data.starttime),
			endtime = os.time(data.endtime),
			datatable = data.datatable,
		})
		self:add(signin)
	end
end

function csignindb:load(data)
	if table.isempty(data) then
		return
	end
	for name,signin_data in pairs(data.name_signin) do
		local signin = self:get(name)
		if signin then
			signin:load(signin_data)
		end
	end
end

function csignindb:save()
	local data = {}
	local name_signin = {}
	for name in pairs(self.name_signin) do
		local signin = self:get(name)
		name_signin[name] = signin:save()
	end
	data.name_signin = name_signin
	return data
end

function csignindb:onlogin(player)
	for name in pairs(self.name_signin) do
		local signin = self:get(name)
		if signin.onlogin then
			signin:onlogin(player)
		end
	end
end

function csignindb:onlogoff(player)
	for name in pairs(self.name_signin) do
		local signin = self:get(name)
		if signin.onlogoff then
			signin:onlogoff(player)
		end
	end
end

-- 增加一个签到实例
function csignindb:add(signin)
	local name = assert(signin.name)
	assert(self.name_signin[name] == nil)
	self.name_signin[name] = true
	self[name] = signin
end

function csignindb:get(name)
	return self[name]
end

function csignindb:getclass(classname)
	return _G[classname]
end

return csignindb
