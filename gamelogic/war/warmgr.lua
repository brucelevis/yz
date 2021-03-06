warmgr = warmgr or {}

function warmgr.init()
	warmgr.wars = {}
	warmgr.pid_warid = {}
	warmgr.pid_watchwarid = {}
end

function warmgr.onlogin(player)
	local pid = player.pid
	local watch_warid = warmgr.watchwarid(pid)
	if watch_warid then
		local war = warmgr.getwar(watch_warid)
		if war then
			warmgr.watchwar(player,watch_warid)
		else
			warmgr.pid_watchwarid[pid] = nil
		end
	end
	local war = warmgr.getwarbypid(pid)
	if war then
		local ishelper = table.find(war.attack_helpers,pid) or table.find(war.defense_helpers,pid)
		if ishelper then
			warmgr.quitwar(pid)
		end
		-- dosomething
	end
	local scene = scenemgr.getscene(player.sceneid)
	scene:set(player.pid,{
		warid = warmgr.warid(player.pid) or 0,
	})
end

function warmgr.onlogoff(player,reason)
	if reason == "replace" then
		return
	end
	warmgr.quitwar(player.pid)
end

function warmgr.packwar(war)
	return war
end

function warmgr.packplayer(player)
	local warplayer = {}
	warplayer.pid = player.pid
	warplayer.attr = {
		roletype = player.roletype,
		name = player.name,
		lv = player.lv,
		exp = player.exp,
		viplv = player.viplv,
		sex = player.sex,
		jobzs = player.jobzs,
		joblv = player.joblv,
		jobexp = player.jobexp,
		qualitypoint = player:query("qualitypoint"),
		huoli = player:query("huoli"),
		lang = player:getlanguage(),
	}
	local all_equippos = {}
	for id,equippos in pairs(player.equipposdb.objs) do
		-- equippos是一个数据集对象
		table.insert(all_equippos,equippos)
	end
	warplayer.all_equippos = all_equippos
	local items = {}
	for i,item in pairs(player.itemdb.objs) do
		local maintype = itemaux.getmaintype(item.type)
		if maintype == ItemMainType.EQUIP then
			-- 已佩戴的装备
			if item.pos == item:get("equippos") then
				table.insert(items,item:pack())
			end
		elseif maintype == ItemMainType.DRUG then
			table.insert(items,item:pack())
		end
	end
	warplayer.items = items
	warplayer.petspace = player.petdb:getspace()
	warplayer.pets = player.petdb:getallpets()
	warplayer.skills = player.warskilldb:getcurskills()
	local cards = {}
	for i,item in pairs(player.carddb.objs) do
		table.insert(cards,item:pack())
	end
	warplayer.cards = cards
	warplayer.id = 1
	--pprintf("warplayer:%s",warplayer)
	return warplayer
end


function warmgr.genwarid()
	local warid = globalmgr.server:query("warid",0)
	if warid > MAX_NUMBER then
		warid = 0
	end
	warid = warid + 1
	globalmgr.server:set("warid",warid)
	return warid
end


function warmgr.addwar(warid,war)
	assert(warmgr.getwar(warid)==nil, "Repeat warid:" .. tostring(warid))
	war.warid = warid
	war.attackers = war.attackers or {}
	war.defensers = war.defensers or {}
	war.attack_helpers = war.attack_helpers or {}
	war.defense_helpers = war.defense_helpers or {}
	war.attack_escapers = {}
	war.defense_escapers = {}
	war.attack_watchers = {}
	war.defense_watchers = {}
	warmgr.wars[warid] = war
	if not table.isempty(war.attackers) then
		for i,pid in ipairs(war.attackers) do
			warmgr.pid_warid[pid] = warid
		end
	end
	if not table.isempty(war.defensers) then
		for i,pid in ipairs(war.defensers) do
			if war.wartype == WARTYPE.PVP_ARENA_RANK then
			else
				warmgr.pid_warid[pid] = warid
			end
		end
	end
	return warid
end

function warmgr.delwar(warid)
	local war = warmgr.getwar(warid)
	if war then
		warmgr.wars[warid] = nil
		if not table.isempty(war.attackers) then
			for i,pid in ipairs(war.attackers) do
				warmgr.pid_warid[pid] = nil
			end
		end
		if not table.isempty(war.defensers) then
			for i,pid in ipairs(war.defensers) do
				if war.wartype == WARTYPE.PVP_ARENA_RANK then
				else
					warmgr.pid_warid[pid] = nil
				end end
		end
		if not table.isempty(war.attack_watchers) then
			for i,pid in ipairs(war.attack_watchers) do
				warmgr.pid_watchwarid[pid] = nil
			end
		end
		if not table.isempty(war.defense_watchers) then
			for i,pid in ipairs(war.defense_watchers) do
				warmgr.pid_watchwarid[pid] = nil
			end
		end
		return war
	end
