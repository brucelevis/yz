require "gamelogic.base.container"
require "gamelogic.template.template"

ctaskcontainer = class("ctaskcontainer",ccontainer,ctemplate)

function ctaskcontainer:init(conf)
	ccontainer.init(self,conf)
	ctemplate.init(self,conf)
	self.finishtasks = {}
	self.nowtaskid = nil		-- 仅对同时只有一个任务的任务类有效
	self.lasttaskid = nil		-- 最后一次接的任务
	self.ringnum = 0			-- 任务环数，部分任务启用
	self.donelimit = nil		-- 任务完成次数上限，未修改时用导表数据

	--脚本注册
	self.script_handle.findnpc = true
	self.script_handle.needitem = true
	self.script_handle.setpatrol = true
	self.script_handle.progressbar = true
	self.script_handle.handinitem = true
	self.script_handle.settargetpos = true
	self.script_handle.confirmtalk = true
end

function ctaskcontainer:load(data)
	if not data or not next(data) then
		return
	end
	ccontainer.load(self,data,function(objdata)
		local taskid = objdata.taskid
		local task = self:__newtask({taskid = taskid})
		if not task then
			self:log("info","task",string.format("[load unknow task] pid=%s taskid=%s",self.pid,taskid))
			return nil
		end
		task:load(objdata)
		self:loadres(task,objdata.resource)
		return task
	end)
	local finishtasks = data.finishtasks or {}
	for i,taskid in ipairs(finishtasks) do
		self.finishtasks[taskid] = true
	end
	self.nowtaskid = data.nowtaskid
	self.lasttaskid = data.lasttaskid
	self.ringnum = data.ringnum or 0
	self.donelimit = data.donelimit
end

function ctaskcontainer:save()
	local data = ccontainer.save(self,function(task)
		local data = task:save()
		data.resource = self:saveres(task)
		return data
	end)
	data.nowtaskid = self.nowtaskid
	data.lasttaskid = self.lasttaskid
	data.finishtasks = table.values(self.finishtasks)
	data.ringnum = self.ringnum
	data.donelimit = self.donelimit
	return data
end

function ctaskcontainer:clear()
	self:log("info","task",string.format("[clear] pid=%s",self.pid))
	ccontainer.clear(self)
	self.lasttaskid = nil
	self.nowtaskid = nil
	-- 累积完成任务由使用者决定是否清空
	--self.finishtasks = {}
end


--<<  可重写  >>--
function ctaskcontainer:onlogin(player)
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
	net.task.S2C.addtask(self.pid,self:pack(task))
end

function ctaskcontainer:onwarend(war,result)
	local task = self:gettask(war.taskid)
	if task then
		if warmgr.iswin(result) then
			task.execute_result = TASK_SCRIPT_PASS
		else
			task.execute_result = TASK_SCRIPT_FAIL
		end
		self:check_result(task)
		--战斗结束处理完后，检查任务超时
		task.inwar = false
		self:try_timeouttask(task)
	end
end

function ctaskcontainer:onclientasync(task,ext)
	task.execute_result = TASK_SCRIPT_PASS
end

function ctaskcontainer:raisewar(task,args,pid)
	local isok,msg = self:can_raisewar(task)
	if not isok then
		if msg then
			net.msg.S2C.notify(pid,msg)
		end
		task.execute_result = TASK_SCRIPT_FAIL
	end
	ctemplate.raisewar(self,task,args,pid)
	task.inwar = true
	task.execute_result = TASK_SCRIPT_SUSPEND
end

function ctaskcontainer:can_raisewar(task)
	return true
end

function ctaskcontainer:transwar(task,warid,pid)
	assert(pid == self.pid)
	local war = ctemplate.transwar(self,task,warid,pid)
	war.wartype = WARTYPE.PVE_PERSONAL_TASK
	war.taskid = task.taskid
	return war
end

function ctaskcontainer:getformdata(formname)
	return taskaux.gettaskdata(self.name,formname)
end

function ctaskcontainer:failtask(task)
	task.execute_result = TASK_SCRIPT_NONE
end

