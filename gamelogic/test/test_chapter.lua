
local function test2(pid)
	local player = playermgr.getplayer(pid)
	player.chapterdb:onwarend({chapterid = 10001,},{ star = 0})
	assert(not player.chapterdb:get(10001).pass)
	player.chapterdb:onwarend({chapterid = 10001,},{ star = 3})
	assert(player.chapterdb:get(10001).pass)
	local net = require "gamelogic.net.chapter"
	net.C2S.getaward(player,{awardid = 1})
	net.C2S.getaward(player,{awardid = 1})
	assert(player.chapterdb:findrecord(1))
	net.C2S.getaward(player,{awardid = 2})
	assert(not player.chapterdb:findrecord(2))
end


local function test(pid)
	local player = playermgr.getplayer(pid)
	player.chapterdb:clear()
	local net = require "gamelogic.net.chapter"
	player.chapterdb:unlockchapter(10001)
	assert(player.chapterdb:get(10001))
	net.C2S.raisewar(player,{ chapterid = 10001 })
	net.C2S.getaward(player,{ awardid = 1})
	assert(not player.chapterdb:findrecord(1))
	timer.timeout("chapter",5,functor(test2,pid))
end

return test