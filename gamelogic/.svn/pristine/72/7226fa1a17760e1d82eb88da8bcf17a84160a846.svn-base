nettask = nettask or {
	C2S = {},
	S2C = {},
}
local C2S = nettask.C2S
local S2C = nettask.S2C

function C2S.accepttask(player,request)
	local pid = player.pid
	local taskid = request.taskid
	local isok,msg = player.taskdb:canaccepttask(taskid)
	if not isok then
		if msg then
			net.msg.S2C.notify(player,msg)
		end
		return
	end
	player.taskdb:accepttask(taskid)
end

function C2S.finishtask(player,request)
	local taskid = request.taskid
	local taskdb = player.taskmgr:gettaskdb_by_taskid(taskid)
	local taskdata = taskdb:gettaskdata(taskid)
	if not taskdata.client_canfinish then
		return
	end
	local task = player.taskdb:gettask(taskid)
	if not task then
		return
	end
	player.taskdb:finishtask(task)
end

function C2S.submittask(player,request)
	local pid = player.pid
	local taskid = request.taskid
	local task = player.taskdb:gettask(taskid)
	if not task then
		return
	end
	local isok,msg = player.taskddb:cansubmittask(taskid)
	if not isok then
		if msg then
			net.msg.S2C.notify(pid,msg)
		end
		return
	end
	player.taskdb:submittask(task)
end

function C2S.giveuptask(player,request)
	local pid = player.pid
	local taskid = request.taskid
	local task = player.taskddb:gettask(taskid)
	if not task then
		sendpackage(pid,"task","deltask",{taskid=taskid})
		return
	end
	local isok,msg = player.taskdb:cangiveuptask(taskid)
	if not isok then
		if msg then
			net.msg.S2C.notify(pid,msg)
		end
		return
	end
	player.taskdb:giveuptask(task)
end


-- s2c
return nettask
