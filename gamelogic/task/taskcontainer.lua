require "gamelogic.base.container"

ctaskcontainer = class("ctaskcontainer",ccontainer,ctemplate)

function ctaskcontainer:init(conf)
	cid
	ccontainer.init(self,conf)
	ctemplate.init(self,conf)
	self.finishtasks = {}
	self.nowtaskid = nil  -- 仅对同时只有一个任务的任务类有效
	self.scirpt_handle.find = self.findnpc
	self.script_handle.item = self.needitem
	self.script_handle.patrol = self.setpatrol
	self.script_handle.progress = self.progressbar
	self.script_handle.handin = self.handinitem
	self.script_handle.done = self.taskdone
end

function ctaskcontainer:load(data)
	if not data or not next(data) then
		return
	end
	ccontainer.load(self,data,function(objdata)
		local taskid = objdata.taskid
		local task = __new({taskid = taskid})
		if not task then
			self:log("info","task",string.format("[load unknow task] pid=%s taskid=%s",self.pid,taskid))
			return nil
		end
		task.load(objdata)
		self:loadres(task,objdata)
		return task
	end)
	self.nowtaskid = data.nowtaskid
	local finishtasks = data.finishtasks or {}
	for i,taskid in ipairs(finishtasks) do
		self.finishtasks[taskid] = true
	end
end

function ctaskcontainer:save()
	local data = ccontainer.save(function(obj)
		local data = obj.save()
		self:saveres(obj,data)
		return data
	end)
	data.nowtaskid = self.nowtaskid
	data.finishtasks = table.values(self.finishtasks)
	return data
end

function ctaskcontainer:clear()
	self:log("info","task",string.format("clear,pid=%s",self.pid))
	ccontainer.clear(self)
	-- 累积完成任务又使用者决定是否清空
	--self.finishtasks = {}
end

function ctaskcontainer:log(levelmode,filename,...)
	levelmode = string.upper(levelmode)
	local msg = table.concat({...},"\t")
	msg = string.format("[%s] [name=%s] %s",levelmode,self.name,msg)
	logger.log(filename,msg)
end

function ctaskcontainer:onlogin(player)
end

function ctaskcontainer:onlogoff(player)
end

function ctaskcontainer:onclear(tasks)
	for _,task in pairs(tasks) do
		self.release(task)
		net.task.S2C.deltask(task)
	end
end

function ctaskcontainer:ondel(task)
	self.release(task)
	net.task.S2C.deltask(task)
end

function ctaskcontainer:onadd(task)
	net.task.S2C.addtask(task)
end

function ctemplate:findnpc(task,arg,pid,npc)
	local nid = arg
	local findnpc = plaunit.resourcemgr:get("findnpc",{})
	table.insert(findnpc,nid)
	task.resourcemgr:set("findnpc",findnpc)
end

function ctemplate:needitem(task,arg,pid,npc)
	local itemtype = arg.type
	local itemnum = arg.num
	local itemneed = task.resourcemgr:get("itemneed",{})
	if not itemneed[itemtype] then
		itemneed[itemtype] = 0
	end
	itemneed[itemtype] = itemneed[itemtype] + 1
	task.resourcemgr:set("itemneed",itemneed)
end

function ctemplate:patrolwar(task,arg,pid,npc)
end

function ctemplate:progressbar(task,arg,pid,npc)
end

function ctemplate:handinitem(task,arg,pid,npc)
end

function ctemplate:taskdone(task,arg,pid,npc)
	local donescript = self.formdata.taskinf[taskid]
	self:deltask(taskid,"submit")
	self:addfinishtask(taskid)
	local taskdata = self.formdata.taskinfo[taskid]
	if istrue(taskdata.autoaccept) then
		local nexttask = self:nexttask(taskid)
		if nexttask then
			if self:can_accepttask(nexttask.taskid) then
				self:accepttask(nexttask)
			end
		end
	end
end

function ctemplate:onwarwin(task,pid)
end

function ctemplate:onwarfail(task,pid)
end

function ctaskcontainer:gettask(taskid,nocheckvalid)
	local task = self:get(taskid)
	if task then
		if not nocheckvalid then
			if task.exceedtime then
				local now = os.time()
				if now >= task.exceedtime then
					self:deltask(taskid,"timeout")
					return
				end
			end
		end
	end
	return task
end

