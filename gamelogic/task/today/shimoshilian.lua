-- 使魔试炼
cshimoshiliantask = class("cshimoshiliantask",ctaskcontainer)

function cshimoshiliantask:init(conf)
	ctaskcontainer.init(self,conf)
	self.ringnum = 1
	self.is_teamsubmit = true
	self.is_teamfinish = true
	self.is_teamsync = true
end

function cshimoshiliantask:onfivehourupdate()
	self.ringnum = 1
	self.lasttaskid = nil
	self:refreshtask(self.nowtaskid)
	ctaskcontainer.onfivehourupdate(self)
end

function cshimoshiliantask:opentask()
	local player = playermgr.getplayer(self.pid)
	if player:teamstate() ~= TEAM_STATE_CAPTAIN then
		net.msg.S2C.notify(self.pid,language.format("本任务需要组队后才能进行"))
		return
	end
	local fighters,errmsg = player:getfighters()
	if table.isempty(fighters) then
		net.msg.S2C.notify(self.pid,errmsg)
		return
	end
	local neednum = self:getformdata("var").StartWarNeedNum
	if #fighters < neednum then
		net.msg.S2C.notify(self.pid,language.format("队伍人数不足#<R>#{1}人",neednum))
		return
	end
	ctaskcontainer.opentask(self)
end

function cshimoshiliantask:can_execute(task)
	local player = playermgr.getplayer(self.pid)
	if player:teamstate() ~= TEAM_STATE_CAPTAIN then
		return false,language.format("本任务需要组队后才能进行")
	end
	local fighters,errmsg = player:getfighters()
	if table.isempty(fighters) then
		return false,errmsg
	end
	local neednum = self:getformdata("var").StartWarNeedNum
	local needlv = self:getformdata("var").StartWarNeedLv
	if #fighters < neednum then
		return false,language.format("队伍人数不足#<R>#{1}人",neednum)
	end
	for i,uid in ipairs(fighters) do
		local member = playermgr.getplayer(uid)
		local isok,msg = ctaskcontainer.can_execute(member.taskdb.shimoshilian,task)
		if not isok then
			return false,msg
		end
		if member.lv < needlv then
			return false,language.format("#<G>{1}#等级不足#<R>{2}#级",member:getname(),needlv)
		end
	end
	return true
end

