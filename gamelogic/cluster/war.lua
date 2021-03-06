netcluster_war = netcluster_war or {}

-- warsrv -> gamesrv 协议处理
local CMD = {}
function CMD.echo(srvname,request)
	logger.log("debug","war",format("[CMD.echo] srvname=%s request=%s",srvname,request))
	return request  -- 返回给游戏服的值，一般协议无需返回，这里仅作测试
end

function CMD.forward(srvname,request)
	local pids = assert(request.pids,"no pid")
	local cmd = assert(request.cmd)
	local protoname,subprotoname = string.match(cmd,"([^_]-)%_(.+)")
	local request = request.request
	for i,pid in ipairs(pids) do
		sendpackage(pid,protoname,subprotoname,request)
	end
end

function CMD.warresult(srvname,request)
	local warid = assert(request.warid)
	local result = assert(request.result)
	warmgr.onwarend(warid,result)
end

function CMD.delitem(srvname,request)
	local warid = assert(request.warid)
	local pid = assert(request.pid)
	local itemid = assert(request.itemid)
	local num = assert(request.num)
	local player = playermgr.getplayer(pid)
	if player then
		local item = player.itemdb:getitem(itemid)
		if item then
			assert(item.num >= num)
			player.itemdb:costitembyid(itemid,num,string.format("inwar:%d",warid))
		end
	end
end

function CMD.sethpmp(srvname,request)
end

function CMD.catchpet(srvname,request)
	local warid = assert(request.warid)
	local pid = assert(request.pid)
	local itemid = assert(request.itemid)
	local pettype = assert(request.pettype)
	local bianyi_type = assert(request.bianyi_type)
	local player = playermgr.getplayer(pid)
	if player then
		player.petdb:catchpet(player,pettype,bianyi_type,itemid)
	end
end


function netcluster_war.dispatch(source,cmd,...)
	assert(type(source) == "string","Invalid source:" .. tostring(source))
	local func = assert(CMD[cmd],"Unknow cmd:" .. tostring(cmd))
	return func(source,...)
end

return netcluster_war
