local function test(pid1,pid2)
	local player1 = playermgr.getplayer(pid1)
	local player2 = playermgr.getplayer(pid2)
	if not (player1 and player2) then
		return
	end
	player1:delete("guaji")
	player2:delete("guaji")
	assert(huodongmgr.playunit.guaji.getstate(player1) == huodongmgr.playunit.guaji.UNGUAJI_STATE)
	assert(huodongmgr.playunit.guaji.getstate(player2) == huodongmgr.playunit.guaji.UNGUAJI_STATE)
	local lv = 50
	player1.lv = lv
	player2.lv = lv
	local pos = {x=800,y=800,dir=1}
	player1:enterscene(1,pos)
	player2:enterscene(1,pos)
	assert(player1.sceneid == 1)
	assert(player2.sceneid == 1)
	local can_enter_mapid
	local cannot_enter_mapid
	for mapid,map in pairs(data_1100_GuaJiMap) do
		if map.openlv < lv then
			can_enter_mapid = mapid
		elseif map.openlv > lv then
			cannot_enter_mapid = mapid
		end
	end
	player1:enterscene(can_enter_mapid,pos)
	assert(player1.sceneid == can_enter_mapid)
	player1:enterscene(cannot_enter_mapid,pos)
	assert(player1.sceneid == can_enter_mapid)
	net.guaji.C2S.guaji(player1,{})
	assert(huodongmgr.playunit.guaji.getstate(player1) == huodongmgr.playunit.guaji.GUAJI_STATE)
	net.guaji.C2S.unguaji(player1,{})
	assert(huodongmgr.playunit.guaji.getstate(player1) == huodongmgr.playunit.guaji.UNGUAJI_STATE)
	net.team.C2S.createteam(player1,{target=1,lv=1})
	local teamid = assert(player1.teamid)
	net.team.C2S.apply_jointeam(player2,{teamid=teamid})
	net.team.C2S.agree_jointeam(player1,{pid=player2.pid})
	net.team.C2S.backteam(player2,{})
	assert(player1.sceneid == player2.sceneid)
	net.guaji.C2S.guaji(player1,{})
	assert(huodongmgr.playunit.guaji.getstate(player1) == huodongmgr.playunit.guaji.GUAJI_STATE)
	assert(huodongmgr.playunit.guaji.getstate(player2) == huodongmgr.playunit.guaji.GUAJI_STATE)
	net.guaji.C2S.unguaji(player1,{})
	assert(huodongmgr.playunit.guaji.getstate(player1) == huodongmgr.playunit.guaji.UNGUAJI_STATE)
	assert(huodongmgr.playunit.guaji.getstate(player2) == huodongmgr.playunit.guaji.UNGUAJI_STATE)

end

return test

