
gm = require "gamelogic.gm.init"

function gm.echo(args)
	local isok,args = checkargs(args,"string")
	if not isok then
		net.msg.S2C.notify(master_pid,"用法: echo msg")
		return
	end
	local msg = table.unpack(args)
	--print("length:",#msg,msg)
	net.msg.S2C.notify(master_pid,msg)
end

return gm
