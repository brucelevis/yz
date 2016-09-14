nettask = nettask or {
	C2S = {},
	S2C = {},
}
local C2S = nettask.C2S
local S2C = nettask.S2C

--c2s
function C2S.opentask(player,request)
	local taskkey = assert(request.taskkey)
	local taskcontainer = player.taskdb[taskkey]
	if not taskcontainer then
		return
	end
	local taskid = request.taskid
	if taskid and taskcontainer:can_directaccept(taskid) then
		taskcontainer:directaccept(taskid)
	else
		taskcontainer:opentask()
	end
end

-- 此接口仅测试使用
function C2S.accepttask(player,request)
	if not cserver.isinnersrv() then
		return
	end
	local taskid = assert(request.taskid)
	local taskcontainer = player.taskdb:gettaskcontainer(taskid)
	if not taskcontainer then
		return
	end
	local isok,msg = taskcontainer:can_accept(taskid)
	if not isok then
		if msg then
			net.msg.S2C.notify(player.pid,msg)
		end
		return
	end
	taskcontainer:accepttask(taskid)
end

function C2S.executetask(player,request)
	local taskid = assert(request.taskid)
	local taskcontainer = player.taskdb:gettaskcontainer(taskid)
	if not taskcontainer then
		return
	end
	local ext = nil
	if request.ext then
		ext = cjson.decode(request.ext)
	end
	local isok,msg = taskcontainer:executetask(taskid,ext)
	if not isok and msg then
		net.msg.S2C.notify(player.pid,msg)
	end
end

function C2S.finishtask(player,request)
	local taskid = assert(request.taskid)
	local taskcontainer = player.taskdb:gettaskcontainer(taskid)
	if not taskcontainer then
		return
	end
	local isok,msg = taskcontainer:clientfinishtask(taskid)
	if not isok and msg then
		net.msg.S2C.notify(player.pid,msg)
	end
end

function C2S.submittask(player,request)
	local taskid = assert(request.taskid)
	local taskcontainer = player.taskdb:gettaskcontainer(taskid)
	if not taskcontainer then
		return
	end
	local isok,msg = taskcontainer:can_submit(taskid)
	if not isok then
		if msg then
			net.msg.S2C.notify(player.pid,msg)
		end
		return
	end
	taskcontainer:submittask(taskid)
end

function C2S.giveuptask(player,request)
	local taskid = assert(request.taskid)
	local pid = player.pid
	local task = player.taskdb:gettask(taskid)
	if not task then
		nettask.S2C.deltask(pid,taskid)
		return
	end
	local taskcontainer = player.taskdb:gettaskcontainer(taskid)
	local isok,msg = taskcontainer:giveuptask(taskid)
	if not isok and msg then
		net.msg.S2C.notify(player.pid,msg)
	end
end

function C2S.looktasknpc(player,request)
	local taskid = assert(request.taskid)
	local npcid = assert(request.npcid)
	local taskcontainer = player.taskdb:gettaskcontainer(taskid)
	if not taskcontainer then
		return
	end
	local isok,msg = taskcontainer:looktasknpc(taskid,npcid)
	if not isok and msg then
		net.msg.S2C.notify(player.pid,msg)
	end
end

-- s2c
function S2C.addtask(pid,task)
	sendpackage(pid,"task","addtask",{
		task = task,
	})
end

function S2C.alltask(pid,tasks)
	sendpackage(pid,"task","alltask",{
		tasks = tasks,
	})
end

function S2C.deltask(pid,taskid)
	sendpackage(pid,"task","deltask",{ taskid = taskid })
end

function S2C.finishtask(pid,taskid,submitnpc)
	sendpackage(pid,"task","finishtask",{
		taskid = taskid,
		submitnpc = submitnpc,
	})
end

function S2C.updatetask(pid,task)
	sendpackage(pid,"task","updatetask",{
		task = task,
	})
end

function S2C.tasktalk(pid,taskid,textid,transstr,respondid)
	if next(transstr) then
		transstr = cjson.encode(transstr)
	else
		transstr = nil
	end
	sendpackage(pid,"task","tasktalk",{
		taskid = taskid,
		textid = textid,
		transstr = transstr,
		respondid = respondid,
	})
end

function S2C.update_canaccept(pid,canaccept)
	sendpackage(pid,"task","update_canaccept",{ canaccept = canaccept })
end

return nettask