function cshimoshiliantask:transwar(task,warid,pid)
	assert(pid == self.pid)
	local war = ctaskcontainer.transwar(self,task,warid,pid)
	local player = playermgr.getplayer(pid)
	if warid < 0 then
		local lv = player:team_avglv(TEAM_STATE_CAPTAIN_FOLLOW)
		local fakedata = self:getformdata("fake")
		local data = fakedata[lv] or fakedata[#fakedata]
		warid = data.warids[-warid]
	end
	war.wardataid = warid
	war.wartype = WARTYPE.PVE_SHARE_TASK
	return war
end

function cshimoshiliantask:_transaward(awardid,lv)
	if awardid < 0 then
		local fakedata = self:getformdata("fake")
		local data = fakedata[lv] or fakedata[#fakedata]
		awardid = data.awardid
	end
	local awarddata = self:getformdata("award")
	local bonus = award.getaward(awarddata,awardid,function (i,data)
		return data.ratio
	end)
	local ringlimit = self:getformdata("ringlimit")
	bonus = award.mergebonus(bonus)
	return bonus
end

function cshimoshiliantask:transaward(task,awardid,pid)
	assert(pid == self.pid)
	local player = playermgr.getplayer(self.pid)
	local lv = player:team_avglv2(TEAM_STATE_CAPTAIN_FOLLOW)
	local teamstate = player:teamstate()
	local ringlimit = self:getformdata("ringlimit")
	local bonus = self:_transaward(awardid,lv)
	if self.ringnum == ringlimit then
		local items = self:getformdata("var").GiveItemToMemberAt10Ring
		local item = randlist(items)
		table.insert(bonus.items,item)
	end
	-- 队长经验加成
	if teamstate == TEAM_STATE_CAPTAIN then
		if self.teamid ~= player:teamid() then
			self.captaincnt = 0
		end
		self.teamid = player:teamid()
		self.captaincnt = self.captaincnt + 1
		if self.captaincnt == ringlimit then
			self.captaincnt = 0
			if not bonus.items then
				bonus.items = {}
			end
			local item = self:getformdata("var").GiveItemToCaptainAt10Ring
			table.insert(bonus.items,item)
		end
	end
	local isok,exp_addn,detail = player:has_exp_addn(self.name,bonus.exp)
	if isok and exp_addn > 0 then
		-- tips ?
		bonus.exp = bonus.exp + exp_addn
	end
	return bonus
end

function cshimoshiliantask:nexttask(taskid,reason)
	local donelimit = self:getdonelimit()
	local donecnt = self:getdonecnt()
	local ringlimit = self:getformdata("ringlimit")
	local look_npctype = self:getformdata("var").LookNpcType
	local leftcnt = math.max(0,donelimit-donecnt)
	if donecnt >= donelimit and not self.requested then
		openui.messagebox(self.pid,{
			type = MB_SHIMOSHILIAN_REACHLIMIT,
			title = language.format("次数耗尽"),
			content = language.format("【使魔试炼】次数耗尽，继续任务将不会获得奖励。\n剩余次数:0次"),
			buttons = {
				openui.button(language.format("确认")),
			}
		})
		return
	end
	if reason ~= "opentask" and self.ringnum == 1 then
		local player = playermgr.getplayer(self.pid)
		if player and player:teamstate() == TEAM_STATE_CAPTAIN then
			openui.messagebox(self.pid,{
				type = MB_SHIMOSHILIAN_10_RING,
				title = language.format("任务完成"),
				content = language.format("已完成{1}环【使魔试炼】。\n剩余次数：{2}次",ringlimit,leftcnt),
				buttons = {
					openui.button(language.format("取消")),
					openui.button(language.format("继续")),
				},
				attach = {npctype=look_npctype},
			})
		end
		return
	end
	self.requested = nil
	local next_taskid,errmsg
	if self._next_taskid then
		next_taskid = self._next_taskid
		self._next_taskid = nil
	else
		next_taskid,errmsg = ctaskcontainer.nexttask(self,taskid,reason)
	end
	return next_taskid,errmsg
end

function cshimoshiliantask:onsubmittask(task)
	local ringlimit = self:getformdata("ringlimit")
	self.ringnum = (self.ringnum + 1) % ringlimit
	if self.ringnum == 0 then
		self.ringnum = ringlimit
	end
	navigation.addprogress(self.pid,self.name)
end

function cshimoshiliantask:quick_finish()
	local player = playermgr.getplayer(self.pid)
	local donecnt = self:getdonecnt()
	local donelimit = self:getdonelimit()
	local leftcnt = donelimit - donecnt
	local need_leftcnt = self:getformdata("var").QuickFinishNeedLeftCnt
	local needitem = self:getformdata("var").QuickFinishNeedItem
	local reason = "quick_finish"
	local chinesename = self:getformdata("name")
	if leftcnt < need_leftcnt then
		net.msg.S2C.notify(self.pid,language.format("{1}剩余次数不足{2}次，无法使用封魔卷",chinesename,need_leftcnt))
		return
	end
	local itemdb = player:getitemdb(needitem.type)
	local hasnum = itemdb:getnumbytype(needitem.type)
	if hasnum < needitem.num then
		net.msg.S2C.notify(self.pid,language.format("物品数量不足"))
		return
	end
	itemdb:costitembytype(needitem.type,needitem.num,reason)
	local bonuss = {}
	local cnt = 10
	for i=1,cnt do
		local tasktable = self:getformdata(self.name,"task")
		local taskid = randlist(table.keys(tasktable))
		local taskdata = tasktable[taskid]
		local bonus = self:_transaward(taskdata.award,player.lv)
		bonus.items = nil
		bonus.pets = nil
		-- 双倍点经验加成
		local isok,dexp_addn = player:has_dexp_addn(self.name,bonus.exp)
		if isok and dexp_addn > 0 then
			bonus.exp = bonus.exp + dexp_addn
		end
		table.insert(bonuss,bonus)
	end
	local bonus = award.mergebonus(bonuss)
	doaward("player",self.pid,bonus,reason,true)
end

return cshimoshiliantask
