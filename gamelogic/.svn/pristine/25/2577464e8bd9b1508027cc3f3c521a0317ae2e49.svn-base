netwarsvrfw = netwarsvrfw or {
	C2S = setmetatable({},{__index=function (t,k)
		t[k] = function (player,request)
			local pack = {
				pid = player.pid,
				cmd = k,
				request = request,
			}
			sendtowarsrv("war","forward",pack)
		end
		return t[k]
	end}),
	S2C = {},
}

local C2S = netwarsvrfw.C2S
local S2C = netwarsvrfw.S2C

return netwarsvrfw