end

function warmgr.warid(pid)
	return warmgr.pid_warid[pid]
end

function warmgr.watchwarid(pid)
	return warmgr.pid_watchwarid[pid]
end

function warmgr.getwar(warid)
	return warmgr.wars[warid]
end

function warmgr.getwarbypid(pid)
	local warid = warmgr.warid(pid)
	if warid then
		local war = warmgr.getwar(warid)
		if not war then
			warmgr.pid_warid[pid] = nil
		end
		return war
	end
end

function warmgr.can_startwar(war)
	if not clustermgr.isconnect(skynet.getenv("warsrv")) then
		return false
	end
	local set_attackers = table.toset(war.attackers)
	local set_defensers = table.toset(war.defensers)
	local set_attack_helpers = table.toset(war.attack_helpers)
	local set_defense_helpers = table.toset(war.defense_helpers)
	local set = table.intersect_set(set_attackers,set_attack_helpers)
	if not table.isempty(set) then
		return false
	end
	local set = table.intersect_set(set_defensers,set_defense_helpers)
	if not table.isempty(set) then
		return false
	end
	set_attackers = table.union_set(set_attackers,set_attack_helpers)
	set_defensers = table.union_set(set_defensers,set_defense_helpers)
	local set = table.intersect_set(set_attackers,set_defensers)
	if not table.isempty(set) then
		return false
	end
	-- is anyone inwar?
	if not table.isempty(war.attackers) then
		for i,pid in ipairs(war.attackers) do
			if warmgr.warid(pid) then
				return false
			end
		end
	end
	if not table.isempty(war.attack_helpers) then
		for i,pid in ipairs(war.attack_helpers) do
			if warmgr.warid(pid) then
				return false
			end
		end
	end
	if not table.isempty(war.defensers) then
		for i,pid in ipairs(war.defensers) do
			if warmgr.warid(pid) then
				return false
			end
		end
	end
	if not table.isempty(war.defense_helpers) then
		for i,pid in ipairs(war.defense_helpers) do
			if warmgr.warid(pid) then
				return false
			end
		end
	end
	if war.wardataid and not warmgr.isvalid_wardataid(war.wardataid) then
		logger.log("warning","war",string.format("[invalid_wardataid] wardataid=%s",war.wardataid))
		return false
	end

	return true
end

--/*
-- @functions : 发起一场战斗
-- @param table attackers  进攻方玩家列表
-- @param table defensers  防守方玩家列表(PVE战斗传nil)
-- @param table war		   战斗数据，一般格式如下:
--	{
--		wartype=战斗类型,
--		wardataid=战斗数据ID(PVE战斗必填),
--		attack_helpers=进攻方援助列表 [可选],
--		defense_helpers=防守方援助列表 [可选],
--		其他字段（根据游戏逻辑设定)
--	}
--*/
function warmgr.startwar(attackers,defensers,war)
	if not defensers and not war then
		war = attackers
	else
		defensers = defensers or {}
		war.attackers = attackers
		war.defensers = defensers
	end
	assert(WARTYPE[war.wartype],"Invalid wartype:" .. tostring(war.wartype))
	local isok = warmgr.can_startwar(war)
	if not isok then
		return false
	end

	local warid = warmgr.genwarid()
	war.warid = warid
	warmgr.addwar(warid,war)
	sendtowarsrv("war","startwar",warmgr.packwar(war))
	if not table.isempty(war.attackers) then
		for i,pid in ipairs(war.attackers) do
			local player = playermgr.getplayer(pid)
			if not player then
				player = playermgr.loadofflineplayer(pid)
			end
			assert(player,"Invalid pid:" .. tostring(pid))
			sendtowarsrv("war","addplayer",{
				warid = warid,
				player = warmgr.packplayer(player),
			})
			if warmgr.watchwarid(pid) then
				warmgr.quit_watchwar(pid)
			end
		end
	end
	if not table.isempty(war.attack_helpers) then
		for i,pid in ipairs(war.attack_helpers) do
			local player = playermgr.getplayer(pid)
			if not player then
				player = playermgr.loadofflineplayer(pid)
			end
			assert(player,"Invalid pid:" .. tostring(pid))
			--援助玩家一定是离线玩家
			assert(player.__state == "offline")
			sendtowarsrv("war","addplayer",{
				warid = warid,
				player = warmgr.packplayer(player),
			})
		end
	end
	if not table.isempty(war.defensers) then
		for i,pid in ipairs(war.defensers) do
			local player = playermgr.getplayer(pid)
			if not player then
				player = playermgr.loadofflineplayer(pid)
			end
			assert(player,"Invalid pid:" .. tostring(pid))
			sendtowarsrv("war","addplayer",{
				warid = warid,
				player = warmgr.packplayer(player),
			})
			if warmgr.watchwarid(pid) then
				warmgr.quit_watchwar(pid)
			end
		end
	end
	if not table.isempty(war.defense_helpers) then
		for i,pid in ipairs(war.defense_helpers) do
			local player = playermgr.getplayer(pid)
			if not player then
				player = playermgr.loadofflineplayer(pid)
			end
			assert(player,"Invalid pid:" .. tostring(pid))
			--援助玩家一定是离线玩家
			assert(player.__state == "offline")
			sendtowarsrv("war","addplayer",{
				warid = warid,
				player = warmgr.packplayer(player),
			})
		end
	end
	sendtowarsrv("war","finish_startwar",{warid=warid})
	logger.log("info","war",format("[startwar] warid=%s war=%s",warid,war))
	return true
