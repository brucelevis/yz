playunit_baotu = playunit_baotu or {}
huodongmgr.playunit.baotu = playunit_baotu

function playunit_baotu.onlogoff(player)
	-- 下线立即触发发奖励，并且邮寄给玩家
	if player.baotu_cache then
		local baotu_cache = player.baotu_cache
		player.baotu_cache = nil
		playunit_baotu.onuse(player.pid,baotu_cache,true)
	end
end

function playunit_baotu.onuse(pid,packdata,bsendmail)
	local player = playermgr.getplayer(pid)
	if not player then
		return
	end
	player.baotu_cache = nil
	local timer_id = packdata.timer_id
	local timer_name = packdata.timer_name
	timer.untimeout(timer_name,timer_id)
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
		local scenedata = data_1102_BaoTuMonsterPos[sceneid]
		if noinwar_num > scenedata.monster_maxnum then
			assert(ready_delnpc)
			scenemgr.delnpc(ready_delnpc.id,ready_delnpc.sceneid)
		end
		scenemgr.addnpc(npc,npc.sceneid)
		-- todo: modify
		net.msg.sendquickmsg(string.format("【%s】根据在寻宝途中触动了魔法机关，唤醒了在【%s(%d,%d)】沉睡的【%s】",player.name,scene.mapname,npc.pos.x,npc.pos.y,npc.name))
	else
		local item = assert(packdata.item)
		local reward = {items={item},}
		if not bsendmail then
			doaward("player",player.pid,reward,reason,true)
		else
			local lang = player:getlanguage()
			mailmgr.sendmail(player.pid,{
				author = language.formatto(lang,"系统"),
				title = language.formatto(lang,"挖宝获得物品"),
				content = language.formatto(lang,"挖宝获得物品"),
				attach = reward,
			})
		end
	end
end

-- 宝图分两次使用，第一次使用会生成奖励，第二次使用(点击停止转盘）会发放奖励,如果没有收到第二次使用
-- 第二次使用的效果在定时到后会自动触发
function playunit_baotu.use(player,item)
	if player.baotu_cache then
		local baotu_cache = player.baotu_cache
		player.baotu_cache = nil
		playunit_baotu.onuse(player.pid,baotu_cache)
		return "onuse"
	end
	local itemdata = itemaux.getitemdata(item.type)
	local baotuid = choosekey(data_1102_BaoTu,function (k,v)
		return v.ratio
	end)
	local data = data_1102_BaoTu[baotuid]
	local packdata = {
		itemid = item.id,
	}
	local sceneid = randlist(table.keys(data_1102_BaoTuPos))
	local posdata = data_1102_BaoTuPos[sceneid]
	local posid = randlist(posdata.posids)
	local sceneid,x,y = scenemgr.getpos(posid)
	local scene = scenemgr.getscene(sceneid)
	packdata.sceneid = sceneid
	packdata.mapid = scene.mapid
	packdata.posid = posid
	packdata.pos = {x = x,y = y,dir = 1}
	if data.etype == 1 then		-- 遇怪
		local sceneid = randlist(table.keys(data_1102_BaoTuMonsterPos))
		local scenedata = data_1102_BaoTuMonsterPos[sceneid]
		local monsterid = data.data
		local monsterdata = data_1102_BaoTuWar[monsterid]
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
	else
		assert(data.etype == 2)		-- 刷出物品
		local item = data.data
		packdata.item = item
	end
	sendpackage(player.pid,"item","usebaotu_result",packdata)

	packdata.timer_name = "usebaotu"
	packdata.timer_id = timer.timeout(packdata.timer_name,10,functor(playunit_baotu.onuse,player.pid,packdata))
	player.baotu_cache = packdata
	logger.log("debug","huodong/baotu",format("[use] pid=%s baotu_cache=%s",player.pid,player.baotu_cache))
	return "readyuse"
end

function playunit_baotu.startwar(player,npc)
	local fighters,errmsg = player:getfighters()
	if not fighters then
		net.msg.S2C.notify(player.pid,errmsg)
		return
	end
	local lv = player:team_avglv(TEAM_STATE_CAPTAIN_FOLLOW)
	local data = data_1102_BaoTuWar[npc.monsterid]
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
	warmgr.startwar(fighters,nil,war)
end

function playunit_baotu.onwarend(war,result)
	local pid = war.attackers[1]
	local npc = war.npc
	if warmgr.iswin(result) then
		scenemgr.delnpc(npc.id,npc.sceneid)
	end
end

return playunit_baotu
