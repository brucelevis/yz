--主线任务
cmaintask = class("cmaintask",ctaskcontainer)

function cmaintask:init(conf)
	ctaskcontainer.init(self,conf)
	self.is_teamfinish = true
	self.is_teamsubmit = true
end

function cmaintask:onwarend(war,result)
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

function cmaintask:onlogin(player)
	if cserver.isinnersrv() then
		local tmplist = table.keys(self.objs)
		table.extend(tmplist,table.keys(self.finishtasks))
		for _,taskid in ipairs(tmplist) do
			local taskdata = self:getformdata("task")[taskid]
			if taskdata and istrue(taskdata.chapterid) then
				player.chapterdb:unlockchapter(taskdata.chapterid)
			end
		end
	end
	ctaskcontainer.onlogin(self,player)
end

function cmaintask:getcanaccept()
	return
end

function cmaintask:onchangelv()
	for taskid,_ in pairs(self:getformdata("task")) do
		if not self.finishtasks[taskid] then
			if self:can_accept(taskid) then
				self:accepttask(taskid)
				return
			end
		end
	end
end

return cmaintask
