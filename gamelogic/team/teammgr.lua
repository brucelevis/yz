cteammgr = class("cteammgr")

function cteammgr:init()
	self.teamid = 0
	self.teams = {}
	self.automatch_pids = {}
	self.automatch_teams = {}
	self.publish_teams = {}
end

function cteammgr:clear()
	self.teams = {}
	self.automatch_pids = {}
	self.authmatch_teams = {}
	self.publish_teams = {}
end

function cteammgr:onlogin(player)
	local teamid = player:getteamid()
	if teamid then
		local team = self:getteam(teamid)
		if team then
			team:onlogin(player)
		end
	end
end

function cteammgr:onlogoff(player)
	local teamid = player:getteamid()
	if teamid then
		local team = self:getteam(teamid)
		if team then
			team:onlogoff(player)
		end
	end
end

function cteammgr:publishteam(player,param)
	local teamid = player:getteamid()
	if not teamid then
		return
	end
	local pid = player.pid
	local team = self:getteam(teamid)
	if team.captain ~= pid then
		return
	end
	logger.log("info","team",format("[publishteam] pid=%d teamid=%s param=%s",pid,teamid,param))
	team.target = param.target
	team.lv = param.lv
	local now = os.time()
	local data = data_0301_TeamTarget[team.target]
	local lifetime = data.lifetime or 300
	self.publish_teams[teamid] = {
		time = now,
		lifetime = lifetime,
	}
	local package = self:pack_publishteam(teamid)
	playermgr.broadcast(function (obj)
		sendpackage(obj.pid,"team","publishteam",package)
	end)
end

function cteammgr:pack_publishteam(teamid)
	local publish = self.publish_teams[teamid]
	local team = self:getteam(teamid)
	local captain = playermgr.getplayer(team.captain)
	if not captain then
		captain = resumemgr.getresume(team.captain)
	end
	local package = {
		teamid = team.teamid,
		time = publish.time,
		target = team.target,
		lv = team.lv,
		captain = team:packmember(captain),
	}
	return package
end

function cteammgr:delpublishteam(teamid)
	local publish = self.publish_teams[teamid]
	if publish then
		logger.log("info","team",string.format("[delpublishteam] teamid=%d",teamid))
		self.publish_teams[teamid] = nil
	end
end

function cteammgr:starttimer_check_publishteam()
	timer.timeout("timer.check_publishteam",60,functor(self.starttimer_check_publishteam,self))
	local now = os.time()
	for teamid,publish in pairs(self.publish_teams) do
		if publish.lifetime and publish.lifetime + publish.time > now then
			self:delpublishteam(teamid)
		end
	end
end


function cteammgr:genid()
	if self.teamid >= MAX_NUMBER then
		self.teamid = 0
	end
	self.teamid = self.teamid + 1
	return self.teamid
end


function cteammgr:createteam(player,param)
	local teamid = player:getteamid()
	if teamid then
		return
	end
	local pid = player.pid
	if not self:before_createteam(player,param) then
		return
	end
	teamid = self:genid()
	logger.log("info","team",format("[createteam] pid=%d teamid=%d param=%s",pid,teamid,param))
	local team = cteam.new(teamid,{})
	team:create(player,param)
	self:addteam(teamid,team)
	-- TODO: modify
	local default_automatch = 1
	if default_automatch == 1 then
		self:team_automatch(teamid)
	end
	self:after_createteam(player,teamid)
	return teamid,team
end

-- 解散队伍接口不应该支持，只会引入复杂性
function cteammgr:dismissteam(player)
	if true then
		return
	end
	local teamid = player:getteamid()
	if not teamid then
		return
	end
	local pid = player.pid
	if not self:before_dismissteam(player,teamid) then
		return false
	end
	logger.log("info","team",string.format("[dismissteam] pid=%d teamid=%d",pid,teamid))

	local team = self:getteam(teamid)
	if not team then
		return
	end
	self:delteam(teamid)
	self:after_dismissteam(player,teamid)
	return true
end