--将texts中所有待替换标识,替换成{ npcname = "Mike" }形式发给客户端
function ctaskcontainer:transtext(task,texts,pid)
end


--<<  内部接口  >>
function ctaskcontainer:gettask(taskid,nocheckvalid)
	local task = self:get(taskid)
	if task then
		if not nocheckvalid then
			task = self:try_timeouttask(task)
		end
	end
	if taskid == self.nowtaskid and not task then
		self.nowtaskid = nil
	end
	return task
end

function ctaskcontainer:try_timeouttask(task)
	if task.inwar == true then
		return task
	end
	if task.exceedtime then
		local now = os.time()
		if now >= task.exceedtime then
			self:deltask(task.taskid,"timeout")
			return
		end
	end
	return task
end

function ctaskcontainer:__newtask(conf)
	local taskid = assert(conf.taskid)
	local taskdata = self:getformdata("task")[taskid]
	if taskdata then
		conf.state = TASK_STATE_ACCEPT
		conf.type = taskdata.type
		conf.pid = self.pid
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
	self:log("info","task",string.format("[addtask] pid=%d taskid=%d",self.pid,taskid))
	self:add(task,taskid)
	self.lasttaskid = taskid
end

function ctaskcontainer:deltask(taskid,reason)
	local task = self:get(taskid)
	if task then
		self:log("info","task",string.format("[deltask] pid=%d taskid=%d reason=%s",self.pid,taskid,reason))
		self:del(taskid)
		return task
	end
end

function ctaskcontainer:getallsendtask()
	local tasks = {}
	for _,task in pairs(self.objs) do
		table.insert(tasks,self:pack(task))
	end
	return tasks
end

function ctaskcontainer:refreshtask(taskid)
	local task = self:gettask(taskid,true)
	if task then
		net.task.S2C.updatetask(self.pid,self:pack(task))
	end
end

function ctaskcontainer:addfinishtask(taskid)
	self.finishtasks[taskid] = true
end

function ctaskcontainer:pack(task)
	local data = {}
	data.taskid = task.taskid
	data.state = task.state
	data.exceedtime = task.exceedtime
	data.type = task.type
	local findnpc = task.resourcemgr:get("findnpc")
	if findnpc then
		local npc = self:getnpc_bynid(task,findnpc)
		if npc then
			data.findnpc = npc.id or findnpc
		end
	end
	data.patrol = task.resourcemgr:get("patrolpos")
	data.progress = task.resourcemgr:get("progresstime")
	data.items = task.resourcemgr:get("itemneed")
	if next(task.resourcemgr.npclist) then
		data.npcs = {}
		for _,npc in pairs(task.resourcemgr.npclist) do
			if npc.isclient then
				table.insert(data.npcs,{
					id = npc.id,
					shape = npc.shape,
					name = npc.name,
					posid = npc.posid,
				})
			end
		end
	end
	return data
end

function ctaskcontainer:nexttask(taskid,reason)
	if reason == "opentask" then
		local newtaskid
		if taskid then
			newtaskid = self:getformdata("task")[taskid].nexttask
		end
		if not newtaskid or newtaskid == 0 then
			newtaskid = "all"
		end
		return self:choosetask(newtaskid,taskid)
	else
		-- 提交任务后，无下一环任务，需要停止接下一环任务
		local newtaskid = self:getformdata("task")[taskid].nexttask
		if not newtaskid or newtaskid == 0 then
			return
		end
		return self:choosetask(newtaskid,taskid)
	end
end

function ctaskcontainer:choosetask(newtaskid,taskid)
	if type(newtaskid) == "number" then
		local can_accept,errmsg = self:can_accept(newtaskid)
		if can_accept then
			return newtaskid
		else
			return nil,errmsg
		end
	end
	local taskids = {}
	local taskdata = self:getformdata("task")
	local can_accept,errmsg
	for id,data in pairs(taskdata) do
		can_accept,errmsg = self:can_accept(id)
		if data.ratio ~= 0 and can_accept then
			if newtaskid == "other" then
				if taskid ~= id then
					taskids[id] = data.ratio
				end
			elseif newtaskid == "all" then
				taskids[id] = data.ratio
			else
				self:log("error","task",string.format("[wrongchoose] pid=%d taskid=%s",self.pid,newtaskid))
				return
			end
		end
	end
	if next(taskids) then
		return choosekey(taskids)
	else
		return nil,errmsg
	end
