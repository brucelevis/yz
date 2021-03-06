
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
	local pids = playermgr.allplayer()
	netmsg.broadcast(pids,"msg","quickmsg",{msg=msg})
end

function netmsg.broadcast(pids,protoname,subprotoname,args)
	local msg = args.msg
	for i,pid in ipairs(pids) do
		local player = playermgr.getplayer(pid)
		if player then
			local translate_msg
			if type(msg) == "table" then  -- 打包的消息
				local lang = playeraux.getlanguage(pid)
				translate_msg = language.translateto(msg,lang)
			else
				translate_msg = msg
			end
			args.msg = translate_msg
			sendpackage(pid,protoname,subprotoname,args)
		end
	end
end

function netmsg.filter(msg,len)
	local isok,msg = wordfilter.filter(msg)
	if not isok then
		return false,language.format("未支持的消息格式")
	end
	local maxlen = len or data_GlobalVar.MaxMsgLen
	if string.utf8len(msg) > maxlen then
		return false,language.format("信息长度过长")
	end
	return true,msg
end

function C2S.worldmsg(player,request)
	local msg = assert(request.msg)
	local rawmsg = msg
	if string.sub(msg,1,1) == "$" then
		if player:isgm() then
			gm.say(msg,player.pid)
			net.player.C2S.gm(player,{
				cmd = string.sub(msg,2),
			})
			return
		end
	end
	local incd,exceedtime = player.thistemp:query("incd.world")
	if incd then
		local lefttime = exceedtime - os.time()
		net.msg.S2C.notify(player.pid,language.format("#<R>{1}#后才能发言",lefttime))
		return
	end
	-- check can send worldmsg
	local banspeak,detail = globalmgr.ban.speak({
		acct = player.account,
		ip = player:ip(),
		roleid = player.pid,
	})
	--print(player.account,player:ip(),player.pid)
	if banspeak then
		local errmsg
		if detail and detail.exceedtime and detail.exceedtime ~= "" then
			errmsg = language.format("你已被禁言,截止时间:{1}",detail.exceedtime)
		else
			errmsg = language.format("你已被禁言")
		end
		net.msg.S2C.notify(player.pid,msg)
		return
	end
	local isok,errmsg = netmsg.filter(msg)
	if not isok then
		net.msg.S2C.notify(player.pid,errmsg)
		return
	else
		msg = errmsg
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
	player.thistemp:set("incd.world",60)
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
	if request.id then
		sendpackage(player.pid,"msg","sendmsg_succ",{
			id = request.id,
		})
	end
	if len >= 3 then
		table.remove(player.privatemsg.worldmsgs,1)
	end
	table.insert(player.privatemsg.worldmsgs,rawmsg)
end

function C2S.scenemsg(player,request)
	local msg = assert(request.msg)
	-- check can send scenemsg
	local isok,errmsg = netmsg.filter(msg)
	if not isok then
		net.msg.S2C.notify(player.pid,errmsg)
		return
	else
		msg = errmsg
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
	if request.id then
		sendpackage(player.pid,"msg","sendmsg_succ",{
			id = request.id,
		})
	end
end

function C2S.teammsg(player,request)
	local msg = assert(request.msg)
	-- check can send teammsg
	local isok,errmsg = netmsg.filter(msg)
	if not isok then
		net.msg.S2C.notify(player.pid,errmsg)
		return
	else
		msg = errmsg
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
	if request.id then
		sendpackage(player.pid,"msg","sendmsg_succ",{
			id = request.id,
		})
	end
end

function C2S.unionmsg(player,request)
	local msg = assert(request.msg)
	local id = request.id
	-- check can send unionmsg
	local isok,errmsg = netmsg.filter(msg)
	if not isok then
		net.msg.S2C.notify(player.pid,errmsg)
		return
	else
		msg = errmsg
	end
	local sender = netmsg.packsender(player)
	if cserver.isunionsrv() then
		isok,errmsg = net.msg.C2S._unionmsg(sender,msg)
	else
		isok,errmsg = rpc.call(cserver.unionsrv(),"rpc","net.msg.C2S._unionmsg",sender,msg)
	end
	if not isok then
		if errmsg then
			net.msg.S2C.notify(player.pid,errmsg)
		end
	else
		if id then
			sendpackage(player.pid,"msg","sendmsg_succ",{
				id = id,
			})
		end
	end
end

