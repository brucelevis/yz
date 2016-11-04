


local function docmd(srvname,pid,methodname,...)
	local kuafuplayer = playermgr.getkuafuplayer(pid)
	if kuafuplayer then
		-- 正常流程很难走到这里，只有极限情况:玩家跨服(如跨服载入数据)的同时,某服向原服发起了rpc操作
		local go_srvname = kuafuplayer.go_srvname
		logger.log("warning","netcluster",format("[playermethod#forward] srvname=%s->%s pid=%s methodname=%s args=%s",srvname,go_srvname,pid,methodname,{...}))
		return rpc.call(go_srvname,"playermethod",pid,methodname,...)
	end
	local player = playermgr.getplayer(pid)	
	if not player then
		player = playermgr.loadofflineplayer(pid)
	end
	assert(player,"Not found pid:" .. tostring(pid))
	local modname,sep,funcname = string.match(methodname,"(.*)([.:])(.+)$")	
	if not (modname and sep and funcname) then
		error("[playermethod] Invalid methodname:" .. tostring(methodname))
	end
	local mod = player
	if modname ~= "" then
		local attrs = {}
		for attr in string.gmatch(modname,"([^.]+)") do
			mod = mod[attr]
		end
	end
	local func = assert(mod[funcname],"[playermethod] Unknow methodname:" .. tostring(methodname))
	if type(func) ~= "function" then
		assert(sep == ".")
		return func
	end
	if sep == "." then
		return func(...)
	elseif sep == ":" then
		return func(mod,...)
	else
		error("Invalid function seperator:" .. tostring(sep))
	end
end

netcluster_playermethod = netcluster_playermethod or {}

function netcluster_playermethod.dispatch(srvname,cmd,...)
	return docmd(srvname,cmd,...)
end

return netcluster_playermethod
