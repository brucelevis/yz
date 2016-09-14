netfriend = netfriend or {
	C2S = {},
	S2C = {},
}
local C2S = netfriend.C2S
local S2C = netfriend.S2C

function C2S.apply_addfriend(player,request)
	local pid = assert(request.pid)
	return player.frienddb:apply_addfriend(pid)
end

function C2S.agree_addfriend(player,request)
	local pid = assert(request.pid)	
	return player.frienddb:agree_addfriend(pid)
end

function C2S.reject_addfriend(player,request)
	local pid = assert(request.pid)
	return player.frienddb:reject_addfriend(player,pid)
end

function C2S.delfriend(player,request)
	local pid = assert(request.pid)
	return player.frienddb.req_delfriend(pid)
end

function C2S.sendmsg(player,request)
	local pid = assert(request.pid)
	local msg = assert(request.msg)
	return player.frienddb:sendmsg(pid,msg)
end


-- s2c
function S2C.sync(pid,request)
	sendpackage(pid,"friend","sync",request)
end

local typs = {applyer = 0,friend = 1,toapply = 2,}
function S2C.dellist(pid,typ,pids)
	typ = assert(typs[typ],"Invalid friend type:" .. tostring(typ))
	if type(pids) == "number" then
		pids = {pids,}
	end
	sendpackage(pid,"friend","dellist",{
		pids = pids,
		type = typ,
	})
end

function S2C.addlist(pid,typ,pids,newflag)
	typ = assert(typs[typ],"Invalid friend type:" .. tostring(typ))
	if type(pids) == "number" then
		pids = {pids,}
	end
	sendpackage(pid,"friend","addlist",{
		pids = pids,
		type = typ,
		newflag = newflag,
	})
end

function S2C.addmsgs(pid,srcpid,msgs)
	if type(msgs) == "string" then
		msgs = {msgs,}
	end
	sendpackage(pid,"friend","addmsgs",{
		pid = srcpid,
		msgs = msgs,
	})
end

return netfriend

