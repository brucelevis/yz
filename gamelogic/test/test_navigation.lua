local function test(pid)
	local player = playermgr.getplayer(pid)
	assert(player)
	net.navigation.C2S.lookstat(player)
	player.today:set("navigatedata",nil)
	navigation.addprogress(pid,"shimen")
	local activity = navigation.getactivity(player,10002)
	assert(activity)
	assert(activity.progress == 1)
	for i = 1,25 do
		navigation.addprogress(pid,"shimen")
	end
	assert(activity.progress == 20)
	net.navigation.C2S.activitydata(player)
	net.navigation.C2S.activityaward(player,{ hid = 10002, })
	assert(activity.awarded == true)
	local navigatedata = navigation.getnavigation(player)
	navigatedata.liveness = 30
	net.navigation.C2S.livenessaward(player,{ awardid = 1 })
	net.navigation.C2S.activitydata(player)
end

return test
