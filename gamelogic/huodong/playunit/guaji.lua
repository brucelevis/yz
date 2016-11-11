playunit_guaji = playunit_guaji or {}
huodongmgr.playunit.guaji = playunit_guaji

playunit_guaji.UNGUAJI_STATE = 0
playunit_guaji.GUAJI_STATE = 1

function playunit_guaji.onlogin(player)
	-- onenter场景后会修正挂机状态
	local state = playunit_guaji.getstate(player)
	sendpackage(player.pid,"guaji","state",{state=state})
end

function playunit_guaji.onlogoff(player,reason)
	if reason == "replace" then
		return
	end
	playunit_guaji.setstate(player,playunit_guaji.UNGUAJI_STATE)
end

function playunit_guaji.isguajimap(mapid)
	local map = data_1100_GuaJiMap[mapid]
	if map then
		return true,map
	end
end

function playunit_guaji.canenter(player,sceneid,pos)
	local scene = scenemgr.getscene(sceneid)
	local isok,map = playunit_guaji.isguajimap(scene.mapid)
	-- 非挂机地图不检
	if not isok or true then   -- 现在所有地图都可以挂机，因此
		return true
	end
	if player.lv < map.openlv then
		return false,language.format("#<R>{1}#级后开放#<R>{2}#地图",map.openlv,map.name)
	end
	local members = player:getfighters()
	for i,uid in ipairs(members) do
		if uid ~= player.pid then
			local member = playermgr.getplayer(uid)
			if member then
				if member.lv < map.openlv then
					return false,language.format("队员#<R>{1}#等级不足#<R>{2}#级",member:getname(),map.openlv)
				end
			end
		end
	end

	return true
end

function playunit_guaji.canbackteam(player)
	local team = player:getteam()
	local captain = playermgr.getplayer(team.captain)
	local scene = scenemgr.getscene(captain.sceneid)
	local isok,map = playunit_guaji.isguajimap(scene.mapid)
	if not isok then
		return true
	end
	if playunit_guaji.inguaji(captain) then
		if player.lv < map.openlv then
			return false,language.format("等级不足#<R>{1}#级，无法进入#<R>{2}#挂机地图",map.openlv,map.name)
		end
	end
	return true
end

function playunit_guaji.canbackteam(player)
	local team = teammgr:getteambypid(player.pid)
	local captain = playermgr.getplayer(team.captain)
	if captain and playunit_guaji.inguaji(captain) then
		local map = data_1100_GuaJiMap[captain.sceneid]
		if player.lv < map.openlv then
			local msg = language.format("【{1}】的等级不足{2}级，无法在【{3}】挂机巡逻",
				language.untranslate(player.name),
				language.untranslate(map.openlv),
				language.untranslate(map.name))
			team:say(msg,true)
			return false
		end
	end
	return true
end

function playunit_guaji.onenter(player,sceneid,pos)

	--playunit_guaji.setstate(player,playunit_guaji.UNGUAJI_STATE)
	local scene = scenemgr.getscene(sceneid)
	if playunit_guaji.isguajimap(scene.mapid) then
		-- 需要主动挂机才会进入挂机状态
		--playunit_guaji.setstate(player,playunit_guaji.GUAJI_STATE)
	else
		playunit_guaji.setstate(player,playunit_guaji.UNGUAJI_STATE)
	end
end

function playunit_guaji.onleave(player,sceneid)
	local scene = scenemgr.getscene(sceneid)
	if playunit_guaji.isguajimap(scene.mapid) then
		playunit_guaji.setstate(player,playunit_guaji.UNGUAJI_STATE)
	end
end

playunit_guaji.canenterscene = playunit_guaji.canenter
playunit_guaji.onenterscene = playunit_guaji.onenter
playunit_guaji.onleavescene = playunit_guaji.onleave

function playunit_guaji.guaji(player)
	local scene = scenemgr.getscene(player.sceneid)
	local isok,map = playunit_guaji.isguajimap(scene.mapid)
	if not isok then
		return false,language.format("非挂机地图无法挂机")
	end
	local teamstate = player:teamstate()
	if teamstate == TEAM_STATE_FOLLOW then
		return false,language.format("只有队长才能进行挂机")
	end
	if teamstate == TEAM_STATE_LEAVE then
		return false,language.format("只有队长才能进行挂机")
	end
	if player:warid() then
		return false,language.format("战斗中无法挂机")
	end
	if playunit_guaji.inguaji(player) then
		return false,language.format("已处于挂机状态")
	end
	if player.lv < map.openlv then
		return false,language.format("等级不足#<R>{1}#级，无法挂机",map.openlv)
	end
	local members = player:getfighters()
	for i,uid in ipairs(members) do
		if uid ~= player.pid then
			local member = playermgr.getplayer(uid)
			if member and member.lv < map.openlv then
				return false,language.format("队员#<R>{1}#等级不足#<R>{2}#级，无法挂机",member:getname(),map.openlv)
			end
		end
	end
	playunit_guaji.setstate(player,playunit_guaji.GUAJI_STATE)
	return true
end

