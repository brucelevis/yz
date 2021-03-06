--转职任务
--该任务暂时废弃
czhuanzhitask = class("czhuanzhitask",ctaskcontainer)

function czhuanzhitask:init(conf)
	ctaskcontainer.init(self,conf)
end

local ZhuanzhiJobid = {
	[104001] = 10007,
	[104002] = 10002,
	[104003] = 10003,
	[104004] = 10004,
	[104005] = 10005,
}

function czhuanzhitask:can_accept(taskid)
	local player = playermgr.getplayer(self.pid)
	if player:teamstate() ~= NO_TEAM then
		return false,language.format("无法组队接受此任务")
	end
	if self.nowtaskid then
		return false,language.format("职业试玩任务或转职任务只能接受一个")
	end
	if not self.nowtaskid and self.lasttaskid and not (math.floor(taskid/100) == math.floor(self.lasttaskid/100)) then
		return false
	end
	return ctaskcontainer.can_accept(self,taskid)
end

function czhuanzhitask:nexttask(taskid,reason)
	if not reason or reason == "submittask" then
		local newtaskid = self:getformdata("task")[taskid].nexttask
		if not newtaskid or newtaskid == "nil" or newtaskid == 0 then
				self.lasttaskid = nil --测试用
				self.finishtasks = {} --测试用
				local player = playermgr.getplayer(self.pid)
				local zhiyintask = player.taskdb:gettaskcontainer(10500105)
				local task = zhiyintask:gettask(10500105)
				zhiyintask:finishtask(task,"zhuanzhi")
		else
			return tonumber(newtaskid)
		end
	end
end

function czhuanzhitask:can_execute(task)
	local isok,msg = ctaskcontainer.can_execute(self,task)
	if not isok then
		return false,msg
	end
	local player = playermgr.getplayer(self.pid)
	if player:teamstate() ~= NO_TEAM then
		return false,language.format("无法组队进行此任务")
	end
	return true
end

function czhuanzhitask:submittask(taskid)
	local player = playermgr.getplayer(self.pid)
	if player:teamstate() ~= NO_TEAM then
		net.msg.S2C.notify(self.pid,"无法组队提交此任务")
		net.task.S2C.finishtasks(self.pid,taskid,nil)
		return
	end
	ctaskcontainer.submittask(self,taskid)
end

function czhuanzhitask:giveuptask(taskid)
	local isok,errmsg = ctaskcontainer.giveuptask(self,taskid)
	if not isok then
		return false,errmsg
	end
	self.finishtasks = {}
	self.nowtaskid = nil
	self.lasttaskid = nil
	local player = playermgr.getplayer(self.pid)
	player.taskdb:update_canaccept()
	return true
end

function czhuanzhitask:opentask()
	return
end

function czhuanzhitask:can_directaccept(taskid)
	return true
end

function czhuanzhitask:taskdati(task,args)
	local datiinfo = task.resourcemgr:query("dati")
	local questionbank = self:getquestionbank()
	if not datiinfo then
		local mincorrect = args.mincorrect or 3
		local maxcnt = args.maxcnt or 3
		local jobtype = math.floor(task.taskid/100)
		local jobid = ZhuanzhiJobid[jobtype]
		if not jobid then
			return
		end
		local questions = self:getquestion(maxcnt,questionbank,jobid)
		datiinfo = {
			mincorrect = mincorrect,
			maxcnt = maxcnt,
			nowcnt = 1,
			correct = 0,
			questions = questions,
		}
		task.resourcemgr:set("dati",datiinfo)
	end
	local questionid = datiinfo.questions[datiinfo.nowcnt]
	local npc = self:getnpc_bynid(task,task.resourcemgr:query("findnpc"))
	if not npc then
		local player = playermgr.getplayer(self.pid)
		npc = { npcname = player.name, npcshape = 0, }
	end
	local callback = functor(function(taskid,player,result)
		local task = player.taskdb:gettask(taskid)
		if not task then
			return
		end
		local taskcontainer = player.taskdb:gettaskcontainer(taskid)
		if result == "closed" or result == "timeout" then
			task.execute_result = TASK_SCRIPT_FAIL
		else
			local datiinfo = task.resourcemgr:query("dati")
			datiinfo.nowcnt = datiinfo.nowcnt + 1
			if result == "yes" then
				datiinfo.correct = datiinfo.correct + 1
			end
			task.resourcemgr:set("dati",datiinfo)
			if datiinfo.nowcnt <= datiinfo.maxcnt then
				taskcontainer:taskdati(task)
			else
				if datiinfo.correct < datiinfo.mincorrect then
					task.resourcemgr:delete("dati")
					task.execute_result = TASK_SCRIPT_FAIL
					net.msg.S2C.notify(player.pid,language.format("答题失败"))
				else
					task.execute_result = TASK_SCRIPT_PASS
				end
			end
		end
		taskcontainer:check_result(task)
	end,task.taskid)
	local data = {
		questionid = questionid,
		npcaname = npc.name,
		npcshape = npc.shape,
		cnt = datiinfo.nowcnt,
		maxcnt = datiinfo.maxcnt,
		questionbank = questionbank,
	}
	if huodongmgr.playunit.dati.opendati(self.pid,callback,data) then
		task.execute_result = TASK_SCRIPT_SUSPEND
	else
		task.execute_result = TASK_SCRIPT_FAIL
	end
end

function czhuanzhitask:getquestion(maxnum,questionbank,jobid)
	local questions = {}
	local ids = {}
	local nownum = 1
	for id,data in pairs(data_1100_QuestionBank03) do
		if data.jobid == jobid then
			table.insert(ids,id)
		end
	end
	while nownum <= maxnum do
		local isok = true
		local n = math.random(1,#ids)
		if not next(questions) then
			questions[nownum] = ids[n]
			nownum = nownum + 1
		end
		for _,id in pairs(questions) do
			if id == ids[n] then
				isok = false
			end
		end
		if isok then
			questions[nownum] = ids[n]
			nownum = nownum + 1
		end
	end
	return questions
end

function czhuanzhitask:getcanaccept()
	return
	--[[
	local canaccept = {}
	for taskid,_ in pairs(self:getformdata("task")) do
		if not self.finishtasks[taskid] then
			local isok,msg = self:can_accept(taskid)
			if isok then
				table.insert(canaccept,{
					taskkey = self.name,
					taskid = taskid,
				})
			end
		end
	end
	return canaccept]]
end

function czhuanzhitask:getquestionbank()
	return "data_1100_QuestionBank03"
end

function czhuanzhitask:raisewar(task,args,pid)
	local isok = ctaskcontainer.raisewar(self,task,args,pid)
	self:log("debug","task",format("[zhuanzhiwar] pid=%d isok=%s taskid=%d args=%s",self.pid,isok,task.taskid,args))
	return isok
end

return czhuanzhitask
