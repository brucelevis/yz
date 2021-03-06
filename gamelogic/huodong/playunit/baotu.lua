playunit_baotu = playunit_baotu or {}
huodongmgr.playunit.baotu = playunit_baotu

playunit_baotu.AWARD_LIMIT = 10

function playunit_baotu.onlogoff(player,reason)
	playunit_baotu.cancel(player,"baotu")
end

function playunit_baotu.onuse(pid,packdata,bsendmail)
	local player = playermgr.getplayer(pid)
	if not player then
		return
	end
	local itemid = assert(packdata.itemid)
	local item,itemdb = player:getitem(itemid)
	-- 防止挖宝表现过程中删除物品
	if not item then
		return
	end
	local reason = "baotu.onuse"
	itemdb:costitembyid(itemid,1,reason)
	if packdata.npc then
		local npc = packdata.npc
		local sceneid = assert(npc.sceneid)
		local noinwar_num = 0
		local ready_delnpc
		local scene = scenemgr.getscene(sceneid)
		for npcid,npc in pairs(scene.npcs) do
			if npc.purpose == "baotu" and
				(npc.cur_warcnt or 0) <= 0 then
				noinwar_num = noinwar_num + 1
				if not ready_delnpc or ready_delnpc.createtime > npc.createtime then
					ready_delnpc = npc
				end
			end
		end
		local scenedata = data_1100_BaoTuMonsterPos[sceneid]
		if noinwar_num > scenedata.monster_maxnum then
			assert(ready_delnpc)
			scenemgr.delnpc(ready_delnpc.id,ready_delnpc.sceneid)
		end
		scenemgr.addnpc(npc,npc.sceneid)
		-- todo: modify
		net.msg.sendquickmsg(language.format("【{1}】根据在寻宝途中触动了魔法机关，唤醒了在【{2}({3},{4})】沉睡的【{5}】",player.name,scene.mapname,npc.pos.x,npc.pos.y,npc.name))
	end

	if packdata.item then
		local item = assert(packdata.item)
		local reward = {items={item},}
		if not bsendmail and not player:isdisconnect() then
			doaward("player",player.pid,reward,reason,true)
		else
			mailmgr.sendmail(player.pid,{
				author = language.format("系统"),
				title = language.format("挖宝获得物品"),
				content = language.format("挖宝获得物品"),
				attach = reward,
			})
		end
	end
	--sendpackage(player.pid,"item","usebaotu_result",packdata)
end

