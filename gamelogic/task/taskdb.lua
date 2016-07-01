require "gamelogic.task.auxilary"
require "gamelogic.task.taskcontainer"

ctaskdb = class("ctaskdb")

function ctaskdb:init(pid)
	self.pid = pid
	self.loadstate = "unload"
	self.taskcontainers = {}
	for templateid,data in pairs(g_alltaskdata) do
		local formdata,tasktype = data[1],data[2]
		local taskcontainer = ctaskcontainer.new({
			name = TASK_TYPE_NAME[tasktype],
			pid = pid,
			formdata = formdata,
			templateid = templateid,
			type = tasktype,
		})
		self:addtaskcontainer(taskcontainer)
	end
end

function ctaskdb:load(data)
	if not data or not next(data) then
		return
	end
	for name,_ in pairs(self.taskcontainers) do
		local taskcontainer = self:gettaskcontainer(name)
		taskcontainer:load(data[name])
	end
end

function ctaskdb:save()
	local data = {}
	for name,_ in pairs(self.taskcontainers) do
		local taskcontainer = self:gettaskcontainer(name)
		data[name] = taskcontainer:save()
	end
	return data
end

function ctaskdb:clear()
	for name,_ in pairs(self.taskcontainers) do
		local taskcontainer = self:gettaskcontainer(name)
		taskcontainer:clear()
	end
end

function ctaskdb:addtaskcontainer(taskcontainer)
	local name = assert(taskcontainer.name)
	assert(self.taskcontainers[name] == nil)
	self.taskcontainers[name] = true
	self[name] = taskcontainer
end

function ctaskdb:gettaskcontainer(name)
	assert(self.taskcontainers[name] ~= nil)
	return self[name]
end

function ctaskdb:gettaskcontainer_bytaskid(taskid)
	local _,name = auxilary.tasktypename(taskid)
	return self:gettaskcontainer(name)
end

function ctaskdb:gettask(taskid)
	local taskcontainer = self:gettaskcontainer_bytaskid(taskid)
	local task = taskcontainer:gettask(taskid)
	return task
end

function ctaskdb:oncreate(player)
	for name,_ in pairs(self.taskcontainers) do
		local taskcontainer = self:gettaskcontainer(name)
		if taskcontainer.oncreate then
			taskcontainer:oncreate(player)
		end
	end
end

function ctaskdb:onlogin(player)
	for name,_ in pairs(self.taskcontainers) do
		local taskcontainer = self:gettaskcontainer(name)
		taskcontainer:onlogin(player)
	end
end

function ctaskdb:onlogoff(player)
	for name,_ in pairs(self.taskcontainers) do
		local taskcontainer = self:gettaskcontainer(name)
		taskcontainer:onlogoff(player)
	end
end

function ctaskdb:onchangelv(oldlv,newlv)

end

-- 物品(itemtype)增加数量(num)
function ctaskdb:onadditem(itemtype,num)
end

-- 物品(itemtype)减少数量(num)
function ctaskdb:ondelitem(itemtype,num)
end

function ctaskdb:onaddpet(pettype,num)
end

function ctaskdb:ondelpet(pettype,num)
end

function ctaskdb:onfivehourupdate()
	local player = playermgr.getplayer(self.pid)
	for name,_ in pairs(self.taskcontainers) do
		local taskcontainer = self:gettaskcontainer(name)
		if taskcontainer.onfivehourupdate then
			taskcontainer:onfivehourupdate(player)
		end
	end
end

return ctaskdb
