
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
	if string.utf8len(msg) > MAX_MSG_LEN then
		return false,language.format("信息长度过长")
	end
	return true,msg
end

function C2S.onmessagebox(player,request)
	local id = request.buttonid
	if id == 0 then
		return
	end
	return reqresp.resp(player.pid,id,{id=id})
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

function C2S.onnpcsay(player,request)
	local respondid = assert(request.respondid)
	local answer = assert(request.answer)
	player:do_respondhandler(respondid,answer)
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

--[[
function onbuysomething(pid,request,response)
	local player = playermgr.getplayer(pid)
	local buttonid = response.buttonid
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
netmsg.S2C.messagebox(10001,{
				type = MB_LACK_CONDITION,
				title = "条件不足",
				content = "是否花费100金币购买:",
				buttons = {
					"确认",
					"取消",
				},
				attach = {
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
				},onbuysomething)
--]]


function S2C.messagebox(pid,request,callback)
	local player = playermgr.getplayer(pid)
	if not player then
		return
	end
	local lang = player:getlanguage()
	local pack_request = {}
	pack_request.type = assert(request.type)
	pack_request.title = assert(language.translateto(request.title))
	pack_request.content = assert(language.translateto(request.content))
	pack_request.attach = cjson.encode(request.attach)
	pack_request.buttons = {}
	local lang = player:getlanguage()
	for i,button_str in ipairs(request.buttons) do
		pack_request.buttons[i] = language.translateto(button_str,lang)
	end
	local id = reqresp.req(pid,request,callback)
	pack_request.id = id
	sendpackage(pid,"msg","messagebox",pack_request)
	return id
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
				table.insert(options2,language.translateto(option,lang))
			end
		end
		options = options2
	end
	local respondid
	if callback and type(callback) == "function" then
		respondid = player:set_respondhandler(callback,...)
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
