gm = require "gamelogic.gm.init"

local shop = {}

function gm.shop(args)
	local funcname = args[1]
	local player = playermgr.getplayer(master_pid)
	if not player then
		return
	end
	local func = shop[funcname]
	print(funcname,func)
	if not func then
		net.msg.S2C.notify(master_pid,"指令未找到，查看帮助:help shop")
		return
	end
	table.remove(args,1)
	func(player,args)
end

--- 指令: shop refresh
--- 用法: shop refresh grocery <=> 刷新杂货店
--- 用法: shop refresh secret  <=> 刷新神秘商店
function shop.refresh(player,args)
	local isok,arrgs = checkargs(args,"string")
	if not isok then
		net.msg.S2C.notify(player.pid,"shop refresh grocery <=> 刷新杂货店")
		return
	end
	local shopname = args[1]
	local shop = globalmgr.shop[shopname] or player.shopdb[shopname]
	if shop and shop._refresh then
		shop:_refresh("gm")
	end
end
