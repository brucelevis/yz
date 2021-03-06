require "gamelogic.base.container"
require "gamelogic.template.template"

ctaskcontainer = class("ctaskcontainer",ccontainer,ctemplate)

function ctaskcontainer:init(conf)
	ccontainer.init(self,conf)
	ctemplate.init(self,conf)
	self.pid = assert(conf.pid)
	self.finishtasks = {}
	self.nowtaskid = nil		-- 仅对同时只有一个任务的任务类有效
	self.lasttaskid = nil		-- 最后一次接的任务
	self.ringnum = 0			-- 任务环数，部分任务启用
	self.canacceptnum = 1		-- 该类任务可以同时接个数，nil不限

	self.is_teamsubmit = false
	self.is_teamfinish = false
	self.is_teamsync = false

	--脚本注册
	self.script_handle.findnpc = true
	self.script_handle.needitem = true
	self.script_handle.setpatrol = true
	self.script_handle.setcollect = true
	self.script_handle.handinitem = true
	self.script_handle.taskdati = true
	self.script_handle.optiontalkto = true
	self.script_handle.openui = true
end

function ctaskcontainer:load(data)
	if not data or not next(data) then
		return
	end
	ccontainer.load(self,data,function(objdata)
		return self:loadtask(objdata)
	end)
	local finishtasks = data.finishtasks or {}
	for i,taskid in ipairs(finishtasks) do
		self.finishtasks[taskid] = true
	end
	self.nowtaskid = data.nowtaskid
	self.lasttaskid = data.lasttaskid
	self.ringnum = data.ringnum or 0
end

function ctaskcontainer:loadtask(objdata)
	local taskid = objdata.taskid
	local task = self:__newtask({taskid = taskid})
	if not task then
		self:log("info","task",string.format("[load unknow task] pid=%s taskid=%s",self.pid,taskid))
		return nil
	end
	task:load(objdata)
	if cserver.isinnersrv() then
		local isok = xpcall(self.loadres,onerror,self,task,objdata.resource)
		if not isok then
			return nil
		end
	else
		self:loadres(task,objdata.resource)
	end
	task = self:try_timeouttask(task)
	return task
end

function ctaskcontainer:save()
	local data = ccontainer.save(self,function(task)
		return self:savetask(task)
	end)
	data.nowtaskid = self.nowtaskid
	data.lasttaskid = self.lasttaskid
	data.finishtasks = table.keys(self.finishtasks)
	data.ringnum = self.ringnum
	return data
end

function ctaskcontainer:savetask(task)
	local data = task:save()
	data.resource = self:saveres(task)
	return data
end

function ctaskcontainer:clear(reason)
	self:log("info","task",string.format("[clear] pid=%s reason=%s",self.pid,reason))
	ccontainer.clear(self)
	self.lasttaskid = nil
	self.nowtaskid = nil
	-- 累积完成任务由使用者决定是否清空
	--self.finishtasks = {}
end


--<<  可重写  >>--
function ctaskcontainer:onlogin(player)
end

function ctaskcontainer:onlogoff(player,reason)
	if not warmgr.warid(player.pid) then
		for _,task in pairs(self.objs) do
			task.execute_result = TASK_SCRIPT_NONE
		end
	end
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
		task.war_members = war.attackers
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

function ctaskcontainer:onsubmittask(task)
end

function ctaskcontainer:raisewar(task,args,pid)
	assert(pid == self.pid)
	local isok,msg = self:can_raisewar(task)
	if not isok then
		if msg then
			net.msg.S2C.notify(pid,msg)
		end
		task.execute_result = TASK_SCRIPT_FAIL
		return false
	end
	local isok = ctemplate.raisewar(self,task,args,pid)
	if not isok then
		task.execute_result = TASK_SCRIPT_FAIL
		return false
	end
	task.inwar = true
	task.execute_result = TASK_SCRIPT_SUSPEND
	return true
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
	local transstr = {}
	local player = playermgr.getplayer(pid)
	for _,text in pairs(texts) do
		if string.find(text.name,"$playername") or string.find(text.content,"$playername") then
			transstr.playername = player.name
		end
		if string.find(text.content,"$playerjob") then
			transstr.playerjob = data_0101_Hero[player.roletype].name
		end
	end
	return transstr
