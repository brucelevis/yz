
netmsg = netmsg or {
	C2S = {},
	S2C = {},
}
local C2S = netmsg.C2S
local S2C = netmsg.S2C

function netmsg.packsender(player)
	return {
		pid = player.pid,
		name = player.name,
		lv = player.lv,
		roletype = player.roletype,
	}
end

-- 快讯
function netmsg.sendquickmsg(msg)
	-- 快讯内容:服务端决定，可能需要翻译，不便于用频道
	--channel.publish("world",{
	--	p = "msg",
	--	s = "quickmsg",
	--	a = {
	--		msg = msg,
	--	}
	--})
	
	for i,pid in pairs(playermgr.allplayer()) do
		local player = playermgr.getplayer(pid)
		if type(msg) == "table" then  -- 打包的消息
			local lang
			-- player 可能只是个连线对象
			if typename(player) == "cplayer" then
				lang = player:getlanguage()
			else
				lang = language.language_from
			end
			translate_msg = language.translateto(msg,lang)
		else
			translate_msg = msg
		end
		sendpackage(pid,"msg","notify",{msg=translate_msg})
	end
end

function netmsg.filter(msg)
	local isok,msg = wordfilter.filter(msg)
	if not isok then
		return false,language.format("未支持的消息格式")
	end
	if string.utf8len(msg) > MAX_MSG_LEN then
		return false,language.format("信息长度过长")
	end
	return true,msg
end

function C2S.worldmsg(player,request)
	local msg = assert(request.msg)
	local rawmsg = msg
	if string.sub(msg,1,1) == "$" then
		if player:isgm() then
			net.player.C2S.gm(player,request)
			return
		end
	end
	-- check can send worldmsg
	local banspeak,detail = globalmgr.ban.speak({
		acct = player.account,
		ip = player:ip(),
		roleid = player.pid,
	})
	--print(player.account,player:ip(),player.pid)
	if banspeak then
		if detail and detail.exceedtime and detail.exceedtime ~= "" then
			msg = language.format("你已被禁言,截止时间:{1}",detail.exceedtime)
		else
			msg = language.format("你已被禁言")
		end
		net.msg.S2C.notify(player.pid,msg)
		return
	end
	local isok,msg = netmsg.filter(msg)
	if not isok then
		net.msg.S2C.notify(player.pid,msg)
		return
	end
	-- 检查重复发言
	local len = #player.privatemsg.worldmsgs
	if len > 0 then
		local lastmsg = player.privatemsg.worldmsgs[len]
		local similar = string.get_similar(lastmsg,rawmsg)
		if similar >= 0.9 then
			net.msg.S2C.notify(player.pid,language.format("不能重复发送多条一样的消息"))
			return
		end
	end
	local sender = netmsg.packsender(player)
	local packmsg = {
		sender = sender,
		msg = msg,
	}
	channel.publish("world",{
		p = "msg",
		s = "worldmsg",
		a = packmsg,
	})
	if len >= 3 then
		table.remove(player.privatemsg.worldmsgs,1)
	end
	table.insert(player.privatemsg.worldmsgs,rawmsg)
end

function C2S.scenemsg(player,request)
	local msg = assert(request.msg)
	-- check can send scenemsg
	local isok,msg = netmsg.filter(msg)
	if not isok then
		net.msg.S2C.notify(player.pid,msg)
		return
	end
	local sceneid = player.sceneid
	local scene = scenemgr.getscene(sceneid)
	if not scene then
		return
	end
	local sender = netmsg.packsender(player)
	local packmsg = {
		sender = sender,
		msg = msg,
	}

	channel.publish(scene.channel,{
		p = "msg",
		s = "scenemsg",
		a = packmsg,
	})
end

function C2S.teammsg(player,request)
	local msg = assert(request.msg)
	-- check can send teammsg
	local isok,msg = netmsg.filter(msg)
	if not isok then
		net.msg.S2C.notify(player.pid,msg)
		return
	end
	local teamid = player:teamid()
	local team = teammgr:getteam(teamid)
	if not team then
		return
	end
	local sender = netmsg.packsender(player)
	local packmsg = {
		sender = sender,
		msg = msg,
	}
	channel.publish(team.channel,{
		p = "msg",
		s = "teammsg",
		a = packmsg,
	})

end

function C2S.orgmsg(player,request)
	local msg = assert(request.msg)
	-- check can send orgmsg
	local isok,msg = netmsg.filter(msg)
	if not isok then
		net.msg.S2C.notify(player.pid,msg)
		return
	end

end

local COST_HORNNUM = {
	[0] = 1,
	[21] = 2,
	[31] = 3,
	[41] = 4,
	[51] = 5,
}

