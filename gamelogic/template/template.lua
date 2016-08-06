require "gamelogic.award.init"

ctemplate = class("ctemplate")

function ctemplate:init(conf)
	self.name = assert(conf.name)
	self.type = assert(conf.type)
	self.script_handle = {
		talkto = true,
		addnpc = true,
		delnpc = true,
		raisewar = true,
	}
end

function ctemplate:loadres(playunit,data)
	if not playunit.resourcemgr then
		local resmgr = cresourcemgr.new(self,playunit)
		playunit.resourcemgr = resmgr
	end
	playunit.resourcemgr:load(data)
end

function ctemplate:saveres(playunit)
	if not playunit.resourcemgr then
		return
	end
	return playunit.resourcemgr:save()
end

--[[
	@functions 执行脚本接口
	@param object playunit 数据独立的玩法单元，例如任务，活动等
	@param table script 策划脚本数据 { cmd = "", args = {} }
	@param integer pid 执行者
	@param ... 扩展参数
]]--
function ctemplate:doscript(playunit,script,pid,...)
	local cmd = script.cmd
	local args = script.args
	if self.script_handle[cmd] then
		local func = self[cmd]
		if func and type(func) == "function" then
			return func(self,playunit,args,pid,...)
		end
	end
	return self:customexec(playunit,script,pid,...)
end

function ctemplate:getnpc(playunit,npcid)
	local npc = playunit.resourcemgr.npclist[npcid]
	if not npc then
		npc = data_0601_NPC[npcid]
	end
	return npc
end

function ctemplate:getnpc_bynid(playunit,nid)
	for _,npc in pairs(playunit.resourcemgr.npclist) do
		if npc.nid == nid then
			return npc
		end
	end
	return data_0601_NPC[nid]
end

function ctemplate:createscene(playunit,mapid,name)
	local scene = playunit.resourcemgr:addscene({
		mapid = mapid,
		name = name,
	})
	scene = self.transscene(playunit,scene)
	return scene
end

function ctemplate:createnpc(playunit,nid,pid)
	local npcdata = self:getformdata("npc")[nid]
	local mapid,x,y = scenemgr.getpos(npcdata.posid)
	local newnpc = {
		nid = nid,
		shape = npcdata.shape,
		name = npcdata.name,
		posid = npcdata.posid,
		pos = { x = x, y = y},
		mapid = mapid,
		isclient = npcdata.isclient,
	}
	newnpc = self:transnpc(playunit,newnpc,pid)
	playunit.resourcemgr:addnpc(newnpc)
	return newnpc
end

function ctemplate:createwar(playunit,warid,pid)
	local war = {
		wardataid = warid,
		attack_helpers = {},
		defense_helpers = {},
	}
	local player = playermgr.getplayer(pid)
	war.attackers = player:getfighters()
	assert(not table.isempty(war.attackers))
	war.defensers = {}		-- 默认PVE，涉及PVP重新该接口
	return war
end

function ctemplate:doaward(playunit,awardid,pid)
	if awardid < 0 then
		awardid = self:transaward(playunit,awardid,pid)
	end
	local awarddata = self:getformdata("award")
	local bonuss = award.getaward(awarddata,awardid,function(i,data)
		return data.ratio
	end)
	doaward("player",pid,bonuss,format("template.%s awardid=%d",self.name,awardid))
end

function ctemplate:isnearby(player,npc,dis)
	if player.testman then
		return true
	end
	if not player or not npc then
		return false
	end
	dis = dis or MAX_NEAR_DISTANCE
	local pos2
	if npc.pos then
		pos2 = npc.pos
	else
		local _,x,y = scenemgr.getpos(npc.posid)
		pos2 = {x = x, y = y}
	end
	if dis ~= "ignore" and getdistance(player.pos,pos2) > dis then
		return false
	end
	return true
end

function ctemplate:release(playunit)
	if not playunit.resourcemgr then
		return
	end
	playunit.resourcemgr:release()
end

function ctemplate:log(levelmode,filename,...)
	local msg = table.concat({...},"\t")
	msg = string.format("[%s] %s",self.name,msg)
	logger.log(levelmode,filename,msg)
end


--<<  可重写方法  >>
function ctemplate:getformdata(formname)
end

function ctemplate:transnpc(playunit,npc,pid)
	return npc
end

function ctemplate:transscene(playunit,scene)
	return scene
end

function ctemplate:transwar(playunit,warid,pid)
	return warid
end

function ctemplate:transaward(playunit,awardid,pid)
	return awardid
end

function ctemplate:transtext(playunit,text,pid)
	return text
end

function ctemplate:transcode(playunit,value,pid)
	if type(value) ~= "string" then
		return value
	end
	local player = playermgr.getplayer(pid)
	if value == "playerlv" then
		return player.lv
	elseif value == "playername" then
		return player.name
	elseif value == "playerpos" then
		return player.sceneid,player.pos
	else
		return value
	end
end

function ctemplate:customexec(playunit,script,pid)
	local cmd = script.cmd
	local args = script.args
	self:log("err","err",format("[unknow script] script=%s pid=%d",script,pid))
end

function ctemplate:onwarend(warid,result)
end


--<<  脚本方法  >>
function ctemplate:talkto(playunit,args,pid)
	local nid = args.nid
	local textid = args.textid
	local text = self:getformdata("text")[textid]
	text = self:transtext(playunit,text,pid)
	net.msg.S2C.npcsay(pid,npc,text)
end

function ctemplate:addnpc(playunit,args,pid)
	local nid = args.nid
	local npc = self:createnpc(playunit,nid,pid)
	if not npc.isclient then
		playunit.resourcemgr:enterscene(npc)
	end
end

function ctemplate:delnpc(playunit,args)
	local nid = args.nid
	local npc = self:getnpc_bynid(playunit,nid)
	if npc then
		playunit.resourcemgr:delnpc(npc)
	end
end

function ctemplate:raisewar(playunit,args,pid)
	local warid = assert(args.warid)
	if warid < 0 then
		warid = self:transwar(playunit,warid,pid)
	end
	local war = self:createwar(playunit,warid,pid)
	warmgr.startwar(war.attackers,war.defensers,war)
end

return ctemplate

