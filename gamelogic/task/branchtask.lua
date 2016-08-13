--支线任务
cbranchtask = class("cbranchtask",ctaskcontainer)

function cbranchtask:init(conf)
	ctaskcontainer.init(self,conf)
end

function cbranchtask:addtask(task)
	ctaskcontainer.addtask(self,task)
	local player = playermgr.getplayer(self.pid)
	local chapterid = self:getformdata("task")[task.taskid].chapterid
	if chapterid then
		player.chapterdb:unlockchapter(chapterid)
	end
end

function cbranchtask:onwarend(war,result)
	ctaskcontainer.onwarend(self,war,result)
	local player = playermgr.getplayer(self.pid)
	local chapterid = self:getformdata("task")[war.taskid].chapterid
	if chapterid then
		war.chapterid = chapterid
		player.chapterdb:onwarend(war,result)
	end
end

return cbranchtask