function cteammgr:jointeam(player,teamid)
	if player:getteamid() then
		return
	end
	local team = self:getteam(teamid)
	if not team then
		return
	end
	local pid = player.pid
	if not self:before_jointeam(player,teamid) then
		return false
	end
	logger.log("info","team",string.format("[jointeam] pid=%d teamid=%d",pid,teamid))
	team:join(player)
	self:unautomatch(pid,"jointeam")
	self:after_jointeam(player,teamid)
	return true
end

function cteammgr:quitteam(player)
	local teamid = player:getteamid()
	if not teamid then
		return
	end
	local pid = player.pid
	if not self:before_quitteam(player,teamid) then
		return false
	end
	logger.log("info","team",string.format("[quitteam] pid=%d teamid=%d",pid,teamid))
	local team = self:getteam(teamid)
	team:quit(player.pid)
	self:after_quitteam(player.pid,teamid)
	return true
end

function cteammgr:kickmember(player,targetid)
	local pid = player.pid
	local teamid = player:getteamid()
	if not teamid then
		return
	end
	local team = teammgr:getteam(teamid)
	if team.captain ~= pid then
		return
	end
	logger.log("info","team",string.format("[kickmember] pid=%d teamid=%d targetid=%d",pid,teamid,targetid))
	team:quit(targetid)
	self:after_quitteam(targetid,teamid)
end

-- 暂离队伍
function cteammgr:leaveteam(player)
	local teamid = player:getteamid()
	if not teamid then
		return
	end
	local pid = player.pid
	local team = self:getteam(teamid)
	if team.captain == pid then
		return
	end
	if team.leave[pid] then
		return
	end
	if not self:before_leaveteam(player,teamid) then
		return false
	end
	logger.log("info","team",string.format("[leaveteam] pid=%d teamid=%d",pid,teamid))
	team:leaveteam(player)
	self:after_leaveteam(player,teamid)
	return true

end

function cteammgr:backteam(player)
	local teamid = player:getteamid()
	if not teamid then
		return
	end
	local pid = player.pid
	local team = self:getteam(teamid)
	if not team then
		return
	end
	if not team.leave[pid] then
		return
	end
	if not self:before_backteam(player,teamid) then
		return false
	end
	logger.log("info","team",string.format("[backteam] pid=%d teamid=%d",pid,teamid))
	team:back(player)
	self:after_backteam(player,teamid)
	return true
end

function cteammgr:getteam(teamid)
	return self.teams[teamid]
end

function cteammgr:addteam(teamid,team)
	assert(self.teams[teamid] == nil,"repeat teamid:" .. tostring(teamid))
	self.teams[teamid] = team
	channel.add(team.channel)
end

function cteammgr:delteam(teamid)
	local team = self:getteam(teamid)
	if team then
		channel.del(team.channel)
		for pid,_ in pairs(team.leave) do
			team:quit(pid)
		end
		for pid,_ in pairs(team.follow) do
			team:quit(pid)
		end
		if team.captain then
			team:quit(team.captain)
		end
		logger.log("info","team",string.format("[delteam] teamid=%d",teamid))
		self.teams[teamid] = nil
		self:team_unautomatch(teamid,"delteam")
		return team
	end
end

function cteammgr:changecaptain(teamid,tid)
	local team = self:getteam(teamid)
	local team = self:getteam(teamid)
	if not self:before_changecaptain(teamid,tid) then
		return false
	end
	logger.log("info","team",string.format("[changecaptain] teamid=%d captain=%d->%d",teamid,team.captain,tid))
	team:changecaptain(tid)
	self:after_changecaptain(teamid,tid)
	return true
end

function cteammgr:changetarget(player,target,lv)
	local teamid = player:getteamid()
	if not teamid then
		return
	end
	local team = self:getteam(teamid)
	if team.captain ~= player.pid then
		return
	end
	logger.log("info","team",string.format("[changetarget] teamid=%s target=%s lv=%s",teamid,target,lv))
	team.target = target
	team.lv = lv
end


function cteammgr:automatch(player,target,lv)
	local pid = player.pid
	lv = lv or player.lv
	logger.log("info","team",string.format("[automatch] pid=%d target=%s lv=%s",pid,target,lv))
	self.automatch_pids[pid] = {
		time = os.time(),
		pid = pid,
		name = player.name,
		lv = lv,
		roletype = player.roletype,
		target = target,
	}
end

