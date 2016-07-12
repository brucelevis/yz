nettitle = nettitle or {
	C2S = {},
	S2C = {},
}

local C2S = nettitle.C2S
local S2C = nettitle.S2C

function C2S.set_curtitle(player,request)
	local id = assert(request.id)
	player.titledb:set_curtitle(id)
end

function C2S.unset_curtitle(player,request)
	player.titledb:unset_curtitle()
end

-- s2c

return nettitle