end

function warmgr.isvalid_wardataid(wardataid)
	return data_1301_WarRole[wardataid] and true or false
end

-- 打包一个玩家简介数据
function warmgr.packresume(player)
	return resumemgr.getresume(player.pid)
end

function warmgr.watchwar(player,warid,towatch_pid)
	local pid = player.pid
	if warmgr.warid(pid) then
		net.msg.S2C.notify(player.pid,language.format("战斗中无法观战"))
		return
	end
	local war = warmgr.getwar(warid)
	if not war then
		net.msg.S2C.notify(player.pid,language.format("观看的战斗失效"))
		return
	end
	local bfound = false
	if not table.isempty(war.attackers) then
		if table.find(war.attackers,towatch_pid) then
			if not table.find(war.attack_watchers,pid) then
				table.insert(war.attack_watchers,pid)
				bfound = true
			end
		end
	end
	if not bfound then
		if not table.isempty(war.defensers) then
			if table.find(war.defensers,towatch_pid) then
				if not table.find(war.defense_watchers,pid) then
					table.insert(war.defense_watchers,pid)
					bfound = true
				end
			end
		end
	end
	if not bfound then
		net.msg.S2C.notify(player.pid,language.format("观看的战斗失效"))
		return
	end
	logger.log("info","war",string.format("[watchwar] warid=%s pid=%s towatch_pid",warid,pid,towatch_pid))
	warmgr.pid_watchwarid[pid] = warid
	sendtowarsrv("war","watchwar",{
		warid = warid,
		watcher = warmgr.packresume(player),
		pid = towatch_pid,
	})
end

function warmgr.quit_watchwar(pid)
	local warid = warmgr.watchwarid(pid)
	local war = warmgr.getwar(warid)
	if not war then
		return
	end
	local bfound = false
	local pos = table.find(war.attack_watchers,pid)
	if pos then
		table.remove(war.attack_watchers,pid)
		bfound = true
	end
	if not bfound then
		local pos = table.find(war.defense_watchers,pid)
		if pos then
			table.remove(war.defense_watchers,pid)
			bfound = true
		end
	end
	if not bfound then
		return
	end
	logger.log("info","war",string.format("[quit_watchwar] warid=%s pid=%s",warid,pid))
	warmgr.pid_watchwarid[pid] = nil
	sendtowarsrv("war","quit_watchwar",{
		warid = warid,
		pid = pid,
	})
end

function warmgr.broadcast_inwar(warid,func)
	local war = warmgr.getwar(warid)
	if not war then
		return
	end
	for i,pid in ipairs(war.attackers) do
		func(pid)
	end
	for i,pid in ipairs(war.defensers) do
		func(pid)
	end
end

-- force to endwar
function warmgr.force_endwar(warid,reason)
	logger.log("info","war",string.format("[force_endwar] warid=%s reason=%s",warid,reason))
	sendtowarsrv("war","endwar",{
		warid = warid,
	})
	warmgr.onwarend(warid,0)
end

