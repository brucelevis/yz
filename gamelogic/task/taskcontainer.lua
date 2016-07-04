require "gamelogic.base.container"

ctaskcontainer = class("ctaskcontainer",ccontainer,ctemplate)

function ctaskcontainer:init(conf)
	ccontainer.init(self,conf)
	ctemplate.init(self,conf)
	self.finishtasks = {}
	self.nowtaskid = nil  -- 仅对同时只有一个任务的任务类有效
	--脚本注册
	self.scirpt_handle.find = self.findnpc
	self.script_handle.verify = self.verifynpc
	self.script_handle.item = self.needitem
	self.script_handle.patrol = self.setpatrol
	self.script_handle.progress = self.progressbar
	self.script_handle.handin = self.handinitem
	self.script_handle.finish = self.finishtask
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
	net.task.S2C.alltask(self.pid,self.objs)
end

function ctaskcontainer:onlogoff(player)
end

function ctaskcontainer:onclear(tasks)
	for _,task in pairs(tasks) do
		self:ondel(task)
	end
end

function ctaskcontainer:ondel(task)
	self:release(task)
	net.task.S2C.deltask(self.pid,task.taskid)
end

function ctaskcontainer:onadd(task)
	net.task.S2C.addtask(self.pid,task)
end

function ctaskcontainer:onwarend(warid,result)
	local wardata = getwarinfo(warid)
	local taskid  = assert(wardata.info.taskid)
	local npcid = assert(wardata.info.npcid)
	local task =self:gettask(taskid)
	if task then
		self:setcurrentnpc(task,npcid)
		if WAR_IS_WIN(result) then
			self:finishtask(task)
		else
			self:failtask(task)
		end
	end
end

--内部接口
function ctaskcontainer:gettask(taskid,nocheckvalid)
	--任务超时的机制看是否改下，接触与get的耦合
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

function ctaskcontainer:nexttask(taskid)
end

function ctaskcontainer:addfinishtask(taskid)
	self.finishtasks[taskid] = true
end

function ctaskcontainer:failtask(task)
	local failscript = self.formdata.taskinfo[taskid].fail
	self:execscript(task,failscript,self.pid)
end


--脚本接口
function ctaskcontainer:findnpc(task,arg)
	local nid = arg
	task.resourcemgr:set("findnpc",nid)
end

function ctaskcontainer:verifynpc(task,arg,pid,npc)
	local findnpc = task.resourcemgr:get("findnpc")
	if findnpc ~= npc.nid then
		return TASK_SCRIPT_SUSPEND
	end
end

function ctaskcontainer:needitem(task,arg)
	local itemtype = arg.type
	local itemnum = arg.num
	local itemneed = task.resourcemgr:get("itemneed",{})
	if not itemneed[itemtype] then
		itemneed[itemtype] = 0
	end
	itemneed[itemtype] = itemneed[itemtype] + itemnum
	task.resourcemgr:set("itemneed",itemneed)
end

function ctaskcontainer:handinitem(task,arg,pid,npc,ext)
	local iteminfo = self.formdata.taskinfo[task.taskid]
	local player = playermgr.getplayer(self.pid)
	local itemneed = task.resourcemgr:get("itemneed")
	if not itemneed then
		return
	end
	if iteminfo.autohandin ~= 1 then
		if not ext then
			return TASK_SCRIPT_SUSPEND
		end
		local type_num = {}
		for _,value in ipairs(ext) do
			local itemid = value.itemid
			local num = value.num
			local itemobj = player.itemdb:getitemobj(itemid)
			if not itemobj or itemobj.num <= num then
				return TASK_SCRIPT_SUSPEND
			end
			if not itemneed[itemobj.type] then
				if npc then
					npc:say(self.pid,language.format("%s不是需求的物品",itemobj.name))
				end
				return TASK_SCRIPT_SUSPEND
			end
			type_num[itemobj.type] = (type_num[itenobj.type] or 0) + num
		end
		for type,num in pairs(itemneed) do
			if not type_num[type] or type_num[type] < num then
				if npc then
					npc:say(self.pid,"物品数量不足")
				end
				return TASK_SCRIPT_SUSPEND
			end
		end
		self:truehandin(player,ext)
	else
		local handinlst = self:autohandin(player,itemneed)
		if not handinlst then
			return TASK_SCRIPT_SUSPEND
		end
		self:truehandin(player,handinlst)
	end
