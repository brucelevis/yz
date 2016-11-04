gm = require "gamelogic.gm.init"

local skill = {}

local function wrongfmt(player)
	net.msg.S2C.notify(player.pid,"指令格式错误,请参考skill help")
	skill.help(player)
end

function gm.skill(args)
	local funcname = args[1]
	local player = playermgr.getplayer(master_pid)
	local func = skill[funcname]
	if not func then
		wrongfmt(player)
		return
	end
	table.remove(args,1)
	func(player,args)
end

function skill.help(player)
	net.msg.S2C.notify(player.pid,"skill addpoint num 增加num点剩余技能点")
	net.msg.S2C.notify(player.pid,"skill setjobskill job 增加职业job所属的技能")
	net.msg.S2C.notify(player.pid,"skill clear 清空剩余技能点和所有技能")
end

function skill.addpoint(player,args)
	local isok,args = checkargs(args,"int")
	if not isok then
		wrongfmt(player)
		return
	end
	local point = args[1]
	player.warskilldb:addpoint(point,"test")
end

function skill.setjobskill(player,args)
	local isok,args = checkargs(args,"int")
	if not isok then
		wrongfmt(player)
		return
	end
	local job = args[1]
	player.warskilldb:openskills(job)
end

function skill.clear(player)
	player.warskilldb.skillpoint = 0
	player.warskilldb:clear()
end

