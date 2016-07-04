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

function ctemplate:execscript(playunit,scriptlist,pid,...)
	local result = nil	--单次脚本执行结果，如果返回非nil表示失败，停止后续执行
	for _,script in ipairs(scriptlist) do
		for sc,arg in pairs(script) do
			local func = self.script_handle[sc]
			if func ~= nil then
				local npc = self:getcurrentnpc(playunit)
				result = func(playunit,arg,pid,npc,...)
			else
				result = self:customexec(playunit,sc,arg,pid,npc,...)
			end
			if result ~= nil then
				return result
			end
		end
	end
end

function ctemplate:getnpc(playunit,nid)
	for _,npcobj in pairs(playunit.resourcemgr.npclist) do
		if npcobj.nid == nid then
			return npcobj
		end
	end
	return npc.globalnpc(nid)
end

function ctemplate:setcurrentnpc(playunit,npcid)
	playunit.resourcemgr.curnpc = npcid
end

function ctemplate:getcurrentnpc(playunit)
	return self:getnpc(playunit,playunit.resourcemgr.curnpc)
end

function ctemplate:createscene(playunit,scid)
	local sceneinfo = self.formdata.sceneinfo[scid]
	local mapid,name = sceneinfo.map,sceneinfo.name
	local newscene = object.cscene.new({
		mapid = mapid,
		name = name,
		scid = scid,
	})
	playunit.resourcemgr:addscene(newscene)
	return newscene
end

function ctemplate:createnpc(playunit,nid)
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
	playunit.resourcemgr:addnpc(newnpc)
	return newnpc
end

function ctemplate:createwar(playunit,warid,pid)
	local newwar = object.cwar.new(warid)
	return newwar
end


--<<  overrides  >>
function ctemplate:customexec(playunit,sc,arg,pid,npc)
	logger.log("err","template",string.format("unknow script=%s template=%d",sc,self.templateid))
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

function ctemplate:onwarend(warid,result)
end


--<<  script func  >>
function ctemplate:npctalk(playunit,arg,pid,npc)
	local textid = arg
	local text = self.formdata.textinfo[textid]
	text = self:transtext(text,pid,npc)
	npc:say(pid,text)
end

function ctemplate:insertnpc(playunit,arg,pid,npc)
	local nid = arg
	local newnpc = self:createnpc(playunit,nid)
	if not newnpc:isclientnpc() then
		newnpc:enterscene()
	end
end

function ctemplate:raisewar(playunit,arg,pid,npc)
	local warid = tonumber(arg)
	if warid < 0 then
		warid = self:getfakedata(warid,"warid")
	end
	local newwar = self:createwar(playunit,warid,pid)
	newwar:start(self.onwarend)
end

function ctemplate:doreward(playunit,arg,pid)
end

function ctemplate:release(playunit)
	if not playunit.resourcemgr then
		return
	end
	playunit.resourcemgr:release()
end

return ctemplate