function C2S.hornmsg(player,request)
	local msg = assert(request.msg)
	-- check can send hornmsg
	local isok,msg = netmsg.filter(msg)
	if not isok then
		net.msg.S2C.notify(player.pid,msg)
		return
	end
	local itemdb = player:getitemdb(501001)
	local hasnum = itemdb:getnumbytype(501001)
	local usehornkey = string.format("itemusecnt.%s",501001)
	local costhornnum
	local usehornnum = player.today:query(usehornkey,0)
	for key,val in pairs(COST_HORNNUM) do
		if usehornnum >= key then
			if not costhornnum or costhornnum < val then
				costhornnum = val
			end
		end
	end
	if hasnum < costhornnum then
		net.msg.S2C.notify(player.pid,language.format("{1}不足{2}个",itemaux.itemlink(501001),costhornnum))
		return
	end
	local now = os.time()
	local usehorntime = player.thistemp:query("usehorntime")
	if usehorntime then
		net.msg.S2C.notify(player.pid,language.format("道具{1}秒后完成冷却",3 - (now - usehorntime)))
		return
	end
	local reason = "usehorn"
	itemdb:costitembytype(501001,costhornnum,reason)
	player.thistemp:set("usehorntime",now,3)
	player.today:add(usehornkey,1)
	local sender = netmsg.packsender(player)
	local packmsg = {
		sender = sender,
		msg = msg,
	}
	channel.publish("world",{
		p = "msg",
		s = "hornmsg",
		a = packmsg,
	})
end

function C2S.sendmsgto(player,request)
	local msg = assert(request.msg)
	local isok,msg = netmsg.filter(msg)
	if not isok then
		net.msg.S2C.notify(player.pid,msg)
		return
	end
	local targetid = assert(request.targetid)
	local target = playermgr.getplayer(targetid)
	if not target then
		target = playermgr.loadofflineplayer(targetid)
	end
	if not target then
		return
	end
	local sender = netmsg.packsender(player)
	local packmsg = {
		sender = sender,
		sendtime = os.time(),
		msg = msg,
	}
	target.privatemsg:add(packmsg)
	sendpackage(targetid,"msg","privatemsg",packmsg)
end

function C2S.respondanswer(player,request)
	local id = assert(request.id)
	local answer = request.answer or -1		-- -1: 客户端关闭了窗口
	local session = reqresp.sessions[id]
	if session and session.pid == player.pid then
		local fromsrv = session.request.fromsrv
		if fromsrv and fromsrv ~= cserver.getsrvname() then
			-- forward to fromsrv
			playermgr.gosrv(player,fromsrv,nil,pack_function(reqresp.resp,player.pid,id,{answer = answer}))
		else
			reqresp.resp(player.pid,id,{ answer = answer })
		end
	end
end

-- s2c
function S2C.notify(pid,msg)
	local player
	if type(pid) == "table" then
		player = pid
	else
		player = playermgr.getplayer(pid)
	end
	if type(msg) == "table" then  -- 打包的消息
		local lang
		-- player 可能只是个连线对象
		if typename(player) == "cplayer" then
			lang = player:getlanguage()
		else
			lang = language.language_from
		end
		msg = language.translateto(msg,lang)
	end
	sendpackage(pid,"msg","notify",{msg=msg,})
end

-- 个人信息
function S2C.info(pid,msg)
	local player
	if type(pid) == "table" then
		player = pid
	else
		player = playermgr.getplayer(pid)
	end
	if type(msg) == "table" then  -- 打包的消息
		local lang
		-- player 可能只是个连线对象
		if typename(player) == "cplayer" then
			lang = player:getlanguage()
		else
			lang = language.language_from
		end
		msg = language.translateto(msg,lang)
	end
	sendpackage(pid,"msg","info",{msg=msg,})
end



function S2C.bulletin(msg,func)
	channel.publish("world",{
		p = "msg",
		s = "notify",
		a = {
			msg = msg,
		}
	})
	--for i,pid in ipairs(playermgr.allplayer()) do
	--	local player = playermgr.getplayer(pid)
	--	if player then
	--		if not func or func(player) then
	--			netmsg.S2C.notify(pid,msg)
	--		end
	--	end
	--end
end

-- 可以带选项的npc对话,无回调时options,callback传nil
function S2C.npcsay(pid,npc,msg,options,callback,...)
	local player = playermgr.getplayer(pid)
	if not player then
		return
	end
	if type(msg) == "table" then  -- 打包的消息
		local lang = player:getlanguage()
		msg = language.translateto(msg,lang)
		local options2
		if options then
			for _,option in ipairs(options) do 
				if not options2 then
					options2 = {}
				end
				if type(option) == "table" then
					option = language.translateto(option,lang)
				end
				table.insert(options2,option)
			end
		end
		options = options2
	end
	local respondid
	if callback and type(callback) == "function" then
		local request = table.pack(...)
		respondid = reqresp.req(pid,request,callback)
	end
	sendpackage(pid,"msg","npcsay",{
		name = npc.name,
		shape = npc.shape,
		msg = msg,
		options = options,
		respondid = respondid,
	})
end

return netmsg
