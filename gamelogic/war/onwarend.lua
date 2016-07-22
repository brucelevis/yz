warmgr.onwarend_callback = {}

function qiecuo_onwarend(warid,result)
end

function personal_task_onwarend(warid,result)
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
end

function chapter_onwarend(warid,result)
	local war = warmgr.getwar(warid)
	local player = playermgr.getplayer(war.pid)
	if not player then
		return
	end
	player.chapterdb:onwarend(war,result)
end

warmgr.onwarend_callback[WARTYPE_PVP_QIECUO] = qiecuo_onwarend
warmgr.onwarend_callback[WARTYPE_PERSONAL_TASK] = personal_task_onwarend
warmgr.onwarend_callback[WARTYPE_CHAPTER] = chapter_onwarend

return onwarend_callback
