warmgr.onwarend_callback = {}

function warmgr.register_onwarend(wartype,callback)
	warmgr.onwarend_callback[wartype] = callback
end

warmgr.register_onwarend(WARTYPE.PVP_QIECUO,function (warid,result)
end)

warmgr.register_onwarend(WARTYPE.PERSONAL_TASK,function (warid,result)
	local war = warmgr.getwar(warid)
	local player = playermgr.getplayer(war.pid)
	if not player then
		return
	end
	local taskcontainer = player.taskdb:gettaskcontainer(war.taskid)
	if not taskcontainer then
		return
	end
	taskcontainer:onwarend(war,result)
end)

warmgr.register_onwarend(WARTYPE.PVE_CHAPTER,function (warid,result)
	local war = warmgr.getwar(warid)
	local player = playermgr.getplayer(war.pid)
	if not player then
		return
	end
	player.chapterdb:onwarend(war,result)
end)

warmgr.register_onwarend(WARTYPE.PVE_BAOTU,function (warid,result)
	local war = warmgr.getwar(warid)
	local player = playermgr.getplayer(war.pid)
	if not player then
		return
	end
	huodongmgr.playunit.baotu.onwarend(warid,result)
end)

return onwarend_callback
