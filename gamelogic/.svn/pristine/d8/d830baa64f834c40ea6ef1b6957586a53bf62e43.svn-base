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


-- s2c
function S2C.notify(pid,msg)
	local player
	if type(pid) == "table" then
		player = pid
	else
		player = playermgr.getplayer(pid)
	end
	local lang
	-- player 可能只是个连线对象
	if typename(player) == "cplayer" then
		lang = player:query("lang") or language.language_to
	else
		lang = language_from
	end
	msg = language.translateto(msg,lang)
	sendpackage(pid,"msg","notify",{msg=msg,})
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
	for i,pid in ipairs(playermgr.allplayer()) do
		local player = playermgr.getplayer(pid)
		if player then
			if not func or func(player) then
				netmsg.S2C.notify(pid,msg)
			end
		end
	end
end

return netmsg