end

function ctaskcontainer:finishtask(task,reason)
	local taskid = task.taskid
	self:log("info","task",string.format("[finishtask] pid=%d taskid=%d reason=%s",self.pid,task.taskid,reason))
	task.state = TASK_STATE_FINISH
	local taskdata = self:getformdata("task")[taskid]
	if not istrue(taskdata.submitnpc) then
		self:submittask(taskid)
	else
		local npc = self:getnpc_bynid(task,taskdata.submitnpc)
		local submitnpc = npc.id or taskdata.submitnpc
		net.task.S2C.finishtask(self.pid,taskid,submitnpc)
	end
end

function ctaskcontainer:verifynpc(task)
	local nid = task.resourcemgr:get("findnpc")
	if not nid then
		return true
	end
	local npc = self:getnpc_bynid(task,nid)
	local player = playermgr.getplayer(self.pid)
	if not self:isnearby(player,npc) then
		net.msg.S2C.notify(self.pid,language.format("太远了"))
		return false
	end
	return true
end

function ctaskcontainer:newnpc()
	return ctasknpc.new()
end


--<<  脚本接口  >>
function ctaskcontainer:findnpc(task,args)
	local nid = self:formdata_values(args,"nid")[1]
	task.resourcemgr:set("findnpc",nid)
end

function ctaskcontainer:needitem(task,args)
	local itemtype = args.type
	local itemnum = args.num
	local nid = args.nid
	local itemneed = task.resourcemgr:get("itemneed",{})
	local exist = false
	for _,item in ipairs(itemneed) do
		if item.type == itemtype then
			item.num = item.num + itemnum
			exist = true
			break
		end
	end
	if not exist then
		table.insert(itemneed,{
			type = itemtype,
			num = itemnum,
		})
	end
	task.resourcemgr:set("findnpc",nid)
	task.resourcemgr:set("itemneed",itemneed)
end

function ctaskcontainer:needitemnum(itemneed,itemtype)
	for _,item in ipairs(itemneed) do
		if item.type == itemtype then
			return item.num
		end
	end
	return 0
end

function ctaskcontainer:handinitem(task,args,pid,itemlst)
	local nid = task.resourcemgr:get("findnpc")
	local npc = self:getnpc_bynid(task,nid)
	local player = playermgr.getplayer(self.pid)
	local taskdata = self:getformdata("task")[task.taskid]
	local itemneed = task.resourcemgr:get("itemneed")
	if not itemneed then
		task.execute_result = TASK_SCRIPT_FAIL
		return
	end
	local handinlst,msg
	if taskdata.autohandin ~= 1 then
		handinlst,msg = self:manualhandin(player,itemneed,itemlst)
	else
		handinlst,msg = self:autohandin(player,itemneed)
	end
	if not handinlst then
		if msg and npc then
			net.msg.S2C.npcsay(pid,npc,msg)
		end
		task.execute_result = TASK_SCRIPT_FAIL
		return
	end
	self:log("info","task",format("[handin] pid=%d,item=%s",pid,itemneed))
	self:truehandin(player,handinlst)
end

function ctaskcontainer:manualhandin(player,itemneed,itemlst)
	if table.isempty(itemlst) then
		return
	end
	local type_num = {}
	local handinlst = {}
	for _,v in ipairs(itemlst) do
		local itemid = v.itemid
		local num = v.num
		local item = player.itemdb:getitem(itemid)
		if not item or item.num < num then
			return
		end
		if 0 == self:needitemnum(itemneed,item.type) then
			return nil,language.format("携带着非需求的物品")
		end
		type_num[item.type] = (type_num[item.type] or 0) + num
		handinlst[itemid] = (handinlst[itemid] or 0) + num
	end
	for _,v in ipairs(itemneed) do
		local itemtype = v.type
		if not type_num[itemtype] then
			return nil,language.format("缺少需要的物品")
		end
		if type_num[itemtype] ~= v.num then
			return nil,language.format("所提交的物品数量不符")
		end
	end
	return handinlst