end

function ctaskcontainer:transnpc(task,newnpc,pid)
	newnpc.purpose = "task"
	return newnpc
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
		if taskdata.exceedtime and taskdata.exceedtime ~= "nil" then
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
	self.nowtaskid = taskid
end

function ctaskcontainer:deltask(taskid,reason)
	local task = self:get(taskid)
	if task then
		self:log("info","task",string.format("[deltask] pid=%d taskid=%d reason=%s",self.pid,taskid,reason))
		self:del(taskid)
		local player = playermgr.getplayer(self.pid)
		player.taskdb:update_canaccept()
		return task
	end
end

function ctaskcontainer:getallsendtask()
	local tasks = {}
	for _,task in pairs(self.objs) do
		task = self:try_timeouttask(task)
		if task then
			table.insert(tasks,self:pack(task))
		end
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
	data.ringnum = self.ringnum
	local findnpc = task.resourcemgr:get("findnpc")
	if findnpc then
		data.findnpc = {}
		if type(findnpc) == "table" then
			for i,nid in pairs(findnpc) do 
				local npc = self:getnpc_bynid(task,nid)
				if npc then
					local id = npc.id or nid
					table.insert(data.findnpc,id)
				end
			end
			data.respondtype = task.resourcemgr:get("respondtype")
		else
			local npc = self:getnpc_bynid(task,findnpc)
			if npc then
				local nid = npc.id or findnpc
				table.insert(data.findnpc,nid)
			end
			data.respondtype = task.resourcemgr:get("respondtype")
		end
	end
	data.patrol = task.resourcemgr:get("patrolpos")
	local collect = task.resourcemgr:get("collectpos")
	if collect then
		data.collect = collect
		local tips = task.resourcemgr:get("collecttips")
		tips = tips and format("正在%s中",tips) or "正在采集中"
		data.collecttips = tips
	end
	local items = task.resourcemgr:get("itemneed")
	if items then
		data.items = items[1]
	end
	if next(task.resourcemgr.npclist) then
		data.npcs = {}
		for _,npc in pairs(task.resourcemgr.npclist) do
			-- 跟玩家的NPC/任务NPC
			if npc.isclient then
				table.insert(data.npcs,{
					id = npc.id,
					shape = npc.shape,
					name = npc.name,
					posid = npc.posid,
					sceneid = npc.sceneid,
					nid = npc.nid,
					purpose = npc.purpose,
				})
			end
		end
	end
	local taskdata = self:getformdata("task")[task.taskid]
	local npc = self:getnpc_bynid(task,taskdata.submitnpc)
	if npc then
		data.submitnpc = npc.id or taskdata.submitnpc
	end
	data.donecnt = self:getdonecnt()
	data.donelimit = self:getdonelimit()
	return data
end

function ctaskcontainer:nexttask(taskid,reason)
	if reason == "opentask" then
		local newtaskid
		if taskid then
			newtaskid = self:getformdata("task")[taskid].nexttask
		end
		if not newtaskid or newtaskid == "nil" or newtaskid == 0 then
			newtaskid = "all"
		end
		return self:choosetask(newtaskid,taskid)
	else
		-- 提交任务后，无下一环任务，需要停止接
		local newtaskid = self:getformdata("task")[taskid].nexttask
		if not newtaskid or newtaskid == "nil" or newtaskid == 0 then
			return
		end
		return self:choosetask(newtaskid,taskid)
	end
end

function ctaskcontainer:choosetask(newtaskid,taskid)
	local newtaskid2 = tonumber(newtaskid)
	if newtaskid2 then
		--支持下一环接不同容器内任务
		local player = playermgr.getplayer(self.pid)
		local taskcontainer = player.taskdb:gettaskcontainer(newtaskid2)
		if not taskcontainer then
			return
		end
		local can_accept,errmsg = taskcontainer:can_accept(newtaskid2)
		if can_accept then
			return newtaskid2
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
	if self.is_teamfinish then
		self:team_finishtask(task,reason)
	end
	local taskdata = self:getformdata("task")[taskid]
	if not istrue(taskdata.submitnpc) then
		self:submittask(taskid)
	else
		local npc = self:getnpc_bynid(task,taskdata.submitnpc)
		local submitnpc = npc.id or taskdata.submitnpc
		net.task.S2C.finishtask(self.pid,taskid,submitnpc)
	end
