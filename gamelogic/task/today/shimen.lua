--师门任务
local g_specialtask = {}

cshimentask = class("cshimentask",ctaskcontainer)

function cshimentask:init(conf)
	ctaskcontainer.init(self,conf)
	self.isautohandin = true
	self.ringnum = 1
	self.canacceptnum = 2
end

function cshimentask:__canaccept()
	local player = playermgr.getplayer(self.pid)
	if player.lv < 10 then
		return false,language.format("等级不足，无法接受")
	end
	for _,task in pairs(self.objs) do
		-- 普通师门只能接一个
		if not table.find(g_specialtask,task.taskid) then
			return false,language.format("无法重复领取该任务")
		end
	end
	return true
end

function cshimentask:can_accept(taskid)
	local isok,msg  = self:__canaccept()
	if not isok then
		return isok,msg
	end
	return ctaskcontainer.can_accept(self,taskid)
end

function cshimentask:validshow_incanaccept()
	if not self:__canaccept() then
		return false
	end
	return ctaskcontainer.validshow_incanaccept(self)
end

function cshimentask:opentask()
	local player = playermgr.getplayer(self.pid)
	if player.today:query("task.shimen.giveup") then
		local npc = data_0601_NPC[20001001]
		local silver = 100
		net.msg.S2C.npcsay(self.pid,npc,
			language.format("协会任务在今天放弃过，是否支付{1}银币再次领取",silver),
			{ 
				language.format("确认"), 
				language.format("取消"),
			},
			function(pid,request,respond)
				local player = playermgr.getplayer(pid)
				if not player or not player.today:query("task.shimen.giveup") then
					return
				end
				if respond.answer ~= 1 then
					return
				end
				local silver = request[1]
				player:oncostres({ silver = silver, },"rmshimengiveup",true,function(uid)
					local player = playermgr.getplayer(uid)
					player.today:delete("task.shimen.giveup")
					player.taskdb.shimen:opentask()
				end)
			end,
			silver
		)
		return false
	end
	return ctaskcontainer.opentask(self)
end

function cshimentask:onsubmittask(task)
	if table.find(g_specialtask,task.taskid) then
		local player = playermgr.getplayer(self.pid)
		player.thistemp:set("task.shimen.specialdone",1,3600*36)
		return
	end
	local ringlimit = self:getformdata("ringlimit")
	if self.ringnum % 10 == 0 then
		local playtype = self:getformdata("task")[task.taskid].type
		local itemtype = self:getformdata("var").RingDoneAward[playtype]
		local player = playermgr.getplayer(self.pid)
		self:log("info","task",format("[ringdoneaward] pid=%d itemtype=%d ring=%d",self.pid,itemtype,self.ringnum))
		player:additembytype(itemtype,1,nil,"shimenring",true)
		if self.ringnum == ringlimit then
			if not player.thistemp:query("task.shimen.specialdone") and ishit(50,100) then
				player.today:set("task.shimen.specialcapacity",1)
				-- TODO 通知客户端可以查看特殊任务面板
			end
		end
	end
	self.ringnum = (self.ringnum + 1) % ringlimit
	if self.ringnum == 0 then
		self.ringnum = ringlimit
	end
	navigation.addprogress(self.pid,self.name)
end

function cshimentask:transaward(task,awardid,pid)
	if awardid < 0 then
		local player = playermgr.getplayer(pid)
		local lv = math.min(player.lv,200)
		local fakedata = self:getformdata("fake")[lv]
		awardid =  fakedata.awardid[-awardid]
	end
	local bonus = ctaskcontainer.transaward(self,task,awardid,pid)
	return bonus
end

function cshimentask:transwar(task,warid,pid)
	if warid < 0 then
		local player = playermgr.getplayer(pid)
		local lv = math.min(player.lv,200)
		local fakedata = self:getformdata("fake")[lv]
		warid = fakedata.warids[-warid]
	end
	return ctaskcontainer.transwar(self,task,warid,pid)
end

function cshimentask:revisebonus(task,bonus)
	if table.find(g_specialtask,task.taskid) then
		return bonus
	end
	local promoteratio = self:getformdata("var").AwardPromoteRatio
	bonus.exp = math.floor(bonus.exp * (100 + (self.ringnum - 1) * promoteratio) / 100)
	bonus.jobexp = math.floor(bonus.jobexp * (100 + (self.ringnum - 1) * promoteratio) / 100)
	bonus.coin = math.floor(bonus.coin * (100 + (self.ringnum - 1) * promoteratio) / 100)
	return bonus
end

function cshimentask:onfivehourupdate()
	self.ringnum = 1
	ctaskcontainer.onfivehourupdate(self)
end

function cshimentask:giveuptask(taskid)
	local isok,msg = ctaskcontainer.giveuptask(self,taskid)
	if isok and not table.find(g_specialtask,taskid) then
		local player = playermgr.getplayer(self.pid)
		player.today:set("task.shimen.giveup",1)
	end
	return isok,msg
end

function cshimentask:can_directaccept(taskid)
	if not table.find(g_specialtask,taskid) then
		return false
	end	
	local player = playermgr.getplayer(self.pid)
	if not player.today:query("task.shimen.specialcapacity") then
		return false
	end
	return true
end

function cshimentask:directaccept(taskid)
	local isaccept = ctaskcontainer.directaccept(self,taskid)
	if isaccept then
		local player = playermgr.getplayer(self.pid)
		player.today:delete("task.shimen.specialcapacity")
	end
	return isaccept
end

function cshimentask:getquestionbank()
	return "data_1100_QuestionBank02"
end

return cshimentask