end

function ctaskcontainer:autohandin(player,itemneed)
	local type_num = {}
	local handinlst = {}
	for _,v in ipairs(itemneed) do
		local itemtype = v.type
		local num = v.num
		type_num[itemtype] = 0
		local items = player.itemdb:getitemsbytype(itemtype,function(item)
			return true
		end)
		table.sort(items,function(item1,item2)
			return true
		end)
		for _,item in ipairs(items) do
			if type_num[itemtype] + item.num < num then
				handinlst[item.id] = item.num
				type_num[itemtype] = type_num[itemtype] + item.num
			else
				handinlst[item.id] = num - type_num[itemtype]
				type_num[itemtype] = num
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
	for itemid,num in pairs(handinlst) do
		player.itemdb:costitembyid(itemid,num,string.format("task_%s",self.name))
	end
end

function ctaskcontainer:setpatrol(task,args)
	local posid = self:formdata_values(args,"posid")[1]
	posid = self:transcode(task,posid,self.pid)
	task.resourcemgr:set("patrolpos",posid)
end

--弹出进度条
function ctaskcontainer:progressbar(task,args)
	local time = args.time
	task.resourcemgr:set("progresstime",time)
end

--设置目标地
function ctaskcontainer:settargetpos(task,args)
	local posid = self:formdata_values(args,"posid")[1]
	task.resourcemgr:set("targetpos",posid)
end

function ctaskcontainer:delnpc(task,args)
	ctemplate.delnpc(self,task,args,self.pid)
	self:refreshtask(task.taskid)
end

function ctaskcontainer:talkto(task,args,pid)
	local textid = args.textid
	local texts = self:getformdata("text")[textid].texts
	local transstr = self:transtext(task,texts,pid)
	net.task.S2C.tasktalk(pid,task.taskid,textid,transstr)
end

function ctaskcontainer:confirmtalk(task,args,pid)
	local textid = args.textid
	local text = self:getformdata("text")[textid].texts[1]
	local player = playermgr.getplayer(self.pid)
	local callback = functor(function(taskid,player,answer)
		local task = player.taskdb:gettask(taskid)
		if not task then
			return
		end
		if answer == 1 then
			task.execute_result = TASK_SCRIPT_PASS
		else
			task.execute_result = TASK_SCRIPT_FAIL
		end
		local taskcontainer = player.taskdb:gettaskcontainer(taskid)
		taskcontainer:check_result(task)
	end,task.taskid)
	task.execute_result = TASK_SCRIPT_SUSPEND
	local msg = language.format("%s",text.content)
	local npc = { name = text.name, shape = text.talk }
	local options = { [1] = language.format("确认"), }
	net.msg.S2C.npcsay(pid,npc,msg,options,callback)
end

--<<  外部接口  >>
function ctaskcontainer:opentask()
	if self.len > 0 then
		return
	end
	local taskid,errmsg = self:nexttask(self.lasttaskid,"opentask")
	if not taskid then
		errmsg = errmsg or language.format("无法接受该类任务")
		net.msg.S2C.notify(self.pid,errmsg)
		return
	end
	self:log("info","task",string.format("[opentask] pid=%d taskid=%d",self.pid,taskid))
	self:accepttask(taskid)
end

function ctaskcontainer:accepttask(taskid)
	local task = self:__newtask({taskid = taskid})
	if task then
		local acceptscript = self:getformdata("task")[taskid].accept
		for _,script in ipairs(acceptscript) do
			self:doscript(task,script,self.pid)
		end
		self:addtask(task)
		self.nowtaskid = taskid
		local player = playermgr.getplayer(self.pid)
		if player.taskdb:incanaccept(self.name) then
			player.taskdb:update_canaccept()
		end
	end
end

