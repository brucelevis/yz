netfriend = netfriend or {
	C2S = {},
	S2C = {},
}
local C2S = netfriend.C2S
local S2C = netfriend.S2C

function C2S.apply_addfriend(player,request)
	local pid = assert(request.pid)
	local isok,msg = player.frienddb:apply_addfriend(pid)
	if msg then
		net.msg.S2C.notify(player.pid,msg)
	end
end

function C2S.agree_addfriend(player,request)
	local pid = assert(request.pid)
	local isok,msg = player.frienddb:agree_addfriend(pid)
	if msg then
		net.msg.S2C.notify(player.pid,msg)
	end
end

function C2S.reject_addfriend(player,request)
	local pid = assert(request.pid)
	return player.frienddb:reject_addfriend(pid)
end

function C2S.delfriend(player,request)
	local pid = assert(request.pid)
	return player.frienddb:req_delfriend(pid)
end

function C2S.sendmsg(player,request)
	local pid = assert(request.pid)
	local msg = assert(request.msg)
	local isok,packmsg = player.frienddb:sendmsg(pid,msg)
	if isok then
		net.friend.S2C.addmsgs(player.pid,packmsg)
	end
end

function C2S.search(player,request)
	local findplayer = assert(request.findplayer)
	local result = {}
	local resume
	local pid = tonumber(findplayer)
	if pid then
		resume = player.frienddb:search_bypid(pid)
		table.insert(result,resume)
	end
	resume = player.frienddb:search_byname(findplayer)
	table.insert(result,resume)
	if table.isempty(result) then
		net.msg.S2C.notify(player.pid,"找不到该玩家")
		return
	end
	net.friend.S2C.search_result(player.pid,result)
end

function C2S.change_recommend(player,request)
	local isok = player.frienddb:change_recommend()
	if not isok then
		net.msg.S2C.notify(player.pid,language.format("没有更多的玩家可以推荐了"))
	end
end

function C2S.apply_allrecommend(player,request)
	local pids = copy(player.frienddb.recommendlist)
	for _,pid in ipairs(pids) do
		player.frienddb:apply_addfriend(pid)
	end
end

function C2S.agree_allapply(player,request)
	local pids = copy(player.frienddb.applyerlist)
	for _,pid in ipairs(pids) do
		player.frienddb:agree_addfriend(pid)
	end
end

function C2S.reject_allapply(player,request)
	local pids = copy(player.frienddb.applyerlist)
	for _,pid in ipairs(pids)do
		player.frienddb:reject_addfriend(pid)
	end
end

function C2S.addblack(player,request)
	local pid = assert(request.pid)
	player.frienddb:addblack(pid)
end

function C2S.delblack(player,request)
	local pid = assert(request.pid)
	player.frienddb:delblack(pid)
end

-- s2c
function S2C.sync_resume(pid,data)
	sendpackage(pid,"friend","sync_resume",{ resume = data, })
end

function S2C.sync_frddata(pid,data)
	sendpackage(pid,"friend","sync_frddata",data)
end

local typs = {applyer = 0,friend = 1,toapply = 2,recommend = 3,black = 4,}
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

