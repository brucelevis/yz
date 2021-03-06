nettest = nettest or {
	C2S = {},
	S2C = {},
}

local C2S = nettest.C2S
local S2C = nettest.S2C

function C2S.echo(player,request)
	pprintf("%s",request)
	nettest.S2C.echo(player,request)
end

-- s2c
function S2C.echo(pid,request)
	sendpackage(pid,"test","echo",request)
end

return nettest
