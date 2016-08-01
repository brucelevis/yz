netguaji = netguaji or {
	C2S = {},
	S2C = {},
}

local C2S = netguaji.C2S
local S2C = netguaji.S2C

function C2S.guaji(player,request)
	huodongmgr.playunit.guaji.guaji(player)
end

function C2S.unguaji(player,request)
	huodongmgr.playunit.guaji.unguaji(player)
end

-- s2c

return netguaji
