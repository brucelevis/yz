nettask = nettask or {
	C2S = {},
	S2C = {},
}
local C2S = nettask.C2S
local S2C = nettask.S2C

function C2S.accepttask(player,request)
	local taskid = request.taskid
	local taskcontainer = player.taskdb:gettaskcontainer_bytaskid(taskid)
	local isok,msg = taskcontainer:can_accept(taskid)
	if not isok then
		if msg then
			net.msg.S2C.notify(player.pid,rmsg)
		end
		return
	end
	taskcontainer:accepttask(taskid,request.npcid)
end

function C2S.executetask(player,request)
	local taskid = request.taskid
	local taskcontainer = player.taskdb:gettaskcontainer_bytaskid(taskid)
	local isok,msg = taskcontainer:can_execute(taskid)
	if not isok then
		if msg then
			net.msg.S2C.notify(player.pid,msg)
		end
		return
	end
	taskcontainer:executetask(taskid,request.npcid,request.ext)
end

function C2S.finishtask(player,request)
	local taskid = request.taskid
	local taskcontainer = player.taskdb:gettaskcontainer_bytaskid(taskid)
	local isok,msg = taskcontainer:can_clientfinish(taskid)
	if not isok then
		if msg then
			net.msg.S2C.notify(player.pid,msg)
		end
		return
	end
	taskcontainer:clientfinishtask(taskid)
end

function C2S.submittask(player,request)
	local taskid = request.taskid
	local taskcontainer = player.taskdb:gettaskcontainer_bytaskid(taskid)
	local isok,msg = taskcontainer:can_submit(taskid)
	if not isok then
		if msg then
			net.msg.S2C.notify(player.pid,msg)
		end
		return
	end
	taskcontainer:submittask(taskid,request.npcid)
end

function C2S.giveuptask(player,request)
	local taskid = request.taskid
	local task = player.taskdb:gettask(taskid)
	if not task then
		nettask.S2C.deltask(pid,taskid)
		return
	end
	local taskcontainer = player.taskdb:gettaskcontainer_bytaskid(taskid)
	local isok,msg = taskcontainer:can_giveup(taskid)
	if not isok then
		if msg then
			net.msg.S2C.notify(pid,msg)
		end
		return
	end
	taskcontainer:giveuptask(taskid)
end


-- s2c
function S2C.addtask(pid,task)
	--[[
	sendpackage(pid,"task","addtask",{
		task = task,
	})
	--]]
end

function S2C.alltask(pid,tasks)
	--[[
	sendpackage(pid,"task","alltask",{
		tasks = tasks,
	})
	--]]
end

function S2C.deltask(pid,taskid)
	--sendpackage(pid,"task","deltask",{ taskid = taskid })
end

function S2C.updatetask(pid,task)
	--[[
	sendpackage(pid,"task","updatetask",{
		task = task,
	})
	--]]
end

return nettask