-- 宝图分两次使用，第一次使用会生成奖励，第二次使用(点击停止转盘）会发放奖励
function playunit_baotu.use(player,item)
	if huodongmgr.playunit.guaji.inguaji(player) then
		net.msg.S2C.notify(player.pid,language.format("挂机状态中，无法进行此项操作"))
		return
	end
	if player:warid() then
		net.msg.S2C.notify(player.pid,language.format("战斗中，无法进行此项操作"))
		return
	end
	local teamstate = player:teamstate()
	if teamstate == TEAM_STATE_FOLLOW then
		net.msg.S2C.notify(player.pid,language.format("跟随队长中，无法进行此项操作"))
		return
	end
	local key = string.format("baotu")
	local baotu_cache = player:query(key)
	if baotu_cache then
		baotu_cache.itemid = item.id
		if baotu_cache.inuse then
			if player.sceneid ~= baotu_cache.sceneid then
				net.msg.S2C.notify(player.pid,language.format("不在此场景"))
				return
			end
			if getdistance(player.pos,baotu_cache.pos) > 320 and false then
				net.msg.S2C.notify(player.pid,language.format("距离太远了"))
				return
			end
			player:delete(key)
			playunit_baotu.onuse(player.pid,baotu_cache)
			return
		end
	end
	if not baotu_cache then
		local itemdata = itemaux.getitemdata(item.type)
		local baotuid = choosekey(data_1100_BaoTu,function (k,v)
			return v.ratio
		end)
		local data = data_1100_BaoTu[baotuid]
		local packdata = {
			itemid = item.id,
			itemtype = item.type,
		}
		local sceneid = randlist(table.keys(data_1100_BaoTuPos))
		local posdata = data_1100_BaoTuPos[sceneid]
		local posid = randlist(posdata.posids)
		local sceneid,x,y = scenemgr.getpos(posid)
		local scene = scenemgr.getscene(sceneid)
		packdata.baotuid = baotuid
		packdata.sceneid = sceneid
		packdata.mapid = scene.mapid
		packdata.posid = posid
		packdata.pos = {x = x,y = y,dir = 1}
		local show_monster = false
		if data.etype == 1 then		-- 遇怪(现在暂时没有单独刷怪事件)
			show_monster = true
		elseif data.etype == 2 then -- 刷出物品
			local item = data.data
			packdata.item = item
			if ishit(data.monster_ratio) then
				show_monster = true
			end
		end
		if show_monster then
			local sceneid = randlist(table.keys(data_1100_BaoTuMonsterPos))
			local scenedata = data_1100_BaoTuMonsterPos[sceneid]
			local monsterid = data.monsterid
			local monsterdata = data_1100_BaoTuWar[monsterid]
			local posid = randlist(scenedata.posids)
			local _,x,y = scenemgr.getpos(posid)
			local pos = {x = x,y = y,dir = 1}
			local npc = {
				shape = monsterdata.shape,
				name = monsterdata.name,
				sceneid = sceneid,
				mapid = scene.mapid,
				posid = posid,
				pos = pos,
				purpose = "baotu",
				exceedtime = os.time() + 1800,
				-- 扩展信息
				monsterid = monsterid,
			}
			packdata.npc = npc
		end
		baotu_cache = packdata
	end
	baotu_cache.inuse = true
	sendpackage(player.pid,"item","usebaotu_result",baotu_cache)
	player:set(key,baotu_cache)
	logger.log("debug","huodong/baotu",format("[use] pid=%s baotu_cache=%s",player.pid,baotu_cache))
end

function playunit_baotu.startwar(player,npc)
	local fighters,errmsg = player:getfighters()
	if not fighters then
		net.msg.S2C.notify(player.pid,errmsg)
		return
	end
	local lv = player:team_avglv(TEAM_STATE_CAPTAIN_FOLLOW)
	local data = data_1100_BaoTuWar[npc.monsterid]
	if not data.war[lv] then  -- 找不到取最大等级
		lv = #data.war
	end
	local wardataid = data.war[lv].warid
	local war = {
		wardataid = wardataid,
		wartype = WARTYPE.PVE_BAOTU,
		-- ext
		npc = npc,
		npclv = lv,
	}
	return warmgr.startwar(fighters,nil,war)
end

function playunit_baotu.onwarend(war,result)
	local npc = war.npc
	if warmgr.iswin(result) then
		scenemgr.delnpc(npc.id,npc.sceneid)
		for i,pid in ipairs(war.attackers) do
			local player = playermgr.getplayer(pid)
			if player then
				local awardcnt = player.today:query("baotunpc_awardcnt") or 0
				local limit = playunit_baotu.AWARD_LIMIT
				if awardcnt >= limit then
					net.msg.S2C.notify(player.pid,language.format("今天已消灭宝图守卫{1}/{2},不会再获得奖励",awardcnt,limit))
				else
					player.today:add("baotunpc_awardcnt",1)
					net.msg.S2C.notify(player.pid,language.format("今天已消灭宝图守卫{1}/{2}",awardcnt+1,limit))
					local lv = player.lv
					local data = data_1100_BaoTuWar[npc.monsterid]
					local reward = data.war[lv]
					local reason = "playunit_baotu.onwarend"
					doaward("player",player.pid,{
						exp = reward.exp,
						jobexp = reward.jobexp,
						coin = reward.coin,
					},reason,true)
					if ishit(reward.normal_box_ratio) then
						player:additembytype(801001,1,nil,reason,true)
					end
					if ishit(reward.beautiful_box_ratio) then

						player:additembytype(801001,1,nil,reason,true)
					end
				end
			end
		end
	end
end

-- 停止挖宝(不能影响挖宝生成的奖励结果,否则客户端可能利用这种漏洞作弊)
function playunit_baotu.cancel(player,typ)
	local baotu_cache = player:query(typ)
	if baotu_cache then
		baotu_cache.inuse = nil
	end
end

function playunit_baotu.onbackteam(player,teamid)
	playunit_baotu.cancel(player,"baotu")
end


function playunit_baotu.getdailystat(player)
	local awardcnt = player.today:query("baotunpc_awardcnt") or 0
	return awardcnt,playunit_baotu.AWARD_LIMIT
end

return playunit_baotu
