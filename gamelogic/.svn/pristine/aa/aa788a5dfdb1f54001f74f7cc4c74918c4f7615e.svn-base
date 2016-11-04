
gm = require "gamelogic.gm.init"

--- 用法: startwar 战斗类型  战斗导表ID
--- 举例: startwar 1000 100000	-- 开始一场测试战斗,战斗导表ID为10000
function gm.startwar(args)
	local isok,args = checkargs(args,"int","int")
	if not isok then
		net.msg.S2C.notify(master_pid,"用法: startwar 战斗类型 战斗导表ID")
		return
	end
	local wartype = args[1]
	local wardataid = args[2]
	local fighters = master:getfighters()
	warmgr.startwar(fighters,nil,{
		wartype = wartype,
		wardataid = wardataid,
	})
end

--- 用法: 结束战斗 战斗ID 结果(>0:进攻方胜利,0--平局,<0:进攻方失败)
--- 举例: endwar 0 1		<=> 结束自身身上的战斗，战斗结果为：进攻方胜利
--- 举例: endwar 1001 0		<=> 结束战斗ID为1001的战斗，战斗结果为：平局
--- 举例: endwar 1001 -1	<=> 结束战斗ID为1001的战斗，战斗结果为：进攻方失败
function gm.endwar(args)
	local isok,args = checkargs(args,"int","int")
	if not isok then
		net.msg.S2C.notify(master_pid,"用法: 结束战斗 战斗ID 结果(>0:进攻方胜利,0--平局,<0:进攻方失败)")
		return
	end
	local warid = args[1]
	local result = args[2]
	if warid == 0 then
		if not master then
			return
		end
		warid = master:warid()
	end
	if not warid or warid == 0 then
		net.msg.S2C.notify(master_pid,"请指定一个战斗ID")
		return
	end
	warmgr.onwarend(warid,result)
end

--- 用法: 强制结束战斗 战斗ID
--- 举例: force_endwar 0		<=> 强制结束自身身上的战斗
--- 举例: force_endwar 1001		<=> 强制结束战斗ID为1001的战斗
--- 举例: force_endwar 1001		<=> 强制结束战斗ID为1001的战斗
function gm.force_endwar(args)
	local isok,args = checkargs(args,"int")
	if not isok then
		net.msg.S2C.notify(master_pid,"用法: 强制结束战斗 战斗ID")
		return
	end
	local warid = args[1]
	if warid == 0 then
		if not master then
			return
		end
		warid = master.warid
	end
	if not warid or warid == 0 then
		net.msg.S2C.notify(master_pid,"请指定一个战斗ID")
		return
	end
	warmgr.force_endwar(warid,"gm")
end

return gm
