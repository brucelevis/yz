nettask = nettask or {
	C2S = {},
	S2C = {},
}
local C2S = nettask.C2S
local S2C = nettask.S2C

function C2S.accepttask(player,request)
	local pid = player.pid
	local taskid = request.taskid
	local taskcontainer = player.taskdb:gettaskcontainer_bytaskid(taskid)
	local isok,msg = taskcontainer:can_accepttask(taskid)
	if not isok then
		if msg then
			net.msg.S2C.notify(player,msg)
		end
		return
	end
	taskcontainer:accepttask(taskid)
end

function C2S.finishtask(player,request)
	local taskid = request.taskid
	local taskcontainer = player.taskdb:gettaskcontainer_bytaskid(taskid)
	if not taskcontainer:can_clientfinish(taskid) then
		return
	end
	local task = player.taskdb:gettask(taskid)
	if not task then
		return
	end
	taskcontainer:finishtask(task)
end

function C2S.submittask(player,request)
	local pid = player.pid
	local taskid = request.taskid
	local task = player.taskdb:gettask(taskid)
	if not task then
		return
	end
	local taskcontainer = player.taskdb:gettaskcontainer_bytaskid(taskid)
	local isok,msg = taskcontainer:can_submittask(taskid)
	if not isok then
		if msg then
			net.msg.S2C.notify(pid,msg)
		end
		return
	end
	taskcontainer:submittask(task)
end

function C2S.giveuptask(player,request)
	local pid = player.pid
	local taskid = request.taskid
	local task = player.taskddb:gettask(taskid)
	if not task then
		sendpackage(pid,"task","deltask",{taskid=taskid})
		return
	end
	local taskcontainer = player.taskdb:gettaskcontainer_bytskid(taskid)
	local isok,msg = taskcontainer:can_giveuptask(taskid)
	if not isok then
		if msg then
			net.msg.S2C.notify(pid,msg)
		end
		return
	end
	taskcontainer:giveuptask(task)
end


-- s2c
return nettask
