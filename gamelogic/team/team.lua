cteam = class("cteam")

function cteam:init(teamid,param)
	param = param or {}
	self.teamid = teamid
	self.createtime = os.time()
	self.follow = {}
	self.leave = {}
	self.captain = 0
	self.applyers = {}
	self.target = param.target or 0
	self.minlv = param.minlv or 1
	self.maxlv = param.maxlv or MAX_LV
	self.channel = string.format("team#%s",self.teamid)
end

function cteam:onlogin(player)
	local pid = player.pid
	-- 同步申请者列表
	sendpackage(pid,"team","addapplyer",self.applyers)
	-- 同步自身队伍信息
	sendpackage(pid,"team","selfteam",{
		team = self:pack(),
	})
	-- 尝试归队
	if pid ~= self.captain then
		local captain = playermgr.getplayer(self.captain)
		if captain and captain.sceneid == player.sceneid then
			teammgr:backteam(player)
		end
	end
end

function cteam:onlogoff(player)
	-- 下线后暂离队伍，如果是队长则先切换队长
	if self.captain == player.pid then
		local newcaptain = self:choose_newcaptain()
		assert(newcaptain ~= self.captain)
		if newcaptain then
			teammgr:changecaptain(self.teamid,newcaptain)
		else
			teammgr:quitteam(player)
		end
	end
	if player.teamid then
		teammgr:leaveteam(player)
	end
end

function cteam:create(player,param)
	param = param or {}
	local pid = player.pid
	self.target = param.target or 0
	self.minlv = param.minlv or 1
	self.maxlv = param.maxlv or MAX_LV
	self.captain = pid
	player.teamid = self.teamid
	local scene = scenemgr.getscene(player.sceneid)
	local teamstate = TEAM_STATE_CAPTAIN
	scene:set(pid,{
		teamid = self.teamid,
		teamstate = teamstate,
	})
	self:broadcast(function (uid)
		sendpackage(uid,"team","selfteam",{
			team = self:pack(),
		})
	end)
end

function cteam:join(player)
	local teamid = player.teamid
	assert(teamid==nil)
	local pid = player.pid
	self:delapplyer(pid)
	player.teamid = self.teamid
	self.leave[pid] = true
	self:broadcast(function (uid)
		if uid ~= pid then
			sendpackage(uid,"team","addmember",{
				teamid = self.teamid,
				member = self:packmember(player),
			})
		end
	end)
	sendpackage(pid,"team","selfteam",{
		team = self:pack(),
	})
	local captain = playermgr.getplayer(self.captain)
	if captain and player.sceneid == captain.sceneid then
		teammgr:backteam(player)
	end
	local scene = scenemgr.getscene(player.sceneid)
	local teamstate = player:teamstate()
	scene:set(pid,{
		teamid = self.teamid,
		teamstate = teamstate,
	})
	
	channel.subscribe(self.channel,player.pid)
end

function cteam:back(player)
	local pid = player.pid
	local captain = playermgr.getplayer(self.captain)
	if not captain then
		return false
	end
	if not player:jumpto(captain.sceneid,captain.pos) then
		return false
	end
	local scene = scenemgr.getscene(captain.sceneid)
	if self.leave[pid] then
		self.leave[pid] = nil
	end
	self.follow[pid] = true
	local teamstate = player:teamstate()
	scene:set(pid,{
		teamid = self.teamid,
		teamstate = teamstate,
	})
	self:broadcast(function (uid)
		sendpackage(uid,"team","updatemember",{
			teamid = self.teamid,
			member = {
				pid = pid,
				teamstate = teamstate,
			}
		})
	end)
	return true
end

function cteam:leaveteam(player)
	local pid = player.pid
	assert(self.captain ~= pid)
	self.follow[pid] = nil
	self.leave[pid] = true
	local scene = scenemgr.getscene(player.sceneid)
	local teamstate = player:teamstate()
	scene:set(pid,{
		teamid = self.teamid,
		teamstate = teamstate,
	})
	self:broadcast(function (uid)
		sendpackage(uid,"team","updatemember",{
			teamid = self.teamid,
			member = {
				pid = pid,
				teamstate = teamstate,
			}
		})
	end)
	return true
