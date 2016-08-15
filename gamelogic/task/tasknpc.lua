
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

function ctasknpc:getcallback(respond)
	local callback = function(player,answer)
		local func = self:getrespondfunc(respond)
		if type(func) == "function" then
			func(self,player,answer)
		else
			self:answer(player,answer)
		end
	end
	return callback
end


-- 选项1:执行任务,2:寻找队伍
function ctasknpc:chooseanswer1(player,answer)
	local task = self.resmgr.playunit
	local taskcontainer = self.resmgr.template
	if not task or not taskcontainer then
		return
	end
	if not taskcontainer:getnpc(task,self.id) then
		return
	end
	if answer == 1 then
		local isok,msg = taskcontainer:executetask(task.taskid)
		if not isok and msg then
			net.msg.S2C.notify(player.pid,msg)
			return
		end
	elseif answer == 2 then
		-- TODO 寻求组队
	end
end
