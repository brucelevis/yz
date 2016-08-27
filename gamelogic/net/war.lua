netwar = netwar or {
	C2S = {},
	S2C = {},
}

local C2S = netwar.C2S
local S2C = netwar.S2C

function C2S.invite_qiecuo(player,request)
	local targetid = assert(request.targetid)
	local target = playermgr.getplayer(targetid)
	if not target then
		net.msg.S2C.notify(player.pid,language.format("目标已下线"))
		return
	end
	net.msg.S2C.messagebox(targetid,
		MB_INVITE_QIECUO,
		language.format("决斗邀请"),
		language.format("【{1}】想你发起了决斗邀请，是否接受?",language.untranslate(player.name)),
		{language.format("确认"),language.format("取消"),},
		netwar.on_invite_qiecuo)
end

function netwar.on_invite_qiecuo(pid,request,response)
	local answer = response.answer
	local player = playermgr.getplayer(pid)
	if answer == 0 then 		-- 超时回调
	elseif answer == 1 then 		-- 确认
	else
		assert(answer == 2) 	-- 取消
	end
end

-- s2c

return netwar