end

function cteam:choose_newcaptain()
	local newcaptain
	if next(self.follow) then
		local pids = {}
		for pid in pairs(self.follow) do
			if playermgr.getplayer(pid) then
				table.insert(pids,pid)
			end
		end
		if not table.isempty(pids) then
			newcaptain = randlist(pids)
		end
	elseif next(self.leave) then
		local pids = {}
		for pid in pairs(self.leave) do
			if playermgr.getplayer(pid) then
				table.insert(pids,pid)
			end
		end
		if not table.isempty(pids) then
			newcaptain = randlist(pids)
		end
	end
	return newcaptain
end

function cteam:quit(pid)
	channel.unsubscribe(self.channel,pid)
	local oldcaptain = self.captain
	if oldcaptain == pid then
		local newcaptain = self:choose_newcaptain()
		if newcaptain then
			teammgr:changecaptain(self.teamid,newcaptain)
		else
			self.captain = nil
		end
	end
	self.follow[pid] = nil
	self.leave[pid] = nil
	sendpackage(pid,"team","selfteam",{})
	self:broadcast(function (uid)
		sendpackage(uid,"team","delmember",{
			teamid = self.teamid,
			pid = pid,
		})
		if self.captain ~= oldcaptain then
			sendpackage(uid,"team","updatemember",{
				teamid = self.teamid,
				member = {
					pid = self.captain,
					teamstate = TEAM_STATE_CAPTAIN,
				}
			})
		end
	end)
	local player = playermgr.getplayer(pid)
	if player then
		player.teamid = nil
		local scene = scenemgr.getscene(player.sceneid)
		scene:set(pid,{
			teamid = 0,
			teamstate = NO_TEAM,
		})
	end
	if self:len(TEAM_STATE_ALL) == 0 or self:isall_logoff() then
		teammgr:delteam(self.teamid)
	end
end

function cteam:changecaptain(pid)
	assert(self.captain~=pid)
	local oldcaptain_pid = self.captain
	local oldcaptain = playermgr.getplayer(oldcaptain_pid)
	local newcaptain = playermgr.getplayer(pid)
	if oldcaptain then
		self.follow[oldcaptain_pid] = true
	else
		self.leave[oldcaptain_pid] = true
	end
	self.captain = pid
	self.follow[pid] = nil
	self.leave[pid] = nil
	self:broadcast(function (uid)
		sendpackage(uid,"team","updatemember",{
			teamid = self.teamid,
			member = {
				pid = oldcaptain_pid,
				teamstate = self.follow[oldcaptain_pid] and TEAM_STATE_FOLLOW or TEAM_STATE_LEAVE,
			}
		})
		sendpackage(uid,"team","updatemember",{
			teamid = self.teamid,
			member = {
				pid = self.captain,
				teamstate = TEAM_STATE_CAPTAIN,
			}
		})
	end)
	if oldcaptain then
		local scene = scenemgr.getscene(oldcaptain.sceneid)
		local teamstate = oldcaptain:teamstate()
		scene:set(oldcaptain.pid,{
			teamid = self.teamid,
			teamstate = teamstate,
		})
	end
	if newcaptain then
		local scene = scenemgr.getscene(newcaptain.sceneid)
		local teamstate = newcaptain:teamstate()	
		scene:set(newcaptain.pid,{
			teamid = self.teamid,
			teamstate = teamstate,
		})
	end

end

function cteam:getapplyer(pid,ispos)
	if ispos then
		local pos = pid
		return self.applyers[pos],pos
	else
		for i,applyer in ipairs(self.applyers) do
			if applyer.pid == pid then
				return applyer,i
			end
		end
	end
end

function cteam:addapplyer(player)
	local pid = player.pid
	local applyer = self:getapplyer(pid)
	if applyer then
		net.msg.S2C.notify(player.pid,language.format("你已经申请过该队伍了"))
		return
	end
	applyer = {
		pid = pid,
		name = player.name,
		lv = player.lv,
		roletype = player.roletype,
		time = os.time(),
	}
	logger.log("info","team",format("[addapplyer] teamid=%d applyer=%s",self.teamid,applyer))
	if #self.applyers >= 10 then
		self:delapplyer(1,true)
	end
	table.insert(self.applyers,applyer)
	self:broadcast(function (uid)
		sendpackage(uid,"team","addapplyer",{applyer,})
	end)
