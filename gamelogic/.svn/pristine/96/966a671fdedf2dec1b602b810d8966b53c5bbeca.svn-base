warmgr.onwarend_callback = {}

function warmgr.register_onwarend(wartype,callback)
	warmgr.onwarend_callback[wartype] = callback
end

-- PVP
warmgr.register_onwarend(WARTYPE.PVP_QIECUO,function (warid,result)
end)

warmgr.register_onwarend(WARTYPE.PVP_ARENA_RANK,function (warid,result)
	local war = warmgr.getwar(warid)
	globalmgr.rank.arena:onwarend(war,result)
end)


-- PVE
warmgr.register_onwarend(WARTYPE.PVE_PERSONAL_TASK,function (warid,result)
	local war = warmgr.getwar(warid)
	if not table.find(war.attackers,war.pid) then
		return
	end
	local player = playermgr.getplayer(war.pid)
	local taskcontainer = player.taskdb:gettaskcontainer(war.taskid)
	taskcontainer:onwarend(war,result)
end)

warmgr.register_onwarend(WARTYPE.PVE_SHARE_TASK,function (warid,result)
	local war = warmgr.getwar(warid)
	if not table.find(war.attackers,war.pid) then
		return
	end
	local captain = playermgr.getplayer(war.pid)
	local taskcontainer = captain.taskdb:gettaskcontainer(war.taskid)
	local next_taskid = ctaskcontainer.nexttask(taskcontainer,war.taskid)
	for i,pid in ipairs(war.attackers) do
		local player = playermgr.getplayer(pid)
		local taskcontainer = player.taskdb:gettaskcontainer(war.taskid)
		taskcontainer._next_taskid = next_taskid
		taskcontainer:onwarend(war,result)
	end
end)

warmgr.register_onwarend(WARTYPE.PVE_CHAPTER,function (warid,result)
	local war = warmgr.getwar(warid)
	local player = playermgr.getplayer(war.attackers[1])
	player.chapterdb:onwarend(war,result)
end)

warmgr.register_onwarend(WARTYPE.PVE_BAOTU,function (warid,result)
	local war = warmgr.getwar(warid)
	huodongmgr.playunit.baotu.onwarend(war,result)
end)

warmgr.register_onwarend(WARTYPE.PVE_GUAJI,function (warid,result)
	local war = warmgr.getwar(warid)
	huodongmgr.playunit.guaji.onwarend(war,result)
end)


return warmgr.onwarend_callback
