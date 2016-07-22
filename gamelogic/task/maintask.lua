--主线任务
cmaintask = class("cmaintask",ctaskcontainer)

function cmaintask:init(conf)
	ctaskcontainer.init(self,conf)
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
	ctaskcontainer.addtask(self,war,result)
	local player = playermgr:getplayer(self.pid)
	local chapterid = self:getformdata("task")[war.taskid].chapterid
	if chapterid then
		player.chapterdb:onwarend(war,result)
	end
end

return cmaintask
