local proto = require "proto.init"

function dumpproto(c2s_filename,s2c_filename)
	c2s_filename = c2s_filename or "/tmp/protoc2s.txt"
	s2c_filename = s2c_filename or "/tmp/protos2c.txt"
	local c2s = proto.getc2s()
	local s2c = proto.gets2c()
	local fd = io.open(c2s_filename,"wb")
	fd:write(c2s)
	io.close(fd)
	local fd = io.open(s2c_filename,"wb")
	fd:write(s2c)
	io.close(fd)
end

dumpproto(...)
