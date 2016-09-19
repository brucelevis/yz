
local function getcmd(t,cmd)
	local cmd = string.format("return %s",cmd)
	t[cmd] = load(cmd,"=(load)","bt",_G)
	return t[cmd]
end
local compile_cmd = setmetatable({},{__index=getcmd})

local function docmd(srvname,cmd,...)
	local attrname,sep,funcname = string.match(cmd,"^(.*)([.:])(.+)$")	
	local chunk = compile_cmd[attrname]
	local caller = chunk()
	if type(caller) == "function" then
		caller = caller()
	end
	local func = caller[funcname]
	if sep == "." then
		return func(...)
	else
		return func(caller,...)
	end
end

netcluster_rpc = netcluster_rpc or {}

netcluster_rpc.docmd = docmd

function netcluster_rpc.dispatch(srvname,cmd,...)
	return docmd(srvname,cmd,...)
end

return netcluster_rpc
