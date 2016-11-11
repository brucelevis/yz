--工会跑商
cpaoshangtask = class("cpaoshangtask",ctaskcontainer)

function cpaoshangtask:init(conf)
	ctaskcontainer.init(self,conf)

	--定制脚本
	self.script_handle.paoshang = true
end

function cpaoshangtask:__canaccept()
	local player = playermgr.getplayer(self.pid)
	local unionid = player:unionid()
	if not unionid then
		return false,language.format("你没有公会")
	end
	local flag = self:getflag("donecnt")
	local flag2 = self:getflag("donelimit")
	local player = playermgr.getplayer(self.pid)
	local donecnt = player.today:query(flag) or 0
	local donelimit = player.today:query(flag2)
	if not donelimit then
		local todaydonelimit = self:getformdata("var").TodayDonelimit
		local weekdonecnt = self:getdonecnt()
		local weekdonelimit = self:getdonelimit()
		donelimit = math.min(todaydonelimit,(weekdonelimit - weekdonecnt))
		player.today:set(flag2,donelimit)
	end
	if donelimit <= donecnt then
		return false,language.format("今天的跑商已经全部完成")
	end
	return true
end

function cpaoshangtask:getdailystat()
	local player = playermgr.getplayer(self.pid)
	local flag = self:getflag("donecnt")
	local flag2 = self:getflag("donelimit")
	local donecnt = player.today:query(flag) or 0
	local donelimit = player.today:query(flag2)
	return donecnt,donelimit
end

function cpaoshangtask:can_accept(taskid)
	local isok,errmsg = self:__canaccept()
	if not isok then
		return isok,errmsg
	end
	return ctaskcontainer.can_accept(self,taskid)
end

function cpaoshangtask:validshow_incanaccept()
	if not self:__canaccept() then
		return false
	end
	return ctaskcontainer.validshow_incanaccept(self)
end