function cteammgr:unautomatch(pid)
	local matchdata = self.automatch_pids[pid]
	if matchdata then
		logger.log("info","team",string.format("[unautomatch] pid=%d reason=%s",pid,reason))
		self.automatch_pids[pid] = nil
	end
end

function cteammgr:team_automatch(teamid)
	local team = self:getteam(teamid)
	if not team then
		return
	end
	logger.log("info","team",string.format("[team_automatch] teamid=%s",teamid))
	self.automatch_teams[teamid] = {
		time = os.time(),
	}
end

function cteammgr:team_unautomatch(teamid,reason)
	local matchdata = self.automatch_teams[teamid]
	if matchdata then
		logger.log("info","team",string.format("[team_unautomatch] teamid=%d reason=%s",teamid,reason))
		self.automatch_teams[teamid] = nil
	end
end

function cteammgr:check_match_team(player)
	local pid = player.pid
	local matchdata = self.automatch_pids[pid]
	if not matchdata then
		return
	end
	local match_teams = {}
	for teamid,v in pairs(self.automatch_teams) do
		local team = self:getteam(teamid)
		if team then
			if team:len(TEAM_STATE_ALL) < team:maxlen() then
				if team.target == matchdata.target then
					local team_target_data = data_0301_TeamTarget[team.target]
					local maxlv = team.lv + team_target_data.up_float
					local minlv = team.lv + team_target_data.down_float
					if minlv <= matchdata.lv and matchdata.lv <= maxlv then
						table.insert(match_teams,teamid)
					end
				end
			end
		else
			self:team_unautomatch(teamid,"invalid_team")
		end
	end
	if not next(match_teams) then
		return
	end
	local lv = player.lv
	table.sort(match_teams,function (teamid1,teamid2)
		local match1 = self.match_teams[teamid1]
		local match2 = self.match_teams[teamid2]
		local team1 = self:getteam(teamid1)
		local team2 = self:getteam(teamid2)
		local len1 = team1:len(TEAM_STATE_ALL)
		local len2 = team2:len(TEAM_STATE_ALL)
		if len1 > len2 then
			return true
		end
		if len1 == len2 and
			math.abs(team1.lv-lv) < math.abs(team2.lv-lv) then
			return true
		end
		if len1 == len2 and 
			math.abs(team1.lv-lv) == math.abs(team2.lv-lv) and
			match1.time < match2.time then
			return true
		end
		return false
	end)
	local teamid = match_teams[1]
	self:jointeam(player,teamid)
end


function cteammgr:starttimer_automatch()
	timer.timeout("timer.automatch",10,functor(self.starttimer_automatch,self))
	local cnt = 0
	for pid,v in pairs(self.automatch_pids) do
		local player = playermgr.getplayer(pid)
		if player then
			cnt = cnt + 1
			self:check_match_team(player)
			if cnt >= 20 then
				break
			end
		end
	end
end

function cteammgr:packteam(teamid)
	local team = self:getteam(teamid)
	return team:pack()
end

function cteammgr:before_createteam(player,param)
	return true
end

function cteammgr:after_createteam(player,teamid)
end

function cteammgr:before_jointeam(player,teamid)
	return true
end

function cteammgr:after_jointeam(player,teamid)
end

function cteammgr:before_leaveteam(player,teamid)
	return true
end

function cteammgr:after_leaveteam(player,teamid)
	huodongmgr.onleaveteam(player,teamid)
end

function cteammgr:before_backteam(player,teamid)
	return true
end

function cteammgr:after_backteam(player,teamid)
	huodongmgr.onbackteam(player,teamid)
end

function cteammgr:before_changecaptain(teamid,pid)
	return true
end

function cteammgr:after_changecaptain(teamid,pid)
end

function cteammgr:before_quitteam(player,teamid)
	return true
end

-- 踢出成员也会走这里接口
function cteammgr:after_quitteam(pid,teamid)
	local player = playermgr.getplayer(pid)
	if player then
		huodongmgr.onquitteam(player,teamid)
	end
end


function cteammgr.startgame()
	teammgr = cteammgr.new()
	teammgr:starttimer_automatch()
	teammgr:starttimer_check_publishteam()
end

return cteammgr
