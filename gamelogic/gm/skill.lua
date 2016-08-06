gm = require "gamelogic.gm.init"

local skill = {}

function gm.skill(args)
	local funcname = args[1]
	local player = playermgr.getplayer(master_pid)
	local func = skill[funcname]
	if not func then
		return
	end
	table.remove(args,1)
	func(player,args)
end

--- 指令: skill addpoint
--- 用法: skill addpoint 增加剩余技能点
--- 举例: skill addpoint 10 <=> 增加自身10点剩余技能点
function skill.addpoint(player,args)
	local isok,args = checkargs(args,"int")
	if not isok then
		net.msg.S2C.notify(player.pid,"用法: skill addpoint 增加剩余技能点")
		return
	end
	local point = args[1]
	player.warskilldb:addpoint(point,"test")
end


--- 指令: skill setjobskill
--- 用法: skill setjobskill 10001
--- 举例: skill setjobskill 10001 <=> 增加职业为10001的所有技能
function skill.setjobskill(player,args)
	local isok,args = checkargs(args,"int")
	if not isok then
		net.msg.S2C.notify(player.pid,"用法: skill setjobskill 职业ID")
		return
	end
	local job = args[1]
	player.warskilldb:openskills(job)
end

--- 指令: skill clear
--- 举例: skill clear <=> 清空自身所有技能
function skill.clear(player)
	player.warskilldb.skillpoint = 0
	player.warskilldb:clear()
end

