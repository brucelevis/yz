--主线任务
cmaintask = class("cmaintask",ctaskcontainer)

function cmaintask:init(conf)
	ctaskcontainer.init(self,conf)
	self.firstlogin = true
end

function cmaintask:save()
	local data = ctaskcontainer.save(self)
	data.firstlogin = self.firstlogin
	return data
end

function cmaintask:load(data)
	if table.isempty(data) then
		return
	end
	ctaskcontainer.load(self,data)
	self.firstlogin = data.firstlogin
end

function cmaintask:addtask(task)
	ctaskcontainer.addtask(self,task)
	local player = playermgr.getplayer(self.pid)
	local chapterid = self:getformdata("task")[task.taskid].chapterid
	if chapterid then
		player.chapterdb:unlockchapter(chapterid)
	end
end

function cmaintask:onwarend(war,result)
	ctaskcontainer.onwarend(self,war,result)
	local player = playermgr.getplayer(self.pid)
	local chapterid = self:getformdata("task")[war.taskid].chapterid
	if chapterid then
		war.chapterid = chapterid
		player.chapterdb:onwarend(war,result)
	end
end

function cmaintask:onlogin(player)
	if self.firstlogin then
		self:accepttask(10000101)
		self.firstlogin = false
	end
	ctaskcontainer.onlogin(self,player)
end

return cmaintask