function C2S._unionmsg(sender,msg)
	local pid = sender.pid
	local unionid = unionmgr:unionid(pid)
	if not unionid then
		return false,language.format("你没有公会")
	end
	local union = unionmgr:getunion(unionid)
	local member = union:member(pid)
	if member.banspeak then
		local date = dhms_time({min=true,sec=true},member.banspeak-os.time())
		return false,language.format("你已被公会管理者禁言，剩余禁言时间{1}分钟{2}秒",date.min,date.sec)
	end
	union:sendmsg(sender,msg)
	return true
end

function C2S.hornmsg(player,request)
	local msg = assert(request.msg)
	-- check can send hornmsg
	local len = data_GlobalVar.MaxHornMsgLen
	local isok,errmsg = netmsg.filter(msg,len)
	if not isok then
		net.msg.S2C.notify(player.pid,errmsg)
		return
	else
		msg = errmsg
	end
	local itemtype = 601003
	local itemdb = player:getitemdb(itemtype)
	local hasnum = itemdb:getnumbytype(itemtype)
	local usehornkey = string.format("usehorncnt")
	local costhornnum
	local usehornnum = player.today:query(usehornkey,0) + 1
	for key,val in pairs(data_GlobalVar.CostHornNum) do
		if usehornnum >= key then
			if not costhornnum or costhornnum < val then
				costhornnum = val
			end
		end
	end
	if hasnum < costhornnum then
		net.msg.S2C.notify(player.pid,language.format("{1}不足{2}个",itemaux.itemlink(itemtype),costhornnum))
		return
	end
	local cd = 3
	local now = os.time()
	local incd,exceedtime = player.thistemp:query("usehorntime")
	if incd then
		net.msg.S2C.notify(player.pid,language.format("道具{1}秒后完成冷却",exceedtime-now))
		return
	end
	local reason = "usehorn"
	itemdb:costitembytype(itemtype,costhornnum,reason)
	player.thistemp:set("usehorntime",now,cd)
	player.today:add(usehornkey,1)
	sendpackage(player.pid,"player","update",{
		usehorncnt = player.today:query(usehornkey) or 0,
	})
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
	if request.id then
		sendpackage(player.pid,"msg","sendmsg_succ",{
			id = request.id,
		})
	end
end

function C2S.sendmsgto(player,request)
	local msg = assert(request.msg)
	local isok,errmsg = netmsg.filter(msg)
	if not isok then
		net.msg.S2C.notify(player.pid,errmsg)
		return
	else
		msg = errmsg
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
	if request.id then
		sendpackage(player.pid,"msg","sendmsg_succ",{
			id = request.id,
		})
	end
end

function C2S.respondanswer(player,request)
	local pid = player.pid
	net.msg.C2S._respondanswer(player.pid,request)
end

function C2S._respondanswer(pid,request)
	local player = playermgr.getplayer(pid)
	if not player then
		return
	end
	local id = assert(request.id)
	local forward = request.forward
	if id == 0 then
		return
	end
	local answer = request.answer or -1 -- -1 -- close window
	local srvname = globalmgr.srvname(id)
	if srvname ~= cserver.getsrvname() then
		if forward then
			rpc.pcall(srvname,"rpc","net.msg.C2S._respondanswer",pid,request)
		else
			local kuafu_onlogin = pack_function("net.msg.C2S._respondanswer",pid,request)
			playermgr.gosrv(player,srvname,kuafu_onlogin)
		end
		return
	end
	local session = reqresp.sessions[id]
	if session then
		reqresp.resp(pid,id,{ answer = answer })
	end
end

-- s2c
function S2C.notify(pid,msg)
	local player
	if type(pid) == "table" then
		player = pid
	else
		player = playermgr.getplayer(pid)
		if not player then
			local resume = resumemgr.getresume(pid)
			local now_srvname = resume:get("now_srvname")
			if now_srvname ~= cserver.getsrvname() then
				rpc.call(now_srvname,"rpc","net.msg.S2C.notify",pid,msg)
			end
			return
		end
	end
	if type(msg) == "table" then  -- 打包的消息
		local lang = playeraux.getlanguage(player.pid)
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
		local lang = playeraux.getlanguage(player.pid)
		msg = language.translateto(msg,lang)
	end
	sendpackage(pid,"msg","info",{msg=msg,})
end



function S2C.bulletin(msg,func)
	local sender = {
		pid = 0,
	}
	local packmsg = {
		sender = sender,
		msg = msg,
	}
	channel.publish("world",{
		p = "msg",
		s = "notify",
		a = packmsg,
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
		local lang = playeraux.getlanguage(player.pid)
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