function playunit_guaji.unguaji(player)
	-- need to check ?
	--local scene = scenemgr.getscene(player.sceneid)
	--if not playunit_guaji.isguajimap(scene.mapid) then
	--	return false,language.format("非挂机地图无法取消挂机")
	--end

	local teamstate = player:teamstate()
	if teamstate == TEAM_STATE_FOLLOW then
		return false,language.format("跟随状态无法取消挂机")
	end
	if player:warid() then
		return false,language.format("战斗中无法取消挂机")
	end
	if not playunit_guaji.inguaji(player) then
		return false,language.format("已处于非挂机状态")
	end
	playunit_guaji.setstate(player,playunit_guaji.UNGUAJI_STATE)
	return true
end

function playunit_guaji.setstate(player,state)
	local oldstate = playunit_guaji.getstate(player)
	if oldstate ~= state then
		player:set("guaji.state",state)
		sendpackage(player.pid,"guaji","state",{
			state = state,
		})
	end
	local teamstate = player:teamstate()
	if teamstate == TEAM_STATE_CAPTAIN then
		local team = player:getteam()
		for uid in pairs(team.follow) do
			local member = playermgr.getplayer(uid)
			if member then
				playunit_guaji.setstate(member,state)
			end
		end
	end
end

function playunit_guaji.getstate(player)
	return player:query("guaji.state") or playunit_guaji.UNGUAJI_STATE
end

function playunit_guaji.inguaji(player)
	return playunit_guaji.getstate(player) == playunit_guaji.GUAJI_STATE
end

function playunit_guaji.onmove(player,oldpos,newpos)
	local teamstate = player:teamstate()
	if not (teamstate == NO_TEAM or
		teamstate == TEAM_STATE_CAPTAIN) then
		return
	end
	if not playunit_guaji.inguaji(player) then
		return
	end
	local ratio = player:query("guaji.ratio") or 0
	if ratio < 100 then
		ratio = math.min(100,ratio+data_1100_GuaJiVar.AddRatioPerSec)
	end
	if ishit(ratio,100) then
		-- 战斗结束后至少5步移动后才遇怪
		ratio = -(data_1100_GuaJiVar.AddRatioPerSec*5)
		playunit_guaji.raisewar(player)
	end
	player:set("guaji.ratio",ratio)
end

function playunit_guaji.raisewar(player)
	local sceneid = player.sceneid
	local map = data_1100_GuaJiMap[sceneid]
	local wargroup = data_1100_GuaJiWarGroup[map.war_group]
	local warid = choosekey(wargroup,function (key,val)
		return val.ratio
	end)
	local fighters = assert(player:getfighters())
	local reward = wargroup[warid]
	local itemtype = choosekey(data_1100_GuaJiVar.ItemTypeRatio)
	local war = {
		attackers = fighters,
		defensers = nil,
		wardataid = warid,
		wartype = WARTYPE.PVE_GUAJI,
		-- ext
		reward = {
			exp = reward.exp,
			jobexp = reward.jobexp,
			items = {{type=itemtype,num=1,},},
		},
	}
	warmgr.startwar(war)
end

function playunit_guaji.onwarend(war,result)
	local reason = "guaji.onwarend"
	if warmgr.iswin(result) then
		for i,uid in ipairs(war.attackers) do
			local player = playermgr.getplayer(uid)
			if player then
				local reward = deepcopy(war.reward)
				local items = reward.items
				reward.items = nil
				local cnt = player.today:query("guaji_itemaward_cnt") or 0
				local ratios = data_1100_GuaJiVar.RatioLimit
				local maxless_key
				for k,v in pairs(ratios) do
					if k <= cnt then
						if not maxless_key or k > maxless_key then
							maxless_key = k
						end
					end
				end
				local ratio = ratios[maxless_key]
				if ishit(ratio,100) then
					reward.items = items
					player.today:add("guaji_itemaward_cnt",1)
				end
				local isok,exp_addn = player:has_exp_addn("guaji",reward.exp)
				if isok and exp_addn > 0 then
					reward.exp = reward.exp + exp_addn
				end
				doaward("player",player.pid,reward,reason,true)
				navigation.addprogress(player.pid,"guaji")
			end
		end
	elseif warmgr.islose(result) then
		for i,uid in ipairs(war.attackers) do
			local player = playermgr.getplayer(uid)
			if player then
				playunit_guaji.setstate(player,playunit_guaji.UNGUAJI_STATE)
			end
		end
	end
end

function playunit_guaji.onjointeam(player,teamid)
	if playunit_guaji.inguaji(player) then
		playunit_guaji.setstate(player,playunit_guaji.UNGUAJI_STATE)
	end
end

function playunit_guaji.onbackteam(player,teamid)
	local team = teammgr:getteam(teamid)
	local captain = playermgr.getplayer(team.captain)
	local state = playunit_guaji.getstate(captain)
	playunit_guaji.setstate(player,state)
end

-- 暂离队伍
function playunit_guaji.onleaveteam(player,teamid)
	if playunit_guaji.inguaji(player) then
		playunit_guaji.setstate(player,playunit_guaji.UNGUAJI_STATE)
	end
end

function playunit_guaji.onquitteam(player,teamid)
	if playunit_guaji.inguaji(player) then
		playunit_guaji.setstate(player,playunit_guaji.UNGUAJI_STATE)
	end
end

function playunit_guaji.onquitwar(pid,warid)
	local player = playermgr.getplayer(pid)
	if not player then
		return
	end
	if playunit_guaji.inguaji(player) then
		playunit_guaji.setstate(player,playunit_guaji.UNGUAJI_STATE)
	end
end

return playunit_guaji

