netlifeskill = netlifeskill or {
	C2S = {},
	S2C = {},
}

local C2S = netlifeskill.C2S
local S2C = netlifeskill.S2C

function C2S.study(player,request)
end

-- 遗忘生活技能
function C2S.forget(player,request)
end

function C2S.upgrade(player,request)
end

function C2S.produceitem(player,request)
	local itemid = assert(request.itemid)
end

-- s2c

return netlifeskill