end

function ctaskcontainer:team_finishtask(task,reason)
	local player = playermgr.getplayer(self.pid)
	if player:teamstate() ~= TEAM_STATE_CAPTAIN or not task.war_members then
		return
	end
	for _,pid in ipairs(task.war_members) do
		if pid ~= self.pid then
			local member = playermgr.getplayer(pid)
			if member then
				local task2 = member.taskdb:gettask(task.taskid)
				if task2 then
					local taskcontainer = member.taskdb:gettaskcontainer(task.taskid)
					ctaskcontainer.finishtask(taskcontainer,task2,reason)
				end
			end
		end
	end
end

function ctaskcontainer:accepttask(taskid)
	local task = self:__newtask({taskid = taskid})
	if task then
		local acceptscript = self:getformdata("task")[taskid].accept
		for _,script in ipairs(acceptscript) do
			self:doscript(task,script,self.pid)
		end
		self:addtask(task)
		local player = playermgr.getplayer(self.pid)
		if player.taskdb:incanaccept(self.name) then
			player.taskdb:update_canaccept()
		end
		if self.is_teamsync then
			self:teamsynctask(taskid)
		end
	end
end

function ctaskcontainer:teamsynctask(taskid)
	local player = playermgr.getplayer(self.pid)
	if player:teamstate() ~= TEAM_STATE_CAPTAIN then
		return
	end
	for _,pid in ipairs(player:getfighters()) do
		if pid ~= self.pid then
			local member = playermgr.getplayer(pid)
			if not member.taskdb:gettask(taskid) then
				self:synctask(member,taskid)
			end
		end
	end
end

function ctaskcontainer:synctask(player,taskid)
	local task = self:gettask(taskid)
	if task then
		local taskcontainer = player.taskdb[self.name]
		taskcontainer:deltask(taskcontainer.nowtaskid,"synctask")
		if taskcontainer:can_accept(taskid) then
			local task2 = taskcontainer:loadtask(self:savetask(task))
			taskcontainer:addtask(task2)
			if player.taskdb:incanaccept(self.name) then
				player.taskdb:update_canaccept()
			end
		end
	end
end

function ctaskcontainer:can_accept(taskid)
	if self:gettask(taskid) then
		return
	end
	local player = playermgr.getplayer(self.pid)
	if not player then
		return false
	end
	if self:reachlimit() then
		return false,language.format("该任务完成次数已达到上限")
	end
	if self.canacceptnum and self.canacceptnum <= self.len then
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
		for i,taskid in ipairs(taskdata.pretask) do
			if not player.taskdb:isfinishtask(taskid) then
				return false,language.format("前置任务未完成")
			end
		end
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
			donelimit = player.thistemp:query(flag,nil,nocheck)
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

function ctaskcontainer:onfivehourupdate()
	if not (self:getformdata("interval") == "today") then
		return
	end
	if not self.nowtaskid then
		return
	end
	self:deltask(self.nowtaskid,"timeout")
end

function ctaskcontainer:oncleartoday(dataunit)
	if not istrue(self:getformdata("isoverlay")) then
		return
	end
	local lastlimit = dataunit:query(self:getflag("donelimit"),self:getformdata("donelimit"))
	local lastdonecnt = dataunit:query(self:getflag("donecnt"),0)
	local restcnt = math.max(lastlimit-lastdonecnt,0)
	local donelimit = self:getformdata("donelimit")
	local harddonelimit = self:getformdata("harddonelimit")
	donelimit = math.min(donelimit + restcnt,harddonelimit)
	self:setdonelimit(donelimit,"oncleartoday")
end

function ctaskcontainer:getflag(flag)
	return string.format("task_%s.%s",self.name,flag)
end


--<<  脚本接口  >>
function ctaskcontainer:findnpc(task,args)
	local nid = self:formdata_values(args,"nid")
	local respond = args.respond
	task.resourcemgr:set("findnpc",nid)
	task.resourcemgr:set("respondtype",respond)
end

