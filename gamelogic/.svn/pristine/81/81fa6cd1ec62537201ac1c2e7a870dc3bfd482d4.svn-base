
local function test2(pid)
	local player = playermgr.getplayer(pid)
	assert(player.chapterdb:get(10000101).pass)
	local net = require "gamelogic.net.chapter"
	net.C2S.getaward(player,{awardid = 101})
	net.C2S.getaward(player,{awardid = 101})
	assert(player.chapterdb:findrecord(101))
	net.C2S.getaward(player,{awardid = 102})
	assert(not player.chapterdb:findrecord(102))
	net.C2S.reviewstory(player,{line = 1,section = 100001,})
end


local function test(pid)
	local player = playermgr.getplayer(pid)
	player.chapterdb:clear()
	local net = require "gamelogic.net.chapter"
	player.chapterdb:unlockchapter(10000101)
	assert(player.chapterdb:get(10000101))
	net.C2S.raisewar(player,{ chapterid = 10000101 })
	net.C2S.getaward(player,{ awardid = 101})
	assert(not player.chapterdb:findrecord(101))
	timer.timeout("chapter",5,functor(test2,pid))
end

return test
