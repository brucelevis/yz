
gm = require "gamelogic.gm.init"

--- 指令: test
--- 用法: test test_filename json_str
function gm.test(args)
	local isok,args = checkargs(args,"string","string")
	if not isok then
		gm.notify("用法: test test_filename json_str")
		return
	end
	local test_filename = args[1]
	local func = require ("gamelogic.test." .. test_filename)
	local tbl = cjson.decode(args[2])
	print(format("test %s %s",test_filename,tbl))
	func(table.unpack(tbl))
	print(string.format("test %s ok",test_filename))
end

function gm.testfunc(args)
	local pid = tonumber(args[1]) or master_pid
	print(pid)
	local function tfunc1()
		print("before tfunc1",pid)
		local resume = resumemgr.getresume(pid)
		print("after tfunc1",pid,resume)
	end
	local function tfunc2()
		print("before tfunc2",pid)
		local resume = resumemgr.getresume(pid)
		print("after tfunc2",pid,resume)
	end
	local function tfunc3()
		print("before tfunc3",pid)
		local resume = resumemgr.getresume(pid)
		print("after tfunc3",pid,resume)
		resumemgr.delresume(pid)
		print("after delresume",pid)
	end
	local function tfunc4()
		print("before tfunc4",pid)
		local resume = resumemgr.getresume(pid)
		print("after tfunc4",pid,resume)
	end


	skynet.fork(tfunc1)
	skynet.fork(tfunc2)
	skynet.fork(tfunc3)
	skynet.fork(tfunc4)
end

return gm
