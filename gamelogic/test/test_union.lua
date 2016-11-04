local function test(pid1,pid2,pid3)
	local player1 = playermgr.getplayer(pid1)
	--local player2 = playermgr.getplayer(pid2)
	--local player3 = playermgr.getplayer(pid3)
	player1:addgold(-player1.gold,"test")
	--player2:addgold(-player1.gold,"test")
	--player3:addgold(-player1.gold,"test")
	player1:addgold(data_1800_UnionVar.CreateUnionCostGold-1,"test")
	-- gold not enough
	net.union.C2S.createunion(player1,{
		name = "union1",
		purpose = "purpose",
		badge = {
			background = 1,
			maincolor = 1,
			minorcolor = 1,
			design = 1,
		},
	})
	player1:addgold(1,"test")
	net.union.C2S.createunion(player1,{
		name = "union1",
		purpose = "purpose",
		badge = {
			background = 1,
			maincolor = 1,
			minorcolor = 1,
			design = 1,
		},
	})
	assert(player1.gold == 0)
end

return test
