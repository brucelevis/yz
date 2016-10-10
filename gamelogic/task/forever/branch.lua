--支线任务
cbranchtask = class("cbranchtask",ctaskcontainer)

function cbranchtask:init(conf)
	ctaskcontainer.init(self,conf)
	self.canacceptnum = nil
end

function cbranchtask:onwarend(war,result)
	ctaskcontainer.onwarend(self,war,result)
	if not warmgr.iswin(result) then
		return
	end
	local player = playermgr.getplayer(self.pid)
	local chapterid = self:getformdata("task")[war.taskid].chapterid
	if chapterid then
		player.chapterdb:unlockchapter(chapterid)
		war.chapterid = chapterid
		player.chapterdb:onwarend(war,result)
	end
end

function cbranchtask:getcanaccept()
	local canaccept = {}
	for taskid,_ in pairs(self:getformdata("task")) do
		if not self.finishtasks[taskid] then
			local isok,msg = self:can_accept(taskid)
			if isok then
				table.insert(canaccept,{ taskkey = self.name, taskid = taskid })
			end
		end
	end
	return canaccept
end

function cbranchtask:can_directaccept(taskid)
	return true
end

function cbranchtask:onlogin(player)
	if cserver.isinnersrv() then
		local tmplist = table.keys(self.objs)
		table.extend(tmplist,table.keys(self.finishtasks))
		for _,taskid in ipairs(tmplist) do
			local chapterid = self:getformdata("task")[taskid].chapterid
			if chapterid then
				player.chapterdb:unlockchapter(chapterid)
			end
		end
	end
	ctaskcontainer.onlogin(self,player)
end

function cbranchtask:directaccept(taskid)
	local isaccept = ctaskcontainer.directaccept(self,taskid)
	if isaccept then
		local taskname = self:getformdata("task")[taskid].name
		net.msg.S2C.notify(self.pid,language.format("接受【{1}】",taskname))
	end
	return isaccept
end

function cbranchtask:finishtask(task,reason)
	ctaskcontainer.finishtask(self,task,reasosn)
	local player = playermgr.getplayer(self.pid)
	local members = player:getfighters()
	for _,pid in ipairs(members) do
		if pid ~= self.pid then
			local member = playermgr.getplayer(pid)
			local task2 = member.taskdb:gettask(task.taskid)
			if task2 then
				ctaskcontainer.finishtask(member.taskdb.branch,task2,reason)
			end
		end
	end
end

return cbranchtask
