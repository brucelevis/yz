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
	if not data_RoGameSrvList[go_srvname] then
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

function netkuafu.packsrv(srv)
	return {
		srvname = srv.srvname,
		showsrvname = srv.showsrvname,
		srvno = srv.srvno,
		ip = srv.ip,
		port = srv.port,
		zonename = srv.zonename,
		showzonename = srv.showzonename,
	}
end

function C2S.srvlist(player,request)
	local srvlist = {}
	local self_srvname = cserver.getsrvname()
	local self_srv = data_RoGameSrvList[self_srvname]
	for srvname,srv in pairs(data_RoGameSrvList) do
		if istrue(srv.isopen) and srv.zonename == self_srv.zonename then
			table.insert(srvlist,netkuafu.packsrv(srv))
		end
	end
	sendpackage(player.pid,"kuafu","srvlist",{
		srvlist = srvlist,
	})
end

return netkuafu
