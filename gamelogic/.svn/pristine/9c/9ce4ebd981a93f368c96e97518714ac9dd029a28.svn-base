--指引任务
czhiyintask = class("czhiyintask",ctaskcontainer)

function czhiyintask:init(conf)
	ctaskcontainer.init(self,conf)
end


function czhiyintask:onlogin(player)
	if player:query("logincnt") == 1 then
		local taskid = self:getformdata("var").FirstDefaultTask
		if self:can_accept(taskid) then
			self:accepttask(taskid)
		end
	end
	ctaskcontainer.onlogin(self,player)
end

function czhiyintask:choosetask(newtaskid,taskid)
	if newtaskid == "zhuxian" then
		local player = playermgr.getplayer(self.pid)
		local zhuxiantask = 10000101
		local isok,msg = player.taskdb.main:can_accept(zhuxiantask)
		print(msg)
		if player.taskdb.main:can_accept(zhuxiantask) then
			player.taskdb.main:accepttask(zhuxiantask)
		end
		return
	end
	return ctaskcontainer.choosetask(self,newtaskid,taskid)
end

function czhiyintask:getcanaccept()
	return
end

return czhiyintask
