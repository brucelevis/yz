
gm = require "gamelogic.gm.init"

function gm.echo(args)
	local isok,args = checkargs(args,"string")
	if not isok then
		net.msg.S2C.notify(master_pid,"usage: echo msg")
		return
	end
	local msg = table.unpack(args)
	--print("length:",#msg,msg)
	net.msg.S2C.notify(master_pid,msg)
end

--- 指令: dumpproto
--- 用法: dumpproto
function gm.dumpproto(args)
	local proto = require "proto.init"
	local c2s = proto.getc2s()
	local s2c = proto.gets2c()
	local filename = "../logicshell/protoc2s.txt"
	local fd = io.open(filename,"wb")
	fd:write(filename,c2s)
	io.close(fd)
	local filename = "../logicshell/protos2c.txt"
	local fd = io.open(filename,"wb")
	fd:write(filename,s2c)
	io.close(fd)
end

return gm