function ctaskcontainer:__newtask(conf)
	local taskid = assert(conf.taskid)
	local taskdata = self.formdata.taskinfo[taskid]
	if taskdata then
		conf.state = TASK_STATE_ACCEPT
		conf.type = taskdata.type
		if taskdata.exceedtime then
			if taskdata.exceedtime == "today" then
				conf.exceedtime = getdayzerotime() + DAY_SECS + 5 * HOUR_SECS
			elseif taskdata.exceedtime == "thisweek" then
				conf.exceedtime = getweekzerotime() + DAY_SECS * 7 + 5 * HOUR_SECS
			elseif taskdata.exceedtime == "thisweek2" then
				conf.exceedtime = getweek2zerotime() + DAY_SECS * 7 + 5 * HOUR_SECS
			elseif taskdata.exceedtime == "thismonth" then
				local now = os.time()
				conf.exceedtime = os.time({year=getyear(now),month=getyearmonth(now)+1,day=1,hour=5,min=0,sec=0,})
			elseif taskdata.exceedtime == "forever" then
			else
				local secs = assert(tonumber(taskdata.exceedtime))
				secs = math.floor(secs)
				conf.exceedtime = os.time() + secs
			end
		end
		local task =  ctask.new(conf)
		self:loadres(task,nil)
		return task
	end
end

function ctaskcontainer:addtask(task)
	local taskid = task.taskid
	assert(self:get(taskid) == nil,"Repeat taskid:" .. tostring(taskid))
	self:log("info","task",string.format("addtask,pid=%d taskid=%d",self.pid,taskid))
	self:add(task,taskid)
	self.nowtaskid = taskid
end

function ctaskcontainer:deltask(taskid,reason)
	local task = self:get(taskid)
	if task then
		self:log("info","task",string.format("deltask,pid=%d taskid=%d reason=%s",self.pid,taskid,reason))
		self:del(taskid)
		self.nowtaskid = nil  -- nowtaskid只对同时只有一个任务的任务类有效
		return task
	end
end

function ctaskcontainer:updatetask(task,key,val)
	task:set(key,val)
	if self.onupdatetask then
		self:onupdatetask(task,key,val)
	end
end

function ctaskcontainer:finishtask(taskid)
	self:log("info","task",string.format("finishtask,pid=%d taskid=%d",self.pid,taskid))
	local task = self:gettask(taskid)
	-- 完成任务时，任务可能已失效，如：战斗结束后完成任务，此时可能已不存在，这时仍然需要提交奖励任务
	if task then  
		self:updatetask(task,"state",TASK_STATE_FINISH)
	end
	local taskdata = self.formdata.taskifno[taskid]
	if istrue(taskdata.autosubmit) then
		-- 无需判断是否可以提交，任务可能已经失效，调用者调用了finishtask,就必须知道可能会“无条件”提交的行为！
		self:submittask(taskid)
	end
	return task
end

-- 可重写,默认不记录“历史已完成任务”
function ctaskcontainer:addfinishtask(taskid)
	self.finishtasks[taskid] = true
end

function ctaskcontainer:submittask(taskid,args)
	local submitscript = self.formdata.taskinfo[taskid].submit
	local task = self:gettask(taskid)
	self:execscript(task,submitscript,self.pid,args)
end

function ctaskcontainer:accepttask(taskid)
	local task = self:__newtask({taskid = taskid})
	if task then
		self:addtask(task)
		local acceptscript = self.formdata.taskinfo[taskid].accept
		self.execscript(task,acceptscript,self.pid)
	end
end

function ctaskcontainer:giveuptask(taskid)
	local task = self:gettask(taskid)
	if task then
		self:deltask(taskid,"giveup")
		return task
	end
end

function ctaskcontainer:can_accepttask(taskid)
	local player = playermgr.getplayer(self.pid)
	if not player then
		return false
	end
	local taskdata = self.formdata.taskinfo[taskid]
	local isok = true
	if taskdata.pretask and next(taskdata.pretask) then
		for i,taskid in ipairs(taskdata.pretask) do
			if not self.finishtasks[taskid] then
				isok = false
			end
		end
	end
	if not isok then
		return false,string.format("前置任务未完成")
	end
	return true
end

function ctaskcontainer:can_submittask(taskid)
	local task = self:gettask(taskid)
	if not task then
		return false,"任务已失效"
	end
	if task.state ~= TASK_STATE_FINISH then
		return false,"任务未完成"
	end
	return true
end

function ctaskcontainer:can_giveuptask(taskid)
	local taskdata = self.formdata.taskinfo[taskid]
	if not istrue(taskdata.cangiveup) then
		return false,"该任务无法放弃"
	end
	return true
end

function ctaskcontainer:can_clientfinish(taskid)
	local taskdata = self.formdata.taskinfo[taskid]
	if taskdata.finishbyclient ~= 1 then
		return false
	end
	return true
end

return ctaskcontainer
