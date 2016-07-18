function starttimer_check_messagebox()
	timer.timeout("timer.check_messagebox",5,starttimer_check_messagebox)	
	local now = os.time()
	for id,session in pairs(messagebox.sessions) do
		if session.exceedtime and session.exceedtime <= now then
			messagebox.sessions[id] = nil
			local callback = session.callback
			if callback then
				callback(nil,session.request,0)
			end
		end
	end
end


if not messagebox then
	messagebox = {
		id = 0,
		sessions = {},
	}
	starttimer_check_messagebox()
end

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
	channel.publish("world",{
		p = "msg",
		s = "quickmsg",
		a = {
			msg = msg,
		}
	})
end

function netmsg.filter(msg)
	local isok,msg = wordfilter.filter(msg)
	if not isok then
		return false,language.format("未支持的消息格式")
	end
	if wordfilter.utf8len(msg) > MAX_MSG_LEN then
		return false,language.format("信息长度过长")
	end
	return true,msg
end

function C2S.onmessagebox(player,request)
	local id = request.id
	if id == 0 then
		return
	end
	local session = messagebox.sessions[id]
	if not session then
		return
	end
	messagebox.sessions[id] = nil
	local callback = session.callback
	if callback then
		callback(player,session.request,request.buttonid)
	end
end

function C2S.worldmsg(player,request)
	local msg = assert(request.msg)
	local rawmsg = msg
	-- check can send worldmsg
	local isok,msg = netmsg.filter(msg)
	if not isok then
		net.msg.S2C.notify(player.pid,msg)
		return
	end
	-- 检查重复发言
	local len = #player.privatemsg.worldmsgs
	if len > 0 then
		local lastmsg = player.privatemsg.worldmsgs[len]
		local similar = wordfilter.get_similar(lastmsg,rawmsg)
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
	local teamid = player:getteamid()
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

function C2S.hornmsg(player,request)
	local msg = assert(request.msg)
	-- check can send hornmsg
	local isok,msg = netmsg.filter(msg)
	if not isok then
		net.msg.S2C.notify(player.pid,msg)
		return
	end
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
			lang = player:query("lang") or language.language_to
		else
			lang = language_from
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
			lang = player:query("lang") or language.language_to
		else
			lang = language_from
		end
		msg = language.translateto(msg,lang)
	end
	sendpackage(pid,"msg","info",{msg=msg,})
end

--[[
function onbuysomething(player,request,buttonid)
	if buttonid == 0 then -- 超时回调
		-- player is nil
		local pid = request.pid
		-- dosomething
	else
		if buttonid == 1 then
			if not costok() then
				return
			end
			addres()
		end
	end
end
netmsg.S2C.messagebox(10001,
				LACK_CONDITION,
				"条件不足",
				"是否花费100金币购买:",
				{
					silver = 1000,
					items = {
						{
							itemid = 14101,
							num = 3,
						},
						{
							itemid = 14201,
							num = 2,
						},
					},
					ext = {
						gold = 100,
					}
				},
				{
					"确认",
					"取消",
				},
				onbuysomething)
--]]


function S2C.messagebox(pid,type,title,content,attach,buttons,callback,lifetime)
	local id
	local request = {
		pid = pid,
		type = type,
		title = title,
		content = content,
		attach = cjson.encode(attach),
		buttons = buttons,
	}

	if callback then
		if messagebox.id > MAX_NUMBER then
			messagebox.id = 0
		end
		messagebox.id = messagebox.id + 1
		messagebox.sessions[messagebox.id] = {
			request = request,
			callback = callback,
			exceedtime = os.time() + (lifetime and lifetime or 300),
		}
		id = messagebox.id
	else
		id = 0
	end
	request.id = id
	sendpackage(pid,"msg","messagebox",request)
	request.attach = attach
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

function S2C.npcsay(pid,npc,msg)
	if type(msg) == "table" then  -- 打包的消息
		local lang
		local player = playermgr.getplayer(pid)
		if player and typename(player) == "cplayer" then
			lang = player:query("lang") or language.language_to
		else
			lang = language_from
		end
		msg = language.translateto(msg,lang)
	end
	sendpackage(pid,"msg","npcsay",{
		name = npc.name,
		type = npc.type,
		msg = msg,
	})
end

return netmsg
