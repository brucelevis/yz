netkuafu = netkuafu or {
	C2S = {},
	S2C = {},
}

local C2S = netkuafu.C2S
local S2C = netkuafu.S2C

function C2S.gosrv(player,request)
	local go_srvname = request.go_srvname
	local now_srvname = cserver.getsrvname()
	if now_srvname == go_srvname then
		return
	end
	if not srvlist[go_srvname] then
		return
	end
	if not cserver.isgamesrv(go_srvname) then
		return
	end
	playermgr.gosrv(player,go_srvname)
end

function C2S.gohome(player,request)
	local home_srvname = player.home_srvname
	if not home_srvname then
		return
	end
	playermgr.gohome(player)
end

return netkuafu
