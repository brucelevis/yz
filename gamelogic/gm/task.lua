gm = require "gamelogic.gm.init"

local task = {}

local function wrongfmt(player)
	net.msg.S2C.notify(player.pid,"指令格式错误,请参考task help")
	task.help(player)
end

function gm.task(args)
	local funcname = args[1]
	local player = playermgr.getplayer(master_pid)
	local func = task[funcname]
	if not func then
		wrongfmt(player)
		return
	end
	table.remove(args,1)
	func(player,args)
end

function task.help(player)
	net.msg.S2C.notify(player.pid,"task clear 清空所有任务")
end

function task.clear(player)
	player.taskdb:clear()
end
