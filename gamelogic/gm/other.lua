
gm = require "gamelogic.gm.init"

--- cmd: echo
--- usage: echo msg
function gm.echo(args)
	local isok,args = checkargs(args,"string")
	if not isok then
		net.msg.S2C.notify(master_pid,"usage: echo msg")
		return
	end
	local msg = table.unpack(args)
	print("length:",#msg,msg)
	net.msg.S2C.notify(master_pid,msg)
end

return gm
