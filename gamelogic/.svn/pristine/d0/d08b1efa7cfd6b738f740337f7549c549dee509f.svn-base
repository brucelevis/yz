
local talk_options = {
	[1] = { "确认","寻找组队" },
}

ctasknpc = class("ctasknpc",ctemplnpc)

function ctasknpc:init()
	ctemplnpc.init(self)
end

function ctasknpc:getrespondfunc(respond)
	local funcname = format("chooseanswer%d",respond)
	return self[funcname]
end

function ctasknpc:getoptions(respond)
	return talk_options[respond]
end

-- 选项1:执行任务,2:寻找队伍
function ctasknpc:chooseanswer1(player,answer)
	local task = self.resmgr.playunit
	local taskcontainer = self.resmgr.template
	if not task or not taskcontainer then
		return
	end
	if not taskcontainer:gettask(task.taskid) or not taskcontainer:getnpc(task,self.id) then
		return
	end
	if answer == 1 then
		local isok,msg = taskcontainer:can_execute(task)
		if not isok then
			net.msg.S2C.notify(player.pid,msg)
			return
		end
		taskcontainer:executetask2(task)
	elseif answer == 2 then
		-- TODO 寻求组队
	end
end
