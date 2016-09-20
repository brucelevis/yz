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

function C2S.search(player,request)
	local pid = request.pid
	local name = request.name
	if pid then
		player.frienddb:search_bypid(pid)
	else
		player.frienddb:search_byname(name)
	end
end

function C2S.change_recommend(player,request)
	player.friedndb:change_recommand()
end

-- s2c
function S2C.sync(pid,data)
	sendpackage(pid,"friend","sync",data)
end

local typs = {applyer = 0,friend = 1,toapply = 2,recommend = 3,}
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

function S2C.addmsgs(pid,msgs)
	if not table.isarray(msgs) then
		local array = {}
		table.insert(array,msgs)
		msgs = array
	end
	sendpackage(pid,"friend","addmsgs",{
		msgs = msgs,
	})
end

function S2C.search_result(pid,resumes)
	sendpackage(pid,"friend","search_result",{
		resumes = resumes,
	})
end

return netfriend

