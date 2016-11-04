
gm = require "gamelogic.gm.init"

--- 指令: playerset
--- 用法: playerset 属性名 属性值 [玩家ID]
--- 举例: playerset lv 10 <=> 不指定玩家ID，将自身等级设置成10级
--- 举例: playerset lv 10 1000001 <=> 将1000001玩家等级设置成10级
function gm.playerset(args)
	local isok,args = checkargs(args,"string","string","*")
	if not isok then
		net.msg.S2C.notify(master_pid,"用法: playerset 属性名 属性值 [玩家ID]")
		return
	end
	local key = args[1]
	local chunk = loadstring("return " .. args[2])
	local pid = tonumber(args[3]) or master_pid
	local val = chunk()
	local player = playermgr.getplayer(pid)
	if not player then
		net.msg.S2C.notify(master_pid,string.format("玩家(%s)不在线",pid))
		return
	end
	local oldval = table.getattr(player,key)
	if type(oldval) == "function" then
		net.msg.S2C.notify(master_pid,"非法属性")
		return
	end
	table.setattr(player,key,val)

	net.msg.S2C.notify(master_pid,string.format("重新登录生效"))
end

--- 指令: addqualitypoint
--- 用法: addqualitypoint 增加的素质点 [玩家ID]
--- 举例: addqualitypoint 10 <=> 不指定玩家ID，将自身素质点增加10
--- 举例: addqualitypoint 10 1000001 <=> 将1000001玩家素质点增加10点
function gm.addqualitypoint(args)
	local isok,args = checkargs(args,"int","*")
	if not isok then
		net.msg.S2C.notify(master_pid,"用法: addqualitypoint 增加的素质点 [玩家ID]")
		return
	end
	local val = args[1]
	local pid = tonumber(args[2]) or master_pid
	local player = playermgr.getplayer(pid)
	if not player then
		net.msg.S2C.notify(master_pid,string.format("玩家(%s)不在线",pid))
		return
	end
	player:add_qualitypoint(val,"gm")
end

--- 指令: resetqualitypoint
--- 用法: resetqualitypoint [玩家ID]
--- 举例: resetqualitypoint <=> 不指定玩家ID，将自身素质点重置
--- 举例: resetqualitypoint 1000001 <=> 将1000001玩家素质点重置
function gm.resetqualitypoint(args)
	local isok,args = checkargs(args,"*")
	if not isok then
		net.msg.S2C.notify(master_pid,"用法: resetqualitypoint [玩家ID]")
		return
	end
	local pid = tonumber(args[1]) or master_pid
	local player = playermgr.getplayer(pid)
	if not player then
		net.msg.S2C.notify(master_pid,string.format("玩家(%s)不在线",pid))
		return
	end
	player:reset_qualitypoint()
end

--- 指令: addplayerexp
--- 用法: addplayerexp 经验值 [玩家ID]
--- 举例: addplayerexp 100 <=> 不指定玩家ID，将自身经验值增加100点
--- 举例: addplayerexp 100 1000001 <=> 将1000001玩家经验值增加100点
function gm.addplayerexp(args)
	local isok,args = checkargs(args,"int","*")
	if not isok then
		net.msg.S2C.notify(master_pid,"用法: addplayerexp 经验值 [玩家ID]")
		return
	end
	local val = args[1]
	local pid = tonumber(args[2]) or master_pid
	local player = playermgr.getplayer(pid)
	if not player then
		net.msg.S2C.notify(master_pid,string.format("玩家(%s)不在线",pid))
		return
	end
	player:addexp(val,"gm")
end

--- 指令: addplayerjobexp
--- 用法: addplayerjobexp 经验值 [玩家ID]
--- 举例: addplayerjobexp 100 <=> 不指定玩家ID，将自身职业经验值增加100点
--- 举例: addplayerjobexp 100 1000001 <=> 将1000001玩家职业经验值增加100点
function gm.addplayerjobexp(args)
	local isok,args = checkargs(args,"int","*")
	if not isok then
		net.msg.S2C.notify(master_pid,"用法: addplayerjobexp 经验值 [玩家ID]")
		return
	end
	local val = args[1]
	local pid = tonumber(args[2]) or master_pid
	local player = playermgr.getplayer(pid)
	if not player then
		net.msg.S2C.notify(master_pid,string.format("玩家(%s)不在线",pid))
		return
	end
	player:addjobexp(val,"gm")
end

return gm
