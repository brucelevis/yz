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
	local team = player:getteam()
	if team and team.captain == player.pid then
		teammgr:gosrv(team.id,go_srvname)
	else
		playermgr.gosrv(player,go_srvname)
	end
end

-- 已废弃:跨服统一用gosrv处理
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
	local allsrv_status = cserver.allsrv_status()
	for srvname,srv in pairs(data_RoGameSrvList) do
		if clustermgr.needconnect(srvname,self_srvname) and
			clustermgr.isconnect(srvname) then
			local srvinfo = allsrv_status[srvname]
			if not srvinfo or (istrue(srvinfo.isopen) and srvinfo.status ~= 3) then  -- 3: 爆满
				table.insert(srvlist,netkuafu.packsrv(srv))
			end
		end
	end
	sendpackage(player.pid,"kuafu","srvlist",{
		srvlist = srvlist,
		now_srvname = cserver.getsrvname(),
		home_srvname = player.home_srvname or cserver.getsrvname(),
	})
end

return netkuafu
