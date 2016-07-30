guajimgr = guajimgr or {}
guajimgr.STATE_LEADER_PATROL = 1
guajimgr.STATE_SOLO_PATROL = 0
guajimgr.STATE_FOLLOW_PATROL = 2
guajimgr.WARTYPE_GUAJI = 4
guajimgr.time = {}
guajimgr.member = {}

function guajimgr.getteam(player)
	local teamid = player:getteamid()
	if not teamid then
		return false
	end
	return teammgr:getteam(teamid)

end

function guajimgr.checklv(player)
	local scene = scenemgr.getmap(player.sceneid)
	if  player.lv < scene.needlv then
		net.msg.S2C.notify(player.pid,language.format("等级不足"))
		return false
	end
	return true
end

function guajimgr.checkleader(player)
	if not player:getteamid() then
		return false
	end
	if not (player:teamstate() == TEAM_STATE_CAPTAIN) 
	    and not (guajimgr.member[player.pid] == guajimgr.STATE_LEADER_PATROL) then
			net.msg.S2C.notify(player.pid,language.format("你不是队长"))
			return false
	end
	return true
end

function guajimgr.checkmap(player)
	if not player.sceneid then
		return false
	end
	--test
	if not (100 > player.sceneid) then
		net.msg.S2C.notify(player.pid,language.format("此地无法挂机"))
		return false
	end
	return true
end

--挂机中离开队伍并且检查是否队长，若是队长则把队长让给下一个人
function guajimgr.leaveteam(player)
	local teamid = player:getteamid()
	if not teamid then
		return
	end
	if player:teamstate() == NO_TEAM and
		guajimgr.member[player.pid] == guajimgr.STATE_SOLO_PATROL then
		return
	end
	if guajimgr.checkleader(player) then
		local team = guajimgr.getteam(player)
		local pids = team:members(TEAM_STATE_FOLLOW)
		for _,pid in ipairs(pids) do
			if not (pid == player.pid) then
				local teammember = playermgr.getplayer(pid)
				guajimgr.member[teammember.pid] = TEAM_STATE_CAPTAIN
				teammgr:changecaptain(teamid,teammember.pid)
				guajimgr.member[teammember.pid] = guajimgr.STATE_LEADER_PATROL
				teammgr:quitteam(player)
				guajimgr.member[player.pid] = nil
				guajimgr.time[player.pid] = nil
				return
			end
		end
	end
	teammgr:quitteam(player)
	guajimgr.member[player.pid] = nil
end

function guajimgr.jointeam(player,teamid)
	if player:getteamid() then
		return
	end
	if not teamid then
		return
	end
	if not guajimgr.checklv(player) then
		return
	end
	if not guajimgr.checkmap(player) then
		return
	end
	team = teammgr:getteam(teamid)
	if not (guajimgr.member[team.captain] == guajimgr.STATE_LEADER_PATROL) then
		return
	end
	teammgr:jointeam(player,teamid)
	guajimgr.member[player.pid] = guajimgr.STATE_FOLLOW_PATROL
end

--队长开启挂机状态为STATE_LEADER_PATROL
--队员状态为STATE_FOLLOW_PATROL
--单人开启挂机状态为STATE_SOLO_PATROL
function guajimgr.leaderonguaji(player)
	if not guajimgr.checkmap(player) then
		return
	end
	if not guajimgr.checklv(player) then
		return
	end
	if guajimgr.checkleader(player) then
		local pid
		local team = guajimgr.getteam(player)
		local pids = team:members(TEAM_STATE_FOLLOW)
		for _,pid in ipairs(pids) do
			if not (pid == player.pid) then
				local teammember = playermgr.getplayer(pid)
				if not teammember then
					return
				end
				if not guajimgr.checklv(teammember) then
					net.msg.S2C.notify(player.pid,language.format("队员等级不足"))
					return
				end
				guajimgr.member[teammember.pid] = guajimgr.STATE_FOLLOW_PATROL
			end
		end
		guajimgr.member[player.pid] = guajimgr.STATE_LEADER_PATROL
	else if player:teamstate() == NO_TEAM then
		guajimgr.member[player.pid] = guajimgr.STATE_SOLO_PATROL
		end
	end
end

--队长关闭挂机恢复状态为TEAM_STATE_CAPTAIN
--队员恢复为TEAM_STATE_FOLLOW
--单人关闭挂机恢复状态为NO_TEAM
function guajimgr.leaderoffguaji(player)
	local pid
	if guajimgr.checkleader(player) then
		local team = guajimgr.getteam(player)
		local pids = team:members(TEAM_STATE_FOLLOW)
		for _,pid in ipairs(pids) do
			local teammember = playermgr.getplayer(pid)
			if not teammember then
				return
			end
			guajimgr.member[teammember.pid] = nil
		end
		guajimgr.time[player.pid] = nil
	else if guajimgr.member[player.pid] == guajimgr.STATE_SOLO_PATROL then
		guajimgr.member[player.pid] = nil
		end
	end
end

--进入战斗
function guajimgr.onwar(player)
	if not guajimgr.member[player.pid] or
		guajimgr.member[player.pid] == guajimgr.STATE_FOLLOW_PATROL then
		return
	end
	--距离上次战斗结束时间不得小于五秒
	if guajimgr.time[player.pid] and
		(guajimgr.time[player.pid] - os.time()) < 5 then
		return
	end
	local pid
	if guajimgr.checkleader(player) then
		local team = guajimgr.getteam(player)
		attackers = {player.pid,}
		table.extend(attackers,team:members(TEAM_STATE_FOLLOW))
	end
	if player:teamstate() == NO_TEAM then
		attackers = {player.pid}
	end
	local war = {}
	--test
	war.wartype = guajimgr.WARTYPE_GUAJI
	if not warmgr.can_startwar(attackers,{},war) then
		return
	end
	warmgr.startwar(attackers,{},war)
end



--结束战斗
function guajimgr.warend(player)
	if not player.warid then
		return
	end
	warmgr.onwarend(player.warid,result)
	guajimgr.time[player.pid] = os.time()
end

--检查血量，并在HP低于百分之五十时使用道具
function guajimgr.checkhp(player)
	--判断血量，低于百分之五十为真
	--test
	return true
end

--战斗结束后自动使用道具恢复
--无道具可消耗时，停止挂机并且脱离队伍(有的话)
function guajimgr.useitem(player,itmeid)
	local itemnum = player.itemdb:getnumbytype(itemid)
	if itemnum <= 0 then
		guajimgr.leaveteam(player)
		return
	end
	local request = net.item.C2S
	local re = {}
	re.num = 1
	re.itemid = itemid
	while(not guajimgr.checkhp(player))
		do
			request.useitem(player,re)
	end
end

