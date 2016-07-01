require "gamelogic.base.class"

ctemplate = class("template")

function ctemplate:init(conf)
	self.name = assert(conf.name)
	self.templateid = assert(conf.templateid)
	self.type = assert(conf.type)
	self.formdata = assert(conf.formdata)
	self.script_handle = {
		talk	= self.npctalk,
		npc		= self.insertnpc,
		war		= self.raisewar,
		reward	= self.doreward,
	}
end

function ctemplate:loadres(playunit,data)
	if playunit.resourcemgr then
		return
	end
	local resmgr = object.cresourcemgr.new(self)
	if data ~= nil and data.resource ~= nil then
		resmgr.load(data.resource)
	end
	playunit.resourcemgr = resmgr
end

function ctemplate:saveres(playunit,data)
	if not playunit.resourcemgr then
		return data
	end
	data.resource = playunit.resourcemgr:save()
	return data
end

function ctemplate:execscript(playunit,scriptlist,pid,npc)
	local resmgr = assert(playunit.resourcemgr)
	for _,script in ipairs(scriptlist) do
		for sc,arg in pairs(script) do
			local func = self.script_handle[sc]
			if func ~= nil then
				func(resmgr,arg,pid,npc)
			else
				local result = self:customexec(resmgr,sc,arg,pid,npc)
				if not result then
					logger.log("err","unknow script:".. sc .."template:".. self.templateid)
				end
			end
		end
	end
end

function ctemplate:getnpc(resmgr,nid)
	for _,npc in pairs(resmgr.npclist) do
		if npc.nid == nid then
			return npc
		end
	end
end

function ctemplate:createscene(resmgr,scid)
	local sceneinfo = self.formdata.sceneinfo[scid]
	local mapid,name = sceneinfo.map,sceneinfo.name
	local newscene = object.cscene.new({
		mapid = mapid,
		name = name,
		scid = scid,
	})
	resmgr:addscene(newscene)
	return newscene
end

function ctemplate:createnpc(resmgr,nid)
	local npcinfo = self.formdata.npcinfo[nid]
	local shape = self:transcode(npcinfo.shape)
	local name = self:transcode(npcinfo.name)
	local scid,x,y = npcinfo.location.scene,npcinfo.location.x,npcinfo.location.y
	if type(scid) == "string" then
		scid,x,y = self.transcode(scid)
	end
	if x == 0 and y == 0 then
		x,y = self:randompos(scid)
	end
	local newnpc = object.cnpc.new({
		shape = shape,
		name = name,
		nid = nid,
		clientnpc = isclient,
	})
	newnpc:setlocation(scid,x,y)
	resmgr:addnpc(newnpc)
	return newnpc
end

function ctemplate:createwar(resmgr,warid,pid)
	local newwar = object.cwar.new(warid)
	return newwar
end

function ctemplate:onwarend(war,pid,iswin)
	local resmgr = war.playunit.resourcemgr
	if iswin then
		self:onwarwin(resmgr,pid)
	else
		self:onwarfail(resmgr,pid)
	end
end


--<<  overrides  >>
function ctemplate:customexec(resmgr,sc,arg,pid,npc)
	return false
end

function ctemplate:transtext(text,pid,npc)
	return text
end

function ctemplate:transcode(value,pid,npc)
	if type(value) ~= "string" then
		return value
	end
	return value
end

function ctemplate:getfakedata(fakeid,faketype)
end

function ctemplate:onwarwin(resmgr,pid)
end

function ctemplate:onwarfail(resmgr,pid)
end


--<<  script func  >>
function ctemplate:npctalk(resmgr,arg,pid,npc)
	local textid = arg
	local text = self.formdata.textinfo[textid]
	text = self:transtext(text,pid,npc)
	npc:say(pid,text)
end

function ctemplate:insertnpc(resmgr,arg,pid,npc)
	local nid = arg
	local newnpc = self:createnpc(resmgr,nid)
	if not newnpc:isclientnpc() then
		newnpc:enterscene()
	end
end

function ctemplate:raisewar(resmgr,arg,pid,npc)
	local warid = tonumber(arg)
	if warid < 0 then
		warid = self:getfakedata(warid,"warid")
	end
	local newwar = self:createwar(resmgr,warid,pid)
	newwar:start(self.onwarend)
end

function ctemplate:doreward(resmgr,arg,pid)
end

function ctemplate:release(playunit)
	if not playunit.resourcemgr then
		return
	end
	playunit.resourcemgr:release()
end

return ctemplate
