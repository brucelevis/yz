require "gamelogic.award.init"

ctemplate = class("ctemplate")

function ctemplate:init(conf)
	self.name = assert(conf.name)
	self.templateid = assert(conf.templateid)
	self.type = assert(conf.type)
	self.formdata = assert(conf.formdata)
	self.script_handle = {
		talk	= "npctalk",
		npc		= "insertnpc",
		war		= "raisewar",
		reward	= "doreward",
	}
end

function ctemplate:loadres(playunit,data)
	if playunit.resourcemgr then
		return
	end
	local resmgr = object.cresourcemgr.new(self,playunit)
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

function ctemplate:doscript(playunit,script,pid,...)
	local sc = script.sc
	local arg = script.arg
	local npc = self:getcurrentnpc(playunit)
	local funcname = self.script_handle[sc]
	local func = self[funcname]
	if func ~= nil and type(func) == "function" then
		return func(self,playunit,arg,pid,npc,...)
	end
	return self:customexec(playunit,sc,arg,pid,npc,...)
end

function ctemplate:getnpc(playunit,npcid)
	local npcobj = playunit.resourcemgr.npclist[npcid]
	if not npcobj then
		--npcobj = npc.globalnpc(npcid)
	end
	return npcobj
end

function ctemplate:getnpc_bynid(playunit,nid)
	for _,npcobj in pairs(playunit.resourcemgr.npclist) do
		if npcobj.nid == nid then
			return npcobj
		end
	end
	return --npc.globalnpc_bynid(nid)
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
	local newscene = instance_scene()
	newscene:config({
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
		scid,x,y = self:transcode(scid)
	end
	if x == 0 and y == 0 then
	--	x,y = self:randompos(scid)
	end
	local newnpc = self:instance_npc()
	newnpc:config({
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
	local newwar = self:instance_war()
	newwar:config({
		warid = warid,
	})
	return newwar
end


--<<  overrides  >>
function ctemplate:instance_npc()
	return object.cnpc.new(self.templateid)
end

function ctemplate:instance_scene()
	return object.cscene.new(self.templateid)
end

function ctemplate:instance_war()
	return object.cwar.new(self.templateid)
end

function ctemplate:customexec(playunit,sc,arg,pid,npc)
	self:log("err","err",string.format("unsc,script=%s pid=%d",sc,pid))
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
	local fakedata = self.formdata.fadkeinfo[fakeid]
	if not fakedata then
		return
	end
	return fakedata[faketype]
end

function ctemplate:onwarend(warid,result)
end


--<<  script func  >>
function ctemplate:npctalk(playunit,arg,pid,npc)
	local textid = arg
	local text = self.formdata.textinfo[textid]
	text = self:transtext(text,pid,npc)
	if npc then
		npc:say(pid,text)
	end
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
		warid = self:getfakedata(-warid,"war")
	end
	local newwar = self:createwar(playunit,warid,pid)
	newwar:start(self.onwarend)
	return newwar
end

function ctemplate:doreward(playunit,arg,pid,npc)
	local rewardid = arg
	local reward = nil
	if rewardid < 0 then
		reward = self:getfakedata(-rewardid,"reward")
	else
		reward = self.formdata.rewardinfo[rewardid]
	end
	reward = deepcopy(reward)
	for res,value in pairs(reward) do
		value = self:transcode(value,pid,npc)
		reward[res] = value
	end
	self:log("info","award",string.format("tplaward,pid=%d,rid=%d",pid,rewardid))
	--doaward("player",pid,reward,string.format("%s.template",self.name))
end

function ctemplate:release(playunit)
	if not playunit.resourcemgr then
		return
	end
	playunit.resourcemgr:release()
end

function ctemplate:log(levelmode,filename,...)
	local msg = table.concat({...},"\t")
	msg = string.format("[%s_%d] %s",self.name,self.templateid,msg)
	logger.log(levelmode,filename,msg)
end

return ctemplate