end

function cteam:delapplyer(pid,ispos)
	local applyer,pos = self:getapplyer(pid,ispos)
	if applyer then
		logger.log("info","team",string.format("[delapplyer] teamid=%d pid=%d",self.teamid,applyer.pid))
		table.remove(self.applyers,pos)
		self:broadcast(function (uid)
			sendpackage(uid,"team","delapplyer",{pid,})
		end)
	end
end

function cteam:clearapplyer()
	for pos = #self.applyers,1,-1 do
		self:delapplyer(pos,true)
	end
end

function cteam:teamstate(pid)
	if self.captain == pid then
		return TEAM_STATE_CAPTAIN
	elseif self.follow[pid] then
		return TEAM_STATE_FOLLOW
	elseif self.leave[pid] then
		return TEAM_STATE_LEAVE
	end
	return NO_TEAM
end

-- player : 1--player object,2 -- resume object
function cteam:packmember(player)
	return {
		pid = player.pid,
		name = player.name,
		lv = player.lv,
		roletype = player.roletype,
		teamstate = self:teamstate(player.pid),	
	}
end

function cteam:packmembers()
	local captain = playermgr.getplayer(self.captain)
	if not captain then
		captain = resumemgr.getresume(self.captain)
	end
	local members = {}
	table.insert(members,self:packmember(captain))
	for pid,_ in pairs(self.follow) do
		local member = playermgr.getplayer(pid)
		if not member then
			member = resumemgr.getresume(pid)
		end
		table.insert(members,self:packmember(member))
	end
	for pid,_ in pairs(self.leave) do
		local member = playermgr.getplayer(pid)
		if not member then
			member = resumemgr.getresume(pid)
		end
		table.insert(members,self:packmember(member))
	end
	return members
end

function cteam:pack()
	return {
		teamid = self.teamid,
		target = self.target,
		minlv = self.minlv,
		maxlv = self.maxlv,
		members = self:packmembers(),
		automatch = teammgr.automatch_teams[self.teamid] and true or false,
	}
end

function cteam:broadcast(func)
	func(self.captain)
	for pid,_ in pairs(self.follow) do
		func(pid)
	end
	for pid,_ in pairs(self.leave) do
		func(pid)
	end
end

function cteam:ismember(pid)
	if self.captain == pid then
		return true
	end
	if self.follow[pid] then
		return true
	end
	if self.leave[pid] then
		return true
	end
	return false
end

function cteam:members(teamstate)
	local pids = {}
	if teamstate == TEAM_STATE_CAPTAIN then
		pids = {self.captain,}
	elseif teamstate == TEAM_STATE_FOLLOW then
		pids = table.keys(self.follow)
	elseif teamstate == TEAM_STATE_LEAVE then
		pids = table.keys(self.leave)
	elseif teamstate == TEAM_STATE_CAPTAIN_FOLLOW then
		pids = {self.captain}
		table.extend(pids,table.keys(self.follow))
	elseif teamstate == TEAM_STATE_ALL then
		pids = {self.captain}
		for uid,_ in pairs(self.follow) do
			table.insert(pids,uid)
		end
		for uid,_ in pairs(self.leave) do
			table.insert(pids,uid)
		end
	else
		assert("invalid team state:" .. tostring(teamstate))
	end
	return pids
end

function cteam:len(teamstate)
	local pids = self:members(teamstate)
	return #pids
end

-- 最大人数
function cteam:maxlen()
	local target = self.target
	if not target or target == 0 then
		return 5
	end
	return data_0301_TeamTarget[target].maxlen or 5
end

function cteam:isall_logoff()
	if self.captain then
		if playermgr.getplayer(self.captain) then
			return false
		end
	end
	for pid in pairs(self.follow) do
		if playermgr.getplayer(pid) then
			return false
		end
	end
	for pid in pairs(self.leave) do
		if playermgr.getplayer(pid) then
			return false
		end
	end
	return true
end

return cteam