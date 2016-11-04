warmgr.onendwar_callback = {}

function qiecuo_onendwar(warid,result)
end

function personal_task_onendwar(warid,result)
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

warmgr.onendwar_callback[WARTYPE_PVP_QIECUO] = qiecuo_onendwar
warmgr.onendwar_callback[WARTYPE_PERSONAL_TASK] = personal_task_onendwar

return onendwar_callback
