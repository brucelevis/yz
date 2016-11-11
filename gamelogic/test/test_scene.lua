local function test(pid1,pid2,pid3)
	local player1 = playermgr.getplayer(pid1)
	local player2 = playermgr.getplayer(pid2)
	local player3 = playermgr.getplayer(pid3)
	local mapid = 1
	local sceneid = mapid -- 普通场景，场景ID就等于地图ID
	local map = scenemgr.getmap(mapid)
	local initpos = {
		x = map.block_width + 1,
		y = map.block_height + 1,
	}
	-- 进入[1][1]块
	player1:enterscene(sceneid,initpos)
	player2:enterscene(sceneid,initpos)
	player3:enterscene(sceneid,initpos)
	local scene1 = scenemgr.getscene(sceneid)
	scene1:dump()

	net.team.C2S.createteam(player1,{target=1,lv=0})
	local teamid = player1:teamid()
	assert(teamid)
	net.team.C2S.apply_jointeam(player2,{teamid=teamid})
	net.team.C2S.agree_jointeam(player1,{pid=pid2})
	local team = teammgr:getteam(teamid)
	assert(team.follow[pid2] == true)	
	scene1:dump()

	local now = os.time()
	-- moveto [2][2]块
	net.scene.C2S.move(player1,{
		dstpos = {
			x = player1.pos.x + map.block_width,
			y = player1.pos.y + map.block_height,
			dir = player1.dir,
		},
		time = now,
	})
	scene1:dump()

	-- moveto [2][1]块
	net.scene.C2S.move(player1,{
		dstpos = {
			x = player1.pos.x,
			y = player1.pos.y - map.block_height,
			dir = player1.dir,
		},
		time = now,
	})
	scene1:dump()

	-- moveto [2][2]块,这时player1，player2离开了player3的视野
	net.scene.C2S.move(player1,{
		dstpos = {
			x = player1.pos.x + map.block_width,
			y = player1.pos.y,
			dir = player1.dir,
		},
		time = now,
	})

	scene1:dump()


	-- moveto [2][1]块,这时player1，player2重新进入player3的视野
	net.scene.C2S.move(player1,{
		dstpos = {
			x = player1.pos.x - map.block_width,
			y = player1.pos.y,
			dir = player1.dir,
		},
		time = now,
	})
	scene1:dump()

	-- player3 moveto [2][1]块
	net.scene.C2S.move(player3,{
		dstpos = {
			x = player3.pos.x + map.block_width,
			y = player3.pos.y,
			dir = player3.dir,
		},
		time = now,
	})
	scene1:dump()

	local sceneid2 = 2
	local scene2 = scenemgr.getscene(sceneid2)
	net.scene.C2S.enter(player1,{
		sceneid = sceneid2,
		pos = initpos,
	})
	scene1:dump()
	scene2:dump()

	net.scene.C2S.enter(player3,{
		sceneid = sceneid2,
		pos = initpos,
	})
	scene1:dump()
	scene2:dump()

	net.scene.C2S.query(player3,{targetid=player1.pid,})

	net.scene.C2S.enter(player3,{
		sceneid = sceneid,
		pos = initpos,
	})
	scene1:dump()
	scene2:dump()
end

return test

