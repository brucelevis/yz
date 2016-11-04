
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

return gm