function ctaskcontainer:needitem(task,args)
	local itemtype = args.type
	local itemnum = args.num
	local nid = self:formdata_values(args,"nid")
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

function ctaskcontainer:getitemtype(itemtype)
	if not data_0501_ItemSet[itemtype] then
		return { itemtype, }
	end
	return data_0501_ItemSet[itemtype].items
end

function ctaskcontainer:handinitem(task,args,pid,ext)
	local itemlst = ext.items
	local nid = task.resourcemgr:get("findnpc")[1]
	local npc = self:getnpc_bynid(task,nid)
	local player = playermgr.getplayer(self.pid)
	local taskdata = self:getformdata("task")[task.taskid]
	local itemneed = task.resourcemgr:get("itemneed")
	if not itemneed then
		task.execute_result = TASK_SCRIPT_FAIL
		return
	end
	local handinlst,msg
	if not self.isautohandin then
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
	for itemid,num in pairs(handinlst) do
		local item = player.itemdb:getitem(itemid)
		local itemtype = item.type
		local itemname = itemaux.getitemdata(itemtype).name
		net.msg.S2C.notify(pid,language.format("消耗 #<II{1}># #<O>【{2}】-{3}#",itemtype,itemname,num))
	end
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
		if not item or item.num < num or item.pos < ITEMPOS_BEGIN then
			return
		end
		local needtype
		for _,v2 in ipairs(itemneed) do
			if table.find(self:getitemtype(v2.type),item.type) then
				needtype = v2.type
				break
			end
		end
		if not needtype then
			return nil,language.format("携带着非需求的物品")
		end
		type_num[needtype] = (type_num[needtype] or 0) + num
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
		local items = {}
		local typs = self:getitemtype(itemtype)
		for _,typ in ipairs(typs) do
			local v2 = player.itemdb:getitemsbytype(typ)
			if v2 then
				table.extend(items,v2)
			end
		end
		table.sort(items,function(item1,item2)
			return item1.id < item2.id
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
		if type_num[itemtype] ~= num then
			return nil,language.format("所需物品不足")
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
	local posid = tostring(self:formdata_values(args,"posid")[1])
	posid = self:transcode(task,posid,self.pid)
	task.resourcemgr:set("patrolpos",posid)
end

function ctaskcontainer:setcollect(task,args)
	local posid = tostring(self:formdata_values(args,"posid")[1])
	local tips = args.name
	posid = self:transcode(task,posid,self.pid)
	task.resourcemgr:set("collectpos",posid)
	task.resourcemgr:set("collecttips",tips)
end

function ctaskcontainer:delnpc(task,args)
	ctemplate.delnpc(self,task,args,self.pid)
	if task.execute_result ~= TASK_SCRIPT_NONE then
		self:refreshtask(task.taskid)
	end
end

function ctaskcontainer:addnpc(task,args)
	ctemplate.addnpc(self,task,args,self.pid)
	if task.execute_result ~= TASK_SCRIPT_NONE then
		self:refreshtask(task.taskid)
	end
end

function ctaskcontainer:talkto(task,args,pid)
	local textid = args.textid
	local textdata = self:getformdata("text")[textid]
	if not textdata then
		return
	end
	local transstr = self:transtext(task,textdata.texts,pid)
	if task.execute_result == TASK_SCRIPT_NONE then
		net.task.S2C.tasktalk(pid,task.taskid,textid,transstr)
	else
		local callback = function(pid,request,respond)
			local player = playermgr.getplayer(pid)
			if not player then
				return
			end
			local taskid = request.taskid
			local task = player.taskdb:gettask(taskid)
			if not task then
				return
			end
			task.execute_result = TASK_SCRIPT_PASS
			local taskcontainer = player.taskdb:gettaskcontainer(taskid)
			taskcontainer:check_result(task)
		end
		local respondid = reqresp.req(pid,{ taskid = task.taskid, },callback)
		task.execute_result = TASK_SCRIPT_SUSPEND
		net.task.S2C.tasktalk(pid,task.taskid,textid,transstr,respondid)
	end
end

function ctaskcontainer:optiontalkto(task,args,pid)
	local textid = args.textid
	local textdata = self:getformdata("text")[textid]
	if not textdata then
		return
	end
	local transstr = self:transtext(task,textdata.texts,pid)
	local option2awardid = {}
	for i = 1,4 do
		local awardid = args[string.format("option%d",i)]
		if not awardid then
			break
		end
		table.insert(option2awardid,awardid)
	end
	local callback = function(pid,request,respond)
		local player = playermgr.getplayer(pid)
		if not player then
			return
		end
		local option2awardid = request.options
		local taskid = request.taskid
		local answer = respond.answer
		local task = player.taskdb:gettask(taskid)
		if not task then
			return
		end
		local awardid = option2awardid[answer]
		if not awardid then
			task.execute_result = TASK_SCRIPT_FAIL
		else
			task.execute_result = TASK_SCRIPT_PASS
			task.resourcemgr:set("optionaward",awardid)
		end
		local taskcontainer = player.taskdb:gettaskcontainer(taskid)
		taskcontainer:check_result(task)
	end
	local respondid = reqresp.req(pid,{ taskid = task.taskid, options = option2awardid, },callback)
	task.execute_result = TASK_SCRIPT_SUSPEND
	net.task.S2C.tasktalk(pid,task.taskid,textid,transstr,respondid)
end

function ctaskcontainer:taskdati(task,args)
	local datiinfo = task.resourcemgr:query("dati")
	local questionbank = self:getquestionbank()
	if not datiinfo then
		local mincorrect = args.mincorrect or 1
		local maxcnt = args.maxcnt or 1
		local questions = huodongmgr.playunit.dati.generate_norepeat(maxcnt,questionbank)
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
					if datiinfo.maxcnt > 1 then
						net.msg.S2C.notify(player.pid,language.format("答题失败"))
					end
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

function ctaskcontainer:getquestionbank()
	return "data_1100_QuestionBank01"
end

function ctaskcontainer:openui(task,args)
	local buttonid = args.buttonid
	net.task.S2C.openui(self.pid,task.taskid,buttonid)
	task.execute_result = TASK_SCRIPT_NONE
end


--<<  外部接口  >>
function ctaskcontainer:opentask()
	local taskid,errmsg = self:nexttask(self.lasttaskid,"opentask")
	if not taskid then
		if errmsg then
			net.msg.S2C.notify(self.pid,errmsg)
		end
		return
	end
	self:log("info","task",string.format("[opentask] pid=%d taskid=%d",self.pid,taskid))
	self:accepttask(taskid)
end

-- 部分任务需要指定任务id接受
function ctaskcontainer:directaccept(taskid)
	local isok,msg = self:can_accept(taskid)
	if not isok then
		if msg then
			net.msg.S2C.notify(self.pid,msg)
		end
		return false
	end
	self:accepttask(taskid)
	return true
end

function ctaskcontainer:can_directaccept(taskid)
	return false
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
	end
	return true
end

function ctaskcontainer:looktasknpc(taskid,npcid)
	local task = self:gettask(taskid)
	if not task then
		return false,language.format("任务已失效")
	end
	local npc = self:getnpc(task,npcid)
	if not npc.nid then
		return false
	end
	local player = playermgr.getplayer(self.pid)
	if not self:isnearby(player,npc) then
		return false,language.format("太远了")
	end
	local npcdata = self:getformdata("npc")[npc.nid]
	local talk,respond = npcdata.talk,npcdata.respond
	return true
end

function ctaskcontainer:executetask(taskid,ext)
	local task = self:gettask(taskid)
	if not task then
		return false,language.format("任务已失效")
	end
	local isok,msg = self:can_execute(task)
	if not isok then
		return false,msg
	end
	if self.is_teamsync then
		self:teamsynctask(taskid)
	end
	self:log("info","task",format("[execute] pid=%d taskid=%d",self.pid,taskid))
	self:executetask2(task,ext)
	return true
end

function ctaskcontainer:can_execute(task)
	if task.state == TASK_STATE_FINISH then
		return false,language.format("任务可提交")
	end
	if task.execute_result ~= TASK_SCRIPT_NONE then
		return false,language.format("任务正在执行中")
	end
	local player = playermgr.getplayer(self.pid)
	local nid = task.resourcemgr:get("findnpc")
	if nid then
		if type(nid) == "table" then
			local isok = false
			for i,id in pairs(nid) do
				local npc = self:getnpc_bynid(task,id)
				if self:isnearby(player,npc) then
					isok = true
				end
			end
			if not isok then
				return false,language.format("太远了")
			end
		else
			local npc = self:getnpc_bynid(task,nid)
			if not self:isnearby(player,npc) then
				return false,language.format("太远了")
			end
		end
	end
	local collectpos = task.resourcemgr:get("collectpos")
	if collectpos then
		if not self:isnearby(player,{ posid = collectpos, }) then
			return false,language.format("还未到采集点")
		end
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
		if self.is_teamfinish then
			local player = playermgr.getplayer(self.pid)
			if player:teamstate() == TEAM_STATE_CAPTAIN and task.war_members then
				for _,pid in ipairs(task.war_members) do
					if pid ~= self.pid then
						local member = playermgr.getplayer(pid)
						--共同完成的任务需要同步数据给队员
						if member and member.taskdb:gettask(task.taskid) then
							self:synctask(member,task.taskid)
						end
					end
				end
			end
		end
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
	net.msg.S2C.notify(self.pid,language.format("完成任务"))
	local awardid = self:getformdata("task")[taskid].award
	if task.resourcemgr:get("optionaward") then
		awardid = task.resourcemgr:get("optionaward")
	end
	self:doaward(task,awardid,self.pid)
	if self:getdonecnt() + 1 <= self:getdonelimit() then
		self:adddonecnt(1)
	end
	self:addfinishtask(taskid)
	self.nowtaskid = nil
	self:deltask(taskid,"taskdone")
	self:onsubmittask(task)
	if self.is_teamsubmit then
		self:team_submittask(taskid)
	end
	local newtaskid = self:nexttask(taskid,"submittask")
	if newtaskid then
		--self:log("info","task",string.format("[nexttask] pid=%d taskid=%d",self.pid,newtaskid))
		local player = playermgr.getplayer(self.pid)
		local taskcontainer = player.taskdb:gettaskcontainer(newtaskid)
		taskcontainer:accepttask(newtaskid)
	end
end

function ctaskcontainer:team_submittask(taskid)
	local player = playermgr.getplayer(self.pid)
	if player:teamstate() ~= TEAM_STATE_CAPTAIN then
		return
	end
	for _,pid in ipairs(player:getfighters()) do
		if pid ~= self.pid then
			local member = playermgr.getplayer(pid)
			local taskcontainer = member.taskdb:gettaskcontainer(taskid)
			if member.taskdb:gettask(taskid) and ctaskcontainer.can_submit(taskcontainer,taskid) then
				ctaskcontainer.submittask(taskcontainer,taskid)
			end
		end
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
	if not self:validshow_incanaccept() then
		return
	end
	local taskdata = self:getformdata("task")
	if not taskdata then
		return
	end
	local taskid
	for id,data in pairs(taskdata) do
		if data.ratio ~= 0 then
			taskid = id
			break
		end
	end
	if not taskid then
		return
	end
	local canaccept = {}
	table.insert(canaccept,{ taskkey = self.name, taskid = taskid, })
	return canaccept
end

function ctaskcontainer:validshow_incanaccept()
	if self.canacceptnum and self.canacceptnum <= self.len then
		return false
	end
	if self:reachlimit() then
		return false
	end
	return true
end

function ctaskcontainer:reviewstory(taskid)
	local taskdata = self:getformdata("task")[taskid]
	if not taskdata then
		return
	end
	local textids = {}
	local transstr = {}
	local textid,textdata
	for _,data in ipairs(taskdata.accept) do
		if data.cmd == "talkto" or data.cmd == "optiontalkto" then
			textid = data.args.textid
			textdata = self:getformdata("text")[textid]
			table.insert(textids,textid)
			table.update(transstr,self:transtext(nil,textdata.texts,self.pid))
		end
	end
	for _,data in ipairs(taskdata.execution) do
		if data.cmd == "talkto" or data.cmd == "optiontalkto" then
			textid = data.args.textid
			textdata = self:getformdata("text")[textid]
			table.insert(textids,textid)
			table.update(transstr,self:transtext(nil,textdata.texts,self.pid))
		end
	end
	return textids,transstr
end

return ctaskcontainer

