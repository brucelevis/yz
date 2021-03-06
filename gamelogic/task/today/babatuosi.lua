-- 巴巴托斯之赏
cbabatuositask = class("cbabatuositask",ctaskcontainer)

function cbabatuositask:init(conf)
	ctaskcontainer.init(self,conf)
	self.is_teamsubmit = true
	self.is_teamsync = true
end

function cbabatuositask:__canaccept()
	local player = playermgr.getplayer(self.pid)
	local needlv = self:getformdata("var").StartWarNeedLv
	if player.lv < needlv then
		return false,language.format("等级不足，无法接受")
	end
	return true
end

function cbabatuositask:can_accept(taskid)
	local isok,msg = self:__canaccept()
	if not isok then
		return isok,msg
	end
	return ctaskcontainer.can_accept(self,taskid)
end

function cbabatuositask:validshow_incanaccept()
	if not self:__canaccept() then
		return false
	end
	return ctaskcontainer.validshow_incanaccept(self)
end

function cbabatuositask:can_raisewar()
	local player = playermgr.getplayer(self.pid)
	local fighters,errmsg = player:getfighters()
	if table.isempty(fighters) then
		return false,errmsg
	end
	local needlv = self:getformdata("var").StartWarNeedLv
	for i,uid in ipairs(fighters) do
		local member = playermgr.getplayer(uid)
		if member.lv < needlv then
			return false,language.format("#<G>{1}#等级不足#<R>{2}#级",member:getname(),needlv)
		end
	end
	return true
end

function cbabatuositask:transwar(task,warid,pid)
	assert(pid == self.pid)
	local war = ctaskcontainer.transwar(self,task,warid,pid)
	local player = playermgr.getplayer(pid)
	if warid < 0 then
		local lv
		if player:teamstate() == TEAM_STATE_CAPTAIN then
			lv = player:team_avglv(TEAM_STATE_CAPTAIN_FOLLOW)
		else
			lv = player.lv
		end
		local fakedata = self:getformdata("fake")
		local data = fakedata[lv] or fakedata[#fakedata]
		warid = data.warids[-warid]
	end
	war.wardataid = warid
	war.wartype = WARTYPE.PVE_SHARE_TASK
	return war
end

function cbabatuositask:_transaward(awardid,lv)
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

function cbabatuositask:transaward(task,awardid,pid)
	assert(pid == self.pid)
	local player = playermgr.getplayer(self.pid)
	local lv = player:team_avglv(TEAM_STATE_CAPTAIN_FOLLOW)
	local bonus = self:_transaward(awardid,lv)
	return bonus
end

function cbabatuositask:nexttask(taskid,reason)
	local donelimit = self:getdonelimit()
	local donecnt = self:getdonecnt()
	if donecnt >= donelimit then
		openui.messagebox(self.pid,{
			type = MB_SHIMOSHILIAN_REACHLIMIT,
			title = language.format("宝图任务"),
			content = language.format("今天已经没有藏宝图的线索了，请明天再来。"),
			buttons = {
				openui.button(language.format("确认")),
			}
		},function()
			return
		end)
		local player = playermgr.getplayer(self.pid)
		player.taskdb:update_canaccept()
		return
	end
	local next_taskid,errmsg
	if self._next_taskid then
		next_taskid = self._next_taskid
		self._next_taskid = nil
	else
		next_taskid,errmsg = ctaskcontainer.nexttask(self,taskid,reason)
	end
	if next_taskid and reason == "submittask" then
		local player = playermgr.getplayer(self.pid)
		local flag = self:getflag("nexttask")
		player.today:set(flag,1)
	end
	return next_taskid,errmsg
end

function cbabatuositask:onwarend(war,result)
	local player = playermgr.getplayer(self.pid)
	local donelimit = self:getdonelimit()
	local donecnt = self:getdonecnt()
	if warmgr.iswin(result) and donecnt < donelimit then
		local flag = self:getflag("ratio")
		local flag2 = self:getflag("isget")
		local isget = player.today:query(flag2)
		local vardata = self:getformdata("var")
		if not isget then
			local ratio = player.today:query(flag)
			if not ratio then
				local startdropitemratio = vardata.StartDropItemRatio or 50
				player.today:set(flag,startdropitemratio)
				ratio = startdropitemratio
			end
			local maxdropitemratio = vardata.MaxDropItemRatio or 100
			if not ishit(ratio,maxdropitemratio) then
				local adddropitemratio = vardata.AddDropItemRatio or 10
				ratio = ratio + adddropitemratio
				player.today:set(flag,ratio)
				net.msg.S2C.notify(self.pid,language.format("未掉落藏宝图，请继续寻找"))
			else
				player.today:set(flag2,1)
				local additembytype = vardata.AddItemId or 601001
				local additemnum = vardata.AddItemNum or 1
				local additembind = vardata.AddItemBind or 0
				player:additembytype(additembytype,additemnum,additembind,"babatuosi",true)
				net.msg.S2C.notify(self.pid,language.format("获得【藏宝图】*1,今天已获得藏宝图{1}/{2}",(donecnt + 1),donelimit))
				navigation.addprogress(self.pid,self.name)
			end
		end
	end
	ctaskcontainer.onwarend(self,war,result)
end

function cbabatuositask:onsubmittask(task)
	local player = playermgr.getplayer(self.pid)
	local flag = self:getflag("isget")
	local isget = player.today:query(flag)
	if isget then
		player.today:delete(flag)
	else
		local flag2 = self:getflag("donecnt")
		local donecnt = player.today:query(flag2)
		player.today:set(flag2,(donecnt-1))
	end
end

function cbabatuositask:accepttask(taskid)
	local player = playermgr.getplayer(self.pid)
	local flag = self:getflag("nexttask")
	local isnexttask = player.today:query(flag)
	if isnexttask then
		self.is_teamsync = false
		player.today:delete(flag)
	end
	ctaskcontainer.accepttask(self,taskid)
	self.is_teamsync = true
end

return cbabatuositask
