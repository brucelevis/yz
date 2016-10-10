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
	else
		self:autoaccept()
	end
	ctaskcontainer.onlogin(self,player)
end

--若达到条件则自动接受任务
function czhiyintask:autoaccept()
	local player = playermgr.getplayer(self.pid)
	if player.lv == 1 then
		return
	end
	for taskid,_ in pairs(self:getformdata("task")) do
		if not self.finishtasks[taskid] then
			local isok,msg = self:can_accept(taskid)
			if isok then
				self:accepttask(taskid)
				return
			end
		end
	end
	return
end

function czhiyintask:onchangejob(job)
	if job ~= 10001 then
		return
	end
	local changejobtaskid = self:getformdata("var").FinishTaskInChangeJob
	local task = self:gettask(changejobtaskid)
	if not task then
		return
	end
	self:finishtask(task,"changejob")
end

return czhiyintask
