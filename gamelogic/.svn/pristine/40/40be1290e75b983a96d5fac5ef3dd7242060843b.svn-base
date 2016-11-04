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
			func(self,playunit,args,pid,...)
		end
	else	
		self:customexec(playunit,script,pid,...)
	end
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
	local newnpc = {
		nid = nid,
		shape = npcdata.shape,
		name = npcdata.name,
		posid = tostring(npcdata.posid),
		isclient = npcdata.isclient,
		purpose = nil,
	}
	newnpc = self:transnpc(playunit,newnpc,pid)
	playunit.resourcemgr:addnpc(newnpc)
	return newnpc
end

function ctemplate:doaward(playunit,awardid,pid)
	local bonus = self:transaward(playunit,awardid,pid)
	doaward("player",pid,bonus,format("template.%s awardid=%d",self.name,awardid),true)
end

function ctemplate:isnearby(player,npc,dis)
	if dis == "ignore" or player.testman == 1 then
		return true
	end
	if not player or not npc then
		return false
	end
	dis = dis or MAX_NEAR_DISTANCE
	local pos2,mapid
	if npc.pos then
		mapid = npc.mapid
		pos2 = npc.pos
	else
		local m,x,y = scenemgr.getpos(npc.posid)
		mapid = m
		pos2 = {x = x, y = y}
	end
	local scene = scenemgr.getscene(player.sceneid)
	if scene.mapid ~= mapid or getdistance(player.pos,pos2) > dis then
		local distance = getdistance(player.pos,pos2)
		self:log("debug","task",format("[nonearby] pid=%d npcmap=%d playermap=%d dis=%d pos=%s pos2=%s",player.pid,mapid,scene.mapid,distance,player.pos,pos2))
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

function ctemplate:formdata_values(data,attr)
	local values = {}
	if type(data[attr]) == "table" then
		if data.rand then
			local v = randlist(data[attr])
			table.insert(values,v)
		elseif data.both then
			values = data[attr]
		end
	else
		table.insert(values,data[attr])
	end
	return values
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
	local war = {
		wardataid = warid,
		-- playunit无wartype时必须重写该函数
		wartype = playunit.wartype or WARTYPE.PVE_TEST,
		attack_helpers = {},
		defense_helpers = {},
		pid = pid,
	}
	local player = playermgr.getplayer(pid)
	war.attackers = player:getfighters()
	assert(not table.isempty(war.attackers))
	war.defensers = {}		-- 默认PVE，涉及PVP重写该接口
	return war
end

function ctemplate:transaward(playunit,awardid,pid)
	local awarddata = self:getformdata("award")
	local bonus = deepcopy(award.getaward(awarddata,awardid))
	local tmplist = {"exp","jobexp","gold","silver","coin"}
	for _,perbonus in ipairs(bonus) do
		for k,v in pairs(perbonus) do
			if type(v) == "string" and table.find(tmplist,k) then
				local v2 = tonumber(v)
				if v2 then
					bonus[k] = v2
				else
					bonus[k] = self:calformula(v)
				end
			end
		end
		self:revisebonus(playunit,perbonus)
	end
	return bonus
end

function ctemplate:revisebonus(playunit,bonus)
end

function ctemplate:calformula(formulastr)
	return formulastr
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
	self:log("error","err",format("[unknow script] script=%s pid=%d",script,pid))
end

function ctemplate:onwarend(warid,result)
end


--<<  脚本方法  >>
function ctemplate:talkto(playunit,args,pid)
	local nid = args.nid
	local textid = args.textid
	local text = self:getformdata("text")[textid]
	local npc = self:getnpc_bynid(playunit,nid)
	text = self:transtext(playunit,text,pid)
	net.msg.S2C.npcsay(pid,npc,text)
end

function ctemplate:addnpc(playunit,args,pid)
	local nids = self:formdata_values(args,"nid")
	for _,nid in ipairs(nids) do
		local npc = self:createnpc(playunit,nid,pid)
		if not npc.isclient then
			playunit.resourcemgr:enterscene(npc)
		end
	end
end

function ctemplate:delnpc(playunit,args,pid)
	local nid = args.nid
	local npc = self:getnpc_bynid(playunit,nid)
	if npc then
		playunit.resourcemgr:delnpc(npc)
	end
end

function ctemplate:raisewar(playunit,args,pid)
	local warid = assert(args.warid)
	local war = self:transwar(playunit,warid,pid)
	warmgr.startwar(war.attackers,war.defensers,war)
end

return ctemplate