function ctaskcontainer:can_accept(taskid)
	local player = playermgr.getplayer(self.pid)
	if not player then
		return false
	end
	if self:gettask(taskid) then
		return false
	end
	local taskdata = self:getformdata("task")[taskid]
	if not taskdata then
		return false
	end
	if taskdata.needlv and taskdata.needlv > player.lv then
		return false,language.format("玩家等级到达{1}级才可以领取该任务",taskdata.needlv)
	end
	if taskdata.needjob and next(taskdata.needjob) then
		local isok = false
		for _,job in ipairs(taskdata.needjob) do
			--if player.job == job then
			-- roletype就是职业ID，命名不够好（历史残留问题)
			if player.roletype == job then
				isok = true
				break
			end
		end
		if not isok then
			return false,language.format("职业不符合领取条件")
		end
	end
	if taskdata.pretask and next(taskdata.pretask) then
		local isok = true
		for i,taskid in ipairs(taskdata.pretask) do
			if not self.finishtasks[taskid] then
				isok = false
			end
		end
		if not isok then
			return false,language.format("前置任务未完成")
		end
	end
	if self:reachlimit() then
		return false
	end
	return true
end

function ctaskcontainer:reachlimit()
	local donelimit = self:getdonelimit()
	if istrue(donelimit) then
		local count = self:getdonecnt()
		if count >= donelimit then
			return true
		end
	end
	return false
end

function ctaskcontainer:getdonelimit(nocheck)
	local interval = data_1500_GlobalTask[self.name].interval
	local donelimit
	local player = playermgr.getplayer(self.pid)
	if interval then
		local flag = self:getflag("donelimit")
		if interval == "today" then
			donelimit = player.today:query(flag,nil,nocheck)
		elseif interval == "thisweek" then
			donelimit = player.thisweek:query(flag,nil,nocheck)
		elseif interval == "thisweek2" then
			donelimit = player.thisweek2:query(flag,nil,nocheck)
		else
			doenlimit = player.thistemp:query(flag,nil,nocheck)
		end
	end
	if not donelimit then
		donelimit = data_1500_GlobalTask[self.name].donelimit
	end
	return donelimit
end

function ctaskcontainer:setdonelimit(limit,reason)
	local interval = data_1500_GlobalTask[self.name].interval
	if not interval then
		return
	end
	self:log("info","task",format("[setdonelimit] pid=%d limit=%d reason=%s",self.pid,limit,reason))
	local player = playermgr.getplayer(self.pid)
	local flag = self:getflag("donelimit")
	if interval == "today" then
		player.today:set(flag,limit)
	elseif interval == "thisweek" then
		player.thisweek:set(flag,limit)
	elseif interval == "thisweek2" then
		player.thisweek2:set(flag,limit)
	else
		local donelimit = player.thistemp:query(flag)
		if not donelimit then
			player.thistemp:set(flag,limit,tonumber(interval))
		else
			player.thistemp:add(flag,limit-donelimit)
		end
	end
end

function ctaskcontainer:getdonecnt(nocheck)
	local interval = data_1500_GlobalTask[self.name].interval
	if not interval then
		return 0
	end
	local player = playermgr.getplayer(self.pid)
	local count = 0
	local flag = self:getflag("donecnt")
	if interval == "today" then
		count = player.today:query(flag,0,nocheck)
	elseif interval == "thisweek" then
		count = player.thisweek:query(flag,0,nocheck)
	elseif interval == "thisweek2" then
		count = player.thisweek2:query(flag,0,nocheck)
	else
		count = player.thistemp:query(flag,0,nocheck)
	end
	return count
end

function ctaskcontainer:adddonecnt(cnt)
	local interval = data_1500_GlobalTask[self.name].interval
	if not interval then
		return
	end
	local player = playermgr.getplayer(self.pid)
	local flag = self:getflag("donecnt")
	if interval == "today" then
		player.today:add(flag,cnt)
	elseif interval == "thisweek" then
		player.thisweek:add(flag,cnt)
	elseif interval == "thisweek2" then
		player.thisweek2:add(flag,cnt)
	else
		if not player.thistemp:query(flag) then
			player.thistemp:set(flag,0,tonumber(interval))
		end
		player.thistemp:add(flag,cnt)
	end
end

