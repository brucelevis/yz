local patten = "../src/?.lua"

local ignore_module = {
	"gamelogic%.service%..+d",
}

local srvname = skynet.getenv("srvname")
hotfix = hotfix or {}

function hotfix.hotfix(modname)
	local is_gamelogic = modname:sub(1,9) == "gamelogic"
	local is_proto = modname:sub(1,5) == "proto"
	-- 只允许游戏逻辑+协议更新
	if not (is_gamelogic or is_proto) then
		logger.log("warning","hotfix",string.format("[cann't hotfix non-script code] module=%s",modname))
		return
	end
	if modname:sub(-4,-1) == ".lua" then
		modname = modname:sub(1,-5)
	end
	for i,patten in ipairs(ignore_module) do
		if modname == string.match(modname,patten) then
			return
		end
	end
	modname = string.gsub(modname,"/",".")
	modname = string.gsub(modname,"\\",".")
	skynet.cache.clear()
	local chunk,err
	local errlist = {}
	local env = _ENV or _G
	env.__hotfix = nil
	local name = string.gsub(modname,"%.","/")
	for pat in string.gmatch(patten,"[^;]+") do
		local filename = string.gsub(pat,"?",name)
		chunk,err = loadfile(filename,"bt",env)
		if chunk then
			break
		else
			table.insert(errlist,err)
		end
	end
	if not chunk then
		local msg = string.format("[hotfix fail] module=%s reason=%s",modname,table.concat(errlist,"\n"))
		logger.log("error","hotfix",msg)
		skynet.error(msg)
		print(msg)
		return
	end
	local msg = string.format("[hotfix] module=%s",modname)
	logger.log("info","hotfix",msg)
	print(msg)
	local oldmod = package.loaded[modname]
	local newmod = chunk()
	package.loaded[modname] = newmod
	if type(env.__hotfix) == "function" then
		env.__hotfix(oldmod)
	end
	-- 通知底层更新协议
	-- 注意: proto.inittypecommon更新后必须加上proto.init的更新才能真正更新到,其他模块无此限制
	-- 注意: 更新协议时不要轻易更改字段名字，字段名字该后，上层逻辑也要跟着改才行
	if is_proto then
		g_serverinfo.newevent("plus_hotifx",{lines={modname,}})
		
	end
	return true
end

return hotfix