function cpaoshangtask:onadd(task)
	local data = self:getformdata("var")
	local goodslist = data.TaskGoodsList
	local goodsmaxnum = data.TaskGoodsMaxNum
	local goodsminnum = data.TaskGoodsMinNum
	local i = 0
	local goodsids = {}
	while i < goodsminnum do
		local n = math.random(1,goodsmaxnum)
		if not (goodsids[n] == goodslist[n]) then
			goodsids[(n)] = (goodslist[n])
			i = i + 1
		end
	end
	local tasknpcdata = {}
	local standard_price = 0
	for _,goodsid in pairs(goodsids) do
		local goodsdata = data_1500_PaoshangTaskGoods[goodsid]
		local minprice = goodsdata.min_price[1]
		local maxprice = goodsdata.min_price[2]
		standard_price = standard_price + goodsdata.standard_price
		local npcs = goodsdata.npcs
		for _,npcid in pairs(npcs) do
			local price = math.random(minprice,maxprice)
			if not tasknpcdata[npcid] then
				tasknpcdata[npcid] = {}
			end
			tasknpcdata[npcid][(goodsid)] = price
		end
	end
	for _,goodsid in pairs(goodsids) do
		local i = 0
		while i < 1 do
			local goodsdata = data_1500_PaoshangTaskGoods[goodsid]
			local minprice = goodsdata.max_price[1]
			local maxprice = goodsdata.max_price[2]
			local npcs = goodsdata.npcs
			local npcid = npcs[math.random(1,#npcs)]
			local price = math.random(minprice,maxprice)
			local nowstandard_price = 0
			for i,p in pairs(tasknpcdata[npcid]) do
				if i == goodsid then
					nowstandard_price = nowstandard_price + price
				else
					nowstandard_price = nowstandard_price + p
				end
			end
			if nowstandard_price < standard_price then
				i = i + 1
				tasknpcdata[npcid][goodsid] = price
			end
		end
	end
	task.goodsids = goodsids
	task.tasknpcdata = tasknpcdata
	task.standard_price = standard_price
	task.acutal_price = 0
	net.task.S2C.addtask(self.pid,self:pack(task))
end

function cpaoshangtask:pack(task)
	local data = ctaskcontainer.pack(self,task)
	data.donecnt = task.acutal_price
	data.donelimit = task.standard_price
	return data
end

function cpaoshangtask:save()
	local task = self:gettask(self.nowtaskid)
	local goodsids = {}
	local tasknpcdata = {}
	local standard_price = nil
	local acutal_price = nil
	if task then
		for i,goodsid in pairs(task.goodsids) do
			goodsids[tostring(i)] = goodsid
		end
		for npcid,ids_price in pairs(task.tasknpcdata) do
			for goodsid,price in pairs(ids_price) do
				npcid = tostring(npcid)
				goodsid = tostring(goodsid)
				if not tasknpcdata[npcid] then
					tasknpcdata[npcid] = {}
				end
				tasknpcdata[npcid][goodsid] = price
			end
		end
		standard_price = task.standard_price
		acutal_price = task.acutal_price
	end
	local data = ctaskcontainer.save(self)
	data.goodsids = goodsids
	data.tasknpcdata = tasknpcdata
	data.standard_price = standard_price
	data.acutal_price = acutal_price
	return data
end

function cpaoshangtask:load(data)
	ctaskcontainer.load(self,data)
	local task = self:gettask(self.nowtaskid)
	if task then
		if table.isempty(data.goodsids) or
			table.isempty(data.tasknpcdata) or
			not data.standard_price or
			not data.acutal_price then
			if cserver.isinnersrv() then
				self:deltask(self.nowtaskid,"olddata")
				return
			end
		end
		local goodsids = {}
		local tasknpcdata = {}
		for i,goodsid in pairs(data.goodsids) do
			goodsids[tonumber(i)] = goodsid
		end
		for npcid,ids_price in pairs(data.tasknpcdata) do
			for goodsid,price in pairs(ids_price) do
				npcid = tonumber(npcid)
				goodsid = tonumber(goodsid)
				if not tasknpcdata[npcid] then
					tasknpcdata[npcid] = {}
				end
				tasknpcdata[npcid][goodsid] = price
			end
		end
		task.goodsids = goodsids
		task.tasknpcdata = tasknpcdata
		task.standard_price = data.standard_price
		task.acutal_price = data.acutal_price
	end
end

function cpaoshangtask:paoshang(task,args,pid,ext)
	local npcid = ext.npcId
	local options = {}
	local goodsids = {}
	local npc = data_0601_NPC[npcid]
	local tasknpcdata = task.tasknpcdata
	for id,v in pairs(tasknpcdata) do
		if id == npcid then
			for goodsid,price in pairs(v) do
				local name = data_1500_PaoshangTaskGoods[goodsid].name
				local icon = data_1500_PaoshangTaskGoods[goodsid].iconid
				local option = language.format("{1}{2} 价格{3}",
				language.untranslate(icon),name,language.untranslate(price))
				table.insert(options,option)
				table.insert(goodsids,goodsid)
			end
		end
	end
	net.msg.S2C.npcsay(self.pid,npc,
		language.format("请问需要出售些什么"),
		options,
		function(pid,request,respond)
			local player = playermgr.getplayer(pid)
			if not player then
				return
			end
			if respond.answer and not openui.isclose(respond.answer) then
				self:deal(task,npcid,goodsids[respond.answer])
				if not table.isempty(task.goodsids) then
					self:paoshang(task,args,pid,ext)
				end
				net.msg.S2C.notify(player.pid,language.format("交易成功"))
			end
		end
		)
	task.execute_result = TASK_SCRIPT_NONE
	return
end

function cpaoshangtask:executetask2(task,ext)
	local executescript = self:getformdata("task")[task.taskid].execution
	local script = executescript[task.execute_step]
	if script then
		task.execute_result = TASK_SCRIPT_PASS
		self:doscript(task,script,self.pid,ext)
	end
end

function cpaoshangtask:can_execute(task)
	local isok,errmsg = ctaskcontainer.can_execute(self,task)
	if not isok then
		return isok,errmsg
	end
	local player = playermgr.getplayer(self.pid)
	local unionid = player:unionid()
	if not unionid then
		self:deltask(task.taskid,"quitunion")
		local errmsg = language.format("你已经退出公会")
		return false,errmsg
	end
	return true
end

function cpaoshangtask:failtask(task)
	self:deltask(task.taskid,"taskfail")
	local taskdata = self:getformdata("task")[task.taskid]
	openui.messagebox(self.pid,{
		type = MB_PAOSHANG_GOBACK,
		title = language.format("跑商失败"),
		content = language.format("出售所有商品，完成任务进度{1}/{2}。任务失败",
		language.untranslate(task.acutal_price),
		language.untranslate(task.standard_price)),
		buttons = {
			openui.button(language.format("取消")),
			openui.button(language.format("回归")),
		},
		attach = {npcid = taskdata.submitnpc},})
end

function cpaoshangtask:deal(task,npcid,goodsid)
	task.acutal_price = task.acutal_price + task.tasknpcdata[npcid][goodsid]
	for n,v in pairs(task.tasknpcdata) do
		if v[goodsid] then
			task.tasknpcdata[n][goodsid] = nil
		end
	end
	local goodsids = task.goodsids
	for i,v in pairs(goodsids) do
		if v == goodsid then
			task.goodsids[i] = nil
		end
	end
	if table.isempty(task.goodsids) then
		self:check(task)
	else
		local data = self:pack(task)
		data.donecnt = task.acutal_price
		data.donelimit = task.standard_price
		net.task.S2C.updatetask(self.pid,data)
	end
end

function cpaoshangtask:check(task)
	if task.acutal_price >= task.standard_price then
		self:finishtask(task,"exec")
	else
		self:failtask(task)
	end
end

function cpaoshangtask:_transaward(awardid,lv)
	if awardid < 0 then
		local fakedata = self:getformdata("fake")
		local data = fakedata[lv] or fakedata[#fakedata]
		awardid = data.awardid
	end
	local awarddata = self:getformdata("award")
	local bonus = award.getaward(awarddata,awardid,function (i,data)
		return data.ratio
	end)
	bonus = award.mergebonus(bonus)
	return bonus
end

function cpaoshangtask:transaward(task,awardid,pid)
	assert(pid == self.pid)
	local player = playermgr.getplayer(self.pid)
	local lv = player.lv
	local bonus = self:_transaward(awardid,lv)
	task.union_addmoney = bonus.union_money
	return bonus
end

function cpaoshangtask:finishtask(task,reason)
	ctaskcontainer.finishtask(self,task,reason)
	local taskdata = self:getformdata("task")[task.taskid]
	openui.messagebox(self.pid,{
		type = MB_PAOSHANG_GOBACK,
		title = language.format("跑商成功"),
		content = language.format("出售所有商品，完成任务进度{1}/{2}。任务成功",
			language.untranslate(task.acutal_price),
			language.untranslate(task.standard_price)),
		buttons = {
			openui.button(language.format("取消")),
			openui.button(language.format("回归")),
		},
		attach = {npcid = taskdata.submitnpc},})
end

function cpaoshangtask:onsubmittask(task)
	local player = playermgr.getplayer(self.pid)
	local flag = self:getflag("donecnt")
	player.today:add(flag,1)
	local donecnt = self:getdonecnt()
	local extaward = self:getformdata("var").TaskDoneAward
	for cnt,itemtype in pairs(extaward) do
		if donecnt == cnt then
			local num,surplus = player:additembytype(itemtype,1,nil,"paoshang_task",true)
			if surplus ~= 0 then
				local item = {
					type = itemtype,
					num = 1,
				}
				local attach = {items = {item},}
				mailmgr.sendmail(self.pid,{
					srcid = SYSTEM_MAIL,
					author = language.format("系统"),
					title = language.format("奖励"),
					content = language.format("奖励"),
					attach = attach,
				})
			end
		end
	end
	local msg = language.format("【{1}】完成了一次工会跑商,公会资金+{2}",
		language.untranslate(player.name),
		language.untranslate(task.union_addmoney))
	local sender = {
		pid = SENDER.UNION
	}
	local unionid = player:unionid()
	flag = "union.huodong.paoshangcnt"
	unionaux.unionmethod(unionid,":sendmsg",sender,msg)
	unionaux.unionmethod(unionid,".today:add",flag,1)
	if not self:__canaccept() or not self:reachlimit() then
		player.taskdb:update_canaccept()
	end
end

return cpaoshangtask
