gm = require "gamelogic.gm.init"

--- 指令: additem
--- 用法: additem 物品类型 数量 [玩家ID]
--- 举例: additem 801001 3  <=> 增加3个801001物品
--- 举例: additem 801001 3 1000001 <=> 给玩家1000001增加3个801001物品
function gm.additem(args)
	local isok,args = checkargs(args,"int","int","*")
	if not isok then
		net.msg.S2C.notify(master_pid,"用法: additem 物品类型 数量 [玩家ID]")
		return
	end
	local itemtype = args[1]
	local num = args[2]
	local pid = tonumber(args[3]) or master_pid
	local player = playermgr.getplayer(pid)
	if not player then
		net.msg.S2C.notify(master_pid,string.format("玩家(%s)不在线",pid))
		return
	end
	player:additembytype(itemtype,num,nil,"gm",true)
end

--- 指令: itemset
--- 用法: itemset 物品ID 属性名 属性值
--- 举例: itemset 1 bind 1 <=>  将ID为1的物品绑定标志设为1
function gm.itemset(args)
	local isok,args = checkargs(args,"int","string","string")
	if not isok then
		net.msg.S2C.notify(master_pid,"用法: itemset 物品ID 属性名 属性值")
		return
	end
	local itemid = args[1]
	local key = args[2]
	local chunk = loadstring("return " .. args[3])
	local val = chunk()
	local item = master:getitem(itemid)
	if not item then
		net.msg.S2C.notify(master_pid,"ID为%s的物品不存在",itemid)
		return
	end
	local oldval = table.getattr(item,key)
	if type(oldval) == "function" then
		net.msg.S2C.notify(master_pid,"非法属性")
		return
	end
	table.setattr(item,key,val)
	net.msg.S2C.notify(master_pid,string.format("重新登录生效"))
end

