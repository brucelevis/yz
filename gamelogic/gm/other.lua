
gm = require "gamelogic.gm.init"

function gm.echo(args)
	local isok,args = checkargs(args,"string")
	if not isok then
		gm.notify("用法: echo msg")
		return
	end
	local msg = table.unpack(args)
	--print("length:",#msg,msg)
	gm.notify(msg)
end

return gm
