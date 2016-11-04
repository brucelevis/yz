local function test(pid)
	local player = playermgr.getplayer(pid)
	player.titledb:clear()

	player.titledb:addtitle(1001)
	assert(player.titledb:gettitle(1001))
	player.titledb:addtitle(1002)
	assert(player.titledb:gettitle(1002))
	assert(player.titledb.len == 2)
	player.titledb:deltitle(1002)
	assert(player.titledb:gettitle(1002)==nil)
	assert(player.titledb.len == 1)
	-- unexist title
	local isok = pcall(player.titledb.set_curtitle,player.titledb,1002)
	assert(isok == false)
	assert(player.titledb.cur_titleid == nil)
	player.titledb:set_curtitle(1001)
	assert(player.titledb.cur_titleid == 1001)
	player.titledb:clear()
	assert(player.titledb:gettitle(1001) == nil)
	assert(player.titledb.len == 0)
end

return test
