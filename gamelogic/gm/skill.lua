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
		gm.notify("用法: skill addpoint 增加剩余技能点")
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
		gm.notify("用法: skill setjobskill 职业ID")
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

function skill.wield(player,args)
	local isok,args = checkargs(args,"int","int")
	if not isok then
		gm.notify("用法: skill wield 技能id 使用位置(1～4)")
		return
	end
	local skillid = args[1]
	local position = args[2]
	player.warskilldb:wieldskill(skillid,position)
end

