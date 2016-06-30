require "gamelogic.base.init"

cscene = class("cscene")

function cscene:init(param)
	self.sceneid = assert(param.sceneid)
	self.mapid = assert(param.mapid)
	self.npcs = {}
	self.items = {}
	self.scenesrv = skynet.newservice("gamelogic/service/scened")
	skynet.send(self.scenesrv,"lua","init",param)
end

function cscene:enter(player)
	if player.teamstate == TEAM_STATE_CAPTAIN then
		local team = teammgr:getteam(player.teamid)
		if team then
			for uid,_ in pairs(team.follow) do
				local member = playermgr.getplayer(uid)
				if member then
					skynet.send(self.scenesrv,"lua","scene","enter",member:packscene())
				end
			end
		end
	end
	skynet.send(self.scenesrv,"lua","enter",player:packscene())
end

function cscene:leave(player)
	if player.teamstate == TEAM_STATE_CAPTAIN then
		local team = teammgr:getteam(player.teamid)
		if team then
			for uid,_ in pairs(team.follow) do
				skynet.send(self.scenesrv,"lua","scene","leave",uid)
			end
		end
	end
	skynet.send(self.scenesrv,"lua","leave",player.pid)
end

function cscene:move(player,package)
	if player.teamstate == TEAM_STATE_CAPTAIN then
		local team = teammgr:getteam(player.teamid)
		if team then
			for uid,_ in pairs(team.follow) do
				skynet.send(self.scenesrv,"lua","scene","move",uid,package)
			end
		end
	end
	skynet.send(self.scenesrv,"lua","move",player.pid,package)
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

-- test cmd
function cscene:dump()
	skynet.send(self.scenesrv,"lua","dump")
end

return cscene
