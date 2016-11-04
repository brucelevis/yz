gm = require "gamelogic.gm.init"

---指令: addgold
---用法: addgold 数量 [玩家ID]
---举例: addgold 10 <=> 给自身增加10金币
---举例: addgold 10 1000001 <=> 给玩家1000001增加10金币
function gm.addgold(args)
	local isok,args = checkargs(args,"int","*")
	if not isok then
		net.msg.S2C.notify(master_pid,"用法: addgold 数量 [玩家ID]")
		return
	end
	local val = args[1]
	local pid = tonumber(args[2]) or master_pid
	local player = playermgr.getplayer(pid)
	if not player then
		net.msg.S2C.notify(master_pid,string.format("玩家(%s)不在线",pid))
		return
	end
	player:addgold(val,"gm")
end

---指令: addsilver
---用法: addsilver 数量 [玩家ID]
---举例: addsilver 10 <=> 给自身增加10银币
---举例: addsilver 10 1000001 <=> 给玩家1000001增加10银币
function gm.addsilver(args)
	local isok,args = checkargs(args,"int","*")
	if not isok then
		net.msg.S2C.notify(master_pid,"用法: addsilver 数量 [玩家ID]")
		return
	end
	local val = args[1]
	local pid = tonumber(args[2]) or master_pid
	local player = playermgr.getplayer(pid)
	if not player then
		net.msg.S2C.notify(master_pid,string.format("玩家(%s)不在线",pid))
		return
	end
	player:addsilver(val,"gm")
end

---指令: addcoin
---用法: addcoin 数量 [玩家ID]
---举例: addcoin 10 <=> 给自身增加10铜币
---举例: addcoin 10 1000001 <=> 给玩家1000001增加10铜币
function gm.addcoin(args)
	local isok,args = checkargs(args,"int","*")
	if not isok then
		net.msg.S2C.notify(master_pid,"用法: addcoin 数量 [玩家ID]")
		return
	end
	local val = args[1]
	local pid = tonumber(args[2]) or master_pid
	local player = playermgr.getplayer(pid)
	if not player then
		net.msg.S2C.notify(master_pid,string.format("玩家(%s)不在线",pid))
		return
	end
	player:addcoin(val,"gm")
end

---指令: addres
---用法: addres 资源类型 数量 [玩家ID]
---举例: addres gold 10 <=> 给自身增加10金币
---举例: addres silver 10 1000001 <=> 给玩家1000001增加10银币
function gm.addres(args)
	local isok,args = checkargs(args,"string","int","*")
	if not isok then
		net.msg.S2C.notify(master_pid,"用法: addres 资源类型 数量 [玩家ID]")
		return
	end
	local typ = args[1]
	local val = args[2]
	local pid = tonumber(args[3]) or master_pid
	local player = playermgr.getplayer(pid)
	if not player then
		net.msg.S2C.notify(master_pid,string.format("玩家(%s)不在线",pid))
		return
	end
	player:addres(typ,val,"gm",true)
end

--- 用法: chongzhi 充值项ID
--- 举例: chongzhi 1	<=> GM模拟充值第一项
function gm.chongzhi(args)
	local isok,args = checkargs(args,"int")
	if not isok then
		net.msg.S2C.notify(master_pid,"用法: chongzhi 充值项ID")
		return
	end
	local id = args[1]
	local product = master:getprodcut(id)
	if not product then
		net.msg.S2C.notify(master_pid,"该充值项不存在")
		return
	end
	local product = {
		id = id,
		rmb = product.rmb,
	}
	master:chongzhi(product)
end