function warmgr.quitwar(pid)
	local warid = warmgr.warid(pid)
	local war = warmgr.getwar(warid)
	if not war then
		return false
	end
	local bfound = false
	if not table.isempty(war.attackers) then
		local pos = table.find(war.attackers,pid)
		if pos then
			bfound =  true
			table.remove(war.attackers,pos)
			table.insert(war.attack_escapers,pid)
			warmgr.pid_warid[pid] = nil
		end
	end
	if not bfound then
		if not table.isempty(war.attack_helpers) then
			local pos = table.find(war.attack_helpers,pid)
			if pos then
				bfound = true
				table.remove(war.attack_helpers,pos)
				table.insert(war.attack_escapers,pid)
				warmgr.pid_warid[pid] = nil
			end
		end
	end
	if not bfound then
		if not table.isempty(war.defensers) then
			local pos = table.find(war.defensers,pid)
			if pos then
				bfound = true
				table.remove(war.defensers,pos)
				table.insert(war.defense_escapers,pid)
				warmgr.pid_warid[pid] = nil
			end
		end
	end
	if not bfound then
		if not table.isempty(war.defense_helpers) then
			local pos = table.find(war.defense_helpers,pid)
			if pos then
				bfound = true
				table.remove(war.defense_helpers,pos)
				table.insert(war.defense_escapers,pid)
				warmgr.pid_warid[pid] = nil
			end
		end
	end
	if bfound then
		logger.log("info","war",string.format("[quitwar] warid=%s pid=%s",warid,pid))
		sendtowarsrv("war","quitwar",{
			warid = warid,
			pid = pid,
		})
		sendpackage(pid,"war","quitwar",{
			warid = warid,
		})
		warmgr.onquitwar(pid,warid)
		local team = teammgr:getteambypid(pid)
		if team and team:teamstate(pid) ~= TEAM_STATE_LEAVE then
			local player = playermgr.getplayer(pid)
			if player then
				teammgr:leaveteam(player)
			end
		end
		return true
	else
		return false
	end
end

function warmgr.onquitwar(pid,warid)
	huodongmgr.onquitwar(pid,warid)
end

function warmgr.onwarend(warid,result)
	local war = warmgr.getwar(warid)
	if not war then
		logger.log("error","war",string.format("[onwarend] Invalid_warid=%s result=%s",warid,result))
		return
	end
	logger.log("info","war",format("[onwarend] warid=%s result=%s war=%s",warid,result,war))
	for i,pid in ipairs(war.attackers) do
		sendpackage(pid,"war","warresult",{
			warid = warid,
			result = result
		})
	end
	for i,pid in ipairs(war.defensers) do
		sendpackage(pid,"war","warresult",{
			warid = warid,
			result = -result,
		})
	end
	local wartype = assert(war.wartype)
	local callback = warmgr.onwarend_callback[wartype]
	if callback then
		local plist = {}
		table.extend(plist,war.attackers)
		table.extend(plist,war.defensers)
		for _,pid in ipairs(plist) do
			local player = playermgr.getplayer(pid)
			if player then
				player.delaypackage:open()
			end
		end
		xpcall(callback,onerror,warid,result)
		for _,pid in ipairs(plist) do
			local player = playermgr.getplayer(pid)
			if player then
				player.delaypackage:close()
			end
		end
	end
	-- dosomething
	warmgr.delwar(warid)
	if war.npc then
		warmgr.subwarcnt(war.npc)
	end
end

function warmgr.iswin(result)
	return result > 0
end

function warmgr.istie(result)
	return result == 0
end

function warmgr.islose(result)
	return result < 0
end

-- 标记怪物战斗状态
function warmgr.addwarcnt(npc)
	npc = scenemgr.getnpc(npc.id,npc.sceneid)
	if not npc then
		return
	end
	npc.cur_warcnt = (npc.cur_warcnt or 0) + 1
	local scene = scenemgr.getscene(npc.sceneid)
	if scene then
		scene:broadcast("scene","updatenpc",{
			id = npc.id,
			cur_warcnt = npc.cur_warcnt,
		})
	end
end

function warmgr.subwarcnt(npc)
	npc = scenemgr.getnpc(npc.id,npc.sceneid)
	if not npc then
		return
	end
	npc.cur_warcnt = (npc.cur_warcnt or 0) - 1
	local scene = scenemgr.getscene(npc.sceneid)
	if scene then
		scene:broadcast("scene","updatenpc",{
			id = npc.id,
			cur_warcnt = npc.cur_warcnt,
		})
	end
end

return warmgr