function ctaskcontainer:getflag(flag)
	return string.format("task_%s.%s",self.name,flag)
end

function ctaskcontainer:giveuptask(taskid)
	local taskdata = self:getformdata("task")[taskid]
	if not istrue(taskdata.cangiveup) then
		return false,language.format("该任务无法放弃")
	end
	local task = self:gettask(taskid)
	if task.inwar then
		return false,language.format("无法在战斗中放弃该任务")
	end
	if task then
		self:deltask(taskid,"giveup")
		local player = playermgr.getplayer(self.pid)
		player.taskdb:update_canaccept()
	end
	return true
end

function ctaskcontainer:executetask(taskid,npcid,ext)
	local task = self:gettask(taskid)
	if not task then
		return false,language.format("任务已失效")
	end
	local npc = self:getnpc(task,npcid)
	if npc and npc.nid then
		local npcdata = self:getformdata("npc")[npc.nid]
		local talk,respond = npcdata.talk,npcdata.respond
		if string.len(talk) ~= 0 then
			npc:look(self.pid,talk,respond)
			return true
		end
	end
	local isok,msg = self:can_execute(task)
	if not isok then
		return false,msg
	end
	self:executetask2(task,ext)
	return true
end

function ctaskcontainer:can_execute(task)
	if not self:verifynpc(task) then
		return false
	end
	if task.execute_result ~= TASK_SCRIPT_NONE then
		return false,language.format("任务正在执行中")
	end
	if task.state == TASK_STATE_FINISH then
		return false,language.format("任务可提交")
	end
	return true
end

function ctaskcontainer:executetask2(task,ext)
	local executescript = self:getformdata("task")[task.taskid].execution
	local script = executescript[task.execute_step]
	if script then
		task.execute_result = TASK_SCRIPT_PASS
		self:doscript(task,script,self.pid,ext)
		self:check_result(task,ext)
	else
		self:finishtask(task,"exec")
	end
end

function ctaskcontainer:check_result(task,ext)
	if task.execute_result == TASK_SCRIPT_PASS then
		task.execute_step = task.execute_step + 1
		return self:executetask2(task,ext)
	end
	if task.execute_result == TASK_SCRIPT_SUSPEND then
		return
	end
	if task.execute_result == TASK_SCRIPT_FAIL then
		self:failtask(task)
		return
	end
end

function ctaskcontainer:submittask(taskid)
	local task = self:gettask(taskid,true)
	if not task then
		return
	end
	local taskdata = self:getformdata("task")[taskid]
	if taskdata.submitnpc then
		local player = playermgr.getplayer(self.pid)
		local npc = self:getnpc_bynid(task,taskdata.submitnpc)
		if npc and not self:isnearby(player,npc) then
			net.msg.S2C.notify(self.pid,language.format("太远了"))
			return
		end
	end
	self:addfinishtask(taskid)
	self:adddonecnt(1)
	self.nowtaskid = nil
	self:deltask(taskid,"taskdone")
	local awardid = self:getformdata("task")[taskid].award
	self:doaward(task,awardid,self.pid)
	local newtaskid = self:nexttask(taskid,"submittask")
	if newtaskid then
		--self:log("info","task",string.format("[nexttask] pid=%d taskid=%d",self.pid,newtaskid))
		self:accepttask(newtaskid)
	end
end

function ctaskcontainer:can_submit(taskid)
	local task = self:gettask(taskid)
	if not task then
		return false,language.format("任务已失效")
	end
	if task.state ~= TASK_STATE_FINISH then
		return false,language.format("任务未完成")
	end
	return true
end

function ctaskcontainer:clientfinishtask(taskid)
	local task = self:gettask(taskid)
	if not task then
		return false,language.format("任务已失效")
	end
	local taskdata = self:getformdata("task")[taskid]
	if taskdata.finishbyclient ~= 1 then
		return false
	end
	self:finishtask(task,"client")
	return true
end

function ctaskcontainer:getcanaccept()
	if self.len > 0 then
		return
	end
	if self:reachlimit() then
		return
	end
	return { taskkey = self.name,}
end

return ctaskcontainer

