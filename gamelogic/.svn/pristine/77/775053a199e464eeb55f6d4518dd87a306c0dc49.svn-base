gm = require "gamelogic.gm.init"

--- 用法: mergeserver 源服务器 目标服务器名
function gm.mergeserver(args)
	local isok,args = checkargs("string","string")
	if not isok then
		net.msg.S2C.notify(master_pid,"用法: mergeserver 源服务器 目标服务器名")
		return
	end
	local src_srvname = assert(args[1])
	local dst_srvname = assert(args[2])
	if not cserver.isvalidsrv(src_srvname) then
		net.msg.S2C.notify(master_pid,string.format("源服务器(%s)不存在",src_srvname))
		return
	end
	if not cserver.isvalidsrv(dst_srvname) then
		net.msg.S2C.notify(master_pid,string.format("目标服务器(%s)不存在",src_srvname))
		return
	end
	local srcdb = dbmgr.getdb(src_srvname)
	local dstdb = dbmgr.getdb(dst_srvname)
	gm.domergeserver(srcdb,dstdb)
end

function gm.domergeserver(srcdb,dstdb)
	-- 合服逻辑
end
