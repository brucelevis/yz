
gm = require "gamelogic.gm.init"

--- 指令: test
--- 用法: test test_filename json_str
function gm.test(args)
	local isok,args = checkargs(args,"string","string")
	if not isok then
		net.msg.S2C.notify(master_pid,"用法: test test_filename json_str")
		return
	end
	local test_filename = args[1]
	local func = require ("gamelogic.test." .. test_filename)
	local tbl = cjson.decode(args[2])
	print(format("test %s %s",test_filename,tbl))
	func(table.unpack(tbl))
	print(string.format("test %s ok",test_filename))
end
return gm