end

function ctaskcontainer:autohandin(player,itemneed)
	local type_num = {}
	local handinlst = {}
	for type,num in pairs(itemneed) do
		type_num[type] = 0
		local items = player.itemdb:getitemsbytype(type,function(item)
			return true
		end)
		table.sort(items,function(item1,item2)
			return true
		end)
		for _,itemobj in ipairs(items) do
			if type_num[type] + itemobj.num < num then
				handinlst[itemobj.id] = itemobj.num
				type_num[type] = type_num[type] + itemobj.num
			else
				handinlst[itemobj.id] = num - type_num[type]
				type_num[type] = num
				break
			end
		end
		if type_num[type] ~= num then
			return nil
		end
	end
	return handinlst
end

function ctaskcontainer:truehandin(player,handinlst)
	for _,value in ipairs(handinlst) do
		player.itemdb:costitembyid(value.itemid,value.num)
	end
end

function ctaskcontainer:setpatrol(task,arg,pid,npc)
end

function ctaskcontainer:progressbar(task,arg,pid,npc)
end

function ctaskcontainer:finishtask(task)
	self:log("info","task",string.format("finishtask,pid=%d taskid=%d",self.pid,task.taskid))
	self:updatetask(task,"state",TASK_STATE_FINISH)
	local taskdata = self.formdata.taskifno[taskid]
	if istrue(taskdata.autosubmit) then
		-- 无需判断是否可以提交，任务可能已经失效，调用者调用了finishtask,就必须知道可能会“无条件”提交的行为！
		self:submittask(taskid)
	end
end


--外部接口
function ctaskcontainer:accepttask(taskid,npcid)
	local task = self:__newtask({taskid = taskid})
	if task then
		self:addtask(task)
		self:setcurrentnpc(task,npcid)
		local acceptscript = self.formdata.taskinfo[taskid].accept
		self.execscript(task,acceptscript,self.pid)
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
		return false,"前置任务未完成"
	end
	return true
end

function ctaskcontainer:giveuptask(taskid)
	local task = self:gettask(taskid)
	if task then
		self:deltask(taskid,"giveup")
		return task
	end
end

function ctaskcontainer:can_giveup(taskid)
	local taskdata = self.formdata.taskinfo[taskid]
	if not istrue(taskdata.cangiveup) then
		return false,"该任务无法放弃"
	end
	return true
end

function ctaskcontainer:executetask(taskid,npcid,ext)
	local task = self:gettask(taskid)
	self:setcurrentnpc(task,npcid)
	local executescript = self.formdata.taskinfo[taskid].execution
	self:execscript(task,executescript,self.pid)
end

function ctaskcontainer:can_execute(taskid)
	local task = self:gettask(taskid)
	if not task then
		return false,"任务已失效"
	end
	if task.state == TASK_FINISH then
		return false
	end
	return true

function ctaskcontainer:submittask(taskid,npcid)
	local task = self:gettask(taskid)
	self:setcurrentnpc(task,taskid)
	local submitscript = self.formdata.taskinfo[taskid].submit
	self:execscript(task,submitscript,self.pid)
	self:deltask(taskid,"taskdone")
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

function ctaskcontainer:can_submit(taskid)
	local task = self:gettask(taskid)
	if not task then
		return false,"任务已失效"
	end
	if task.state ~= TASK_STATE_FINISH then
		return false,"任务未完成"
	end
	return true
end

function ctaskcontainer:clientfinishtask(taskid)
	local task = self:gettask(taskid)
	self:finishtask(task)
end

function ctaskcontainer:can_clientfinish(taskid)
	local task = self:gettask(taskid)
	if not task then
		return false,"任务已失效"
	end
	local taskdata = self.formdata.taskinfo[taskid]
	if taskdata.finishbyclient ~= 1 then
		return false
	end
	return true
end

return ctaskcontainer
