cscene = class("cscene")

function cscene:init(param)
	self.sceneid = assert(param.sceneid)
	self.mapid = assert(param.mapid)
	self.mapname = assert(param.mapname)
	self.width = assert(param.width)
	self.height = assert(param.height)
	self.block_width = assert(param.block_width)
	self.block_height = assert(param.block_height)

	self.npcs = {}
	self.items = {}
	self.scenesrv = skynet.newservice("gamelogic/service/scened")
	skynet.send(self.scenesrv,"lua","init",param)
	self.channel = string.format("scene#%s",self.sceneid)
	channel.add(self.channel)
end

function cscene:enter(player,pos)
	if player:teamstate() == TEAM_STATE_CAPTAIN then
		local team = player:getteam()
		if team then
			for uid,_ in pairs(team.follow) do
				local member = playermgr.getplayer(uid)
				if member then
					skynet.send(self.scenesrv,"lua","enter",member:packscene(self.sceneid,pos))
					xpcall(self.onenter,onerror,self,member,pos)
				end
			end
		end
	end
	skynet.send(self.scenesrv,"lua","enter",player:packscene(self.sceneid,pos))
	xpcall(self.onenter,onerror,self,player,pos)
end

function cscene:leave(player)
	if player:teamstate() == TEAM_STATE_CAPTAIN then
		local team = player:getteam()
		if team then
			for uid,_ in pairs(team.follow) do
				local member = playermgr.getplayer(uid)
				if member then
					skynet.send(self.scenesrv,"lua","leave",uid)
					xpcall(self.onleave,onerror,self,member)
				end
			end
		end
	end
	skynet.send(self.scenesrv,"lua","leave",player.pid)
	xpcall(self.onleave,onerror,self,player)
end

function cscene:move(player,package)
	if player:teamstate() == TEAM_STATE_CAPTAIN then
		local team = player:getteam()
		if team then
			for uid,_ in pairs(team.follow) do
				local member = playermgr.getplayer(uid)
				if member then
					skynet.send(self.scenesrv,"lua","move",uid,package)
					member:setpos(self.sceneid,package.dstpos)
				end
			end
		end
	end
	skynet.send(self.scenesrv,"lua","move",player.pid,package)
	player:setpos(self.sceneid,package.dstpos)
end

function cscene:reload(pid)
	skynet.send(self.scenesrv,"lua","reload",pid)
end

function cscene:set(pid,attrs,nosync)
	skynet.send(self.scenesrv,"lua","set",pid,attrs,nosync)
end

function cscene:query(pid,targetid)
	skynet.send(self.scenesrv,"lua","query",pid,targetid)
end

-- 退出服务
function cscene:exit()
	skynet.send(self.scenesrv,"lua","exit")
end

function cscene:allpids()
	return skynet.call(self.scenesrv,"lua","allpids")
end

function cscene:info()
	return skynet.call(self.scenesrv,"lua","info")
end

function cscene:broadcast(protoname,subprotoname,request)
	skynet.send(self.scenesrv,"lua","broadcast",{
		protoname = protoname,
		subprotoname = subprotoname,
		request = request,
	})
end

function cscene:isvalidpos(pos)
	if (0 <= pos.x and pos.x < self.width) and
		(0 <= pos.y and pos.y < self.height) then
		return true
	end
	return false
end

function cscene:fixpos(pos)
	local pos = deepcopy(pos)
	local x = pos.x
	local y = pos.y
	pos.x = math.max(0,math.min(x,self.width-1))
	pos.y = math.max(0,math.min(y,self.height-1))
	return pos
end

-- test cmd
function cscene:dump()
	skynet.send(self.scenesrv,"lua","dump")
end

-- 进入场景后处理流程
function cscene:onenter(player,pos)
	channel.subscribe(self.channel,player.pid)
	player:setpos(self.sceneid,pos)
	-- 进入/离开场景给主服控制，场景服压力过大时，可能导致进入/离开场景阻塞太久
	sendpackage(player.pid,"scene","enter",{
		pid = player.pid,
		sceneid = player.sceneid,
		pos = player.pos,
		mapid = self.mapid,
		mapname = self.mapname,
	})
	local npcs = {}
	for _,npc in pairs(self.npcs) do
		table.insert(npcs,self:packnpc(npc))
	end
	local items = {}
	for _,item in pairs(self.items) do
		table.insert(items,self:packitem(item))
	end
	sendpackage(player.pid,"scene","allnpc",{npcs = npcs})
	sendpackage(player.pid,"scene","allitem",{items = items})
	huodongmgr.onenterscene(player,self.sceneid,pos)
end

function cscene:onleave(player)
	channel.unsubscribe(self.channel,player.pid)
	sendpackage(player.pid,"scene","leave",{pid=player.pid})
	huodongmgr.onleavescene(player,self.sceneid)
end

function cscene:packnpc(npc)
	if npc.pack then
		return npc:pack()
	end
	local packnpc = {}
	for k,v in pairs(npc) do
		if type(v) ~= "function" then
			packnpc[k] = v
		end
	end
	return packnpc
end

function cscene:packitem(item)
	return item
end

return cscene
