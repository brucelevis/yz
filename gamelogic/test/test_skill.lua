local function test(pid)
	local player = playermgr.getplayer(pid)
	assert(player)
	local warskilldb = player:getskilldb(100011)
	assert(warskilldb)
	warskilldb.skillpoint = 0
	warskilldb:clear()
	local net = require "gamelogic.net.skill"
	warskilldb:openskills(10001)
	assert(warskilldb:get(100011))
	warskilldb:addpoint(10)
	assert(warskilldb.skillpoint == 10)
	net.C2S.learnskill(player,{ skillid = 100011,})
	local skill = warskilldb:get(100011)
	assert(skill.level == 1)
	assert(warskilldb.skillpoint == 9)
	net.C2S.setcurslot(player,{ slot = 2,})
	assert(warskilldb.curslot == 2)
	net.C2S.wieldskill(player,{ skillid = 100011,position = 1})
	assert(warskilldb.skillslot[2][1] == 100011)
	net.C2S.resetpoint(player)
	assert(warskilldb.skillpoint == 10)
	for i = 1,6 do
		net.C2S.learnskill(player,{ skillid = 100011,})
	end
	skill = warskilldb:get(100011)
	assert(skill.level == 5)
	assert(warskilldb.skillpoint == 5)
end

return test
