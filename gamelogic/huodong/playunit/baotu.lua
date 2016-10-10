playunit_baotu = playunit_baotu or {}
huodongmgr.playunit.baotu = playunit_baotu

function playunit_baotu.onlogoff(player,reason)
	-- 下线立即触发发奖励，并且邮寄给玩家
	local baotu_cache = player:query("baotu_cache")
	if baotu_cache then
		playunit_baotu.onuse(player.pid,baotu_cache,true)
	end
end

function playunit_baotu.onuse(pid,packdata,bsendmail)
	local player = playermgr.getplayer(pid)
	if not player then
		return
	end
	player:delete("baotu_cache")
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
	packdata.stop = true
	sendpackage(player.pid,"item","usebaotu_result",packdata)
end

-- 宝图分两次使用，第一次使用会生成奖励，第二次使用(点击停止转盘）会发放奖励,如果没有收到第二次使用
-- 第二次使用的效果在定时到后会自动触发
function playunit_baotu.use(player,item)
	local teamstate = player:teamstate()
	if teamstate == TEAM_STATE_FOLLOW then
		net.msg.S2C.notify(player.pid,language.format("跟随队长中，无法进行此项操作"))
		return "stop"
	end
	local baotu_cache = player:query("baotu_cache")
	if baotu_cache and baotu_cache.itemid == item.id and not baotu_cache.cancel then
		playunit_baotu.onuse(player.pid,baotu_cache)
		return "onuse"
	end
	if not baotu_cache or baotu_cache.itemid ~= item.id then
		player:delete("baotu_cache")
		baotu_cache = nil
		local itemdata = itemaux.getitemdata(item.type)
		local baotuid = choosekey(data_1100_BaoTu,function (k,v)
			return v.ratio
		end)
		local data = data_1100_BaoTu[baotuid]
		local packdata = {
			itemid = item.id,
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
	else
		baotu_cache.cancel = nil
	end
	sendpackage(player.pid,"item","usebaotu_result",baotu_cache)
	baotu_cache.timer_name = "usebaotu"
	baotu_cache.timer_id = timer.timeout(baotu_cache.timer_name,15,functor(playunit_baotu.onuse,player.pid,baotu_cache))
	player:set("baotu_cache",baotu_cache)
	logger.log("debug","huodong/baotu",format("[use] pid=%s baotu_cache=%s",player.pid,baotu_cache))
	return "readyuse"
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
	warmgr.startwar(fighters,nil,war)
end

function playunit_baotu.onwarend(war,result)
	local pid = war.attackers[1]
	local npc = war.npc
	if warmgr.iswin(result) then
		scenemgr.delnpc(npc.id,npc.sceneid)
	end
end

-- 停止挖宝(不能影响挖宝生成的奖励结果,否则客户端可能利用这种漏洞作弊)
function playunit_baotu.cancel(player)
	local baotu_cache = player:query("baotu_cache")
	if not baotu_cache then
		return
	end
	baotu_cache.cancel = true
	local timer_id = baotu_cache.timer_id
	local timer_name = baotu_cache.timer_name
	timer.untimeout(timer_name,timer_id)
end

return playunit_baotu
