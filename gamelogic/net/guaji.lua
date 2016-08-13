netguaji = netguaji or {
	C2S = {},
	S2C = {},
}

local C2S = netguaji.C2S
local S2C = netguaji.S2C

function C2S.guaji(player,request)
	local isok,errmsg = huodongmgr.playunit.guaji.guaji(player)
	if not isok then
		net.msg.S2C.notify(player.pid,errmsg)
		return
	end
end

function C2S.unguaji(player,request)
	local isok,errmsg = huodongmgr.playunit.guaji.unguaji(player)
	if not isok then
		net.msg.S2C.notify(player.pid,errmsg)
		return
	end
end

-- s2c

return netguaji
