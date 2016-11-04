gm = require "gamelogic.gm.init"
require "gamelogic.oscmd.maintain"

--- 指令: maintain
--- 功能: 指定时间后服务器进入维护状态
--- 用法: maintain shutdown_after
function gm.maintain(args)
	local isok,args = checkargs(args,"int")	
	if not isok then
		return "用法: maintain shutdown_after"
	end
	local lefttime = table.unpack(args)
	lefttime = math.max(0,math.min(lefttime,300))
	maintain.force_maintain(lefttime)
end

--- 指令: shutdown
--- 功能: 安全停服
--- 用法: shutdown
function gm.shutdown(args)
	local reason = args[1] or "gm"
	game.shutdown(reason)
end

function gm.saveall(args)
	game.saveall()
end

--- 指令: kick
--- 功能: 将某玩家踢下线
--- 用法: kick 玩家ID [玩家ID]
function gm.kick(args)
	local isok,args = checkargs(args,"int","*")	
	if not isok then
		return "用法: kick pid1 pid2 ..."
	end
	for i,v in ipairs(args) do
		local pid = tonumber(v)
		playermgr.kick(pid,"gm")
	end
end

--- 指令: kickall
function gm.kickall(args)
	playermgr.kickall("gm")
end

--- 指令: runcmd
--- 用法: runcmd lua脚本 [是否返回结果]
function gm.runcmd(args)
	local cmdline = args[1]
	local noresult = args[2]
	if not noresult then
		cmdline = "return " .. cmdline
	end
	local func = load(cmdline,"=(load)","bt")
	return func()
end

--- 指令: offline
--- 功能: 离线载入某个玩家，并让其执行某个指令
--- 用法: offline 玩家ID 指令 参数
function gm.offline(args)
	local isok,args = checkargs(args,"int","*")
	if not isok then
		return "用法: offline 玩家ID 指令 参数"
	end
	local pid = table.remove(args,1)
	local player = playermgr.loadofflineplayer(pid)
	if not player then
		return "Unknow pid:" .. tostring(pid)
	end
	local cmdline = table.concat(args," ")
	return gm.docmd(pid,cmdline)
end

function gm.clearplayerdb(args)
	local isok,args = checkargs(args,"int","string")
	if not isok then
		return "用法: clearplayerdb 玩家ID 存盘块名"
	end
	local pid = args[1]
	local player = playermgr.getplayer(pid)
	if player then
		playermgr.kick(pid,"gmclear")
	end
	local savekey = args[2]
	local db = dbmgr.getdb(pid)
	local key = db:key("role",pid,savekey)
	local data = db:get(key)
	if not data then
		return format("db中没有该数据%s",key)
	end
	logger.log("info","gm",format("[cleardb] pid=%d save=%s",pid,savekey))
	db:set(key,{})
end

--- 指令: hotfix
--- 功能: 热更新某模块
--- 用法: hotfix 模块名 ...
function gm.hotfix(args)
	for i,modname in ipairs(args) do
		hotfix.hotfix(modname)
	end
end

--- 指令: countonline
--- 功能: 获取在线玩家数
function gm.countonline(args)
	local onlinenum,num = 0,0
	for pid,obj in pairs(playermgr.id_obj) do
		num = num + 1
		if obj.__state == "online" then
			onlinenum = onlinenum + 1
		end
	end
	return string.format("onlinenum:%s/%s,num:%s/%s",onlinenum,playermgr.onlinenum,num,playermgr.num)
end

--- 用法: closetuoguan [是否关闭全服托管]
--- 功能: 关闭托管
--- 举例: closetuoguan <=> 关闭自身的托管
--- 举例: closetuoguan 1 <=> 关闭全服的托管
function gm.closetuoguan(args)
	local isok,args = checkargs(args,"*")
	if not isok then
		gm.notify("用法: closetuoguan [是否关闭全服托管]")
		return
	end
	local closeall = args[1]
	if closeall then
		globalmgr.server.closetuoguan = true
		gm.notify("全服已关闭托管")
	else
		master.closetuoguan = true
		gm.notify("自身已关闭托管")
	end
end

--- 用法: opentuoguan [是否打开全服托管]
--- 功能: 打开托管
--- 举例: opentuoguan <=> 打开自身的托管
--- 举例: opentuoguan 1 <=> 打开全服的托管
function gm.opentuoguan(args)
	local isok,args = checkargs(args,"*")
	if not isok then
		gm.notify("用法: opentuoguan [是否关闭全服托管]")
		return
	end
	local openall = args[1]
	if openall then
		globalmgr.server.closetuoguan = nil
		gm.notify("全服已打开托管")
	else
		master.closetuoguan = nil
		gm.notify("自身已打开托管")
	end
end

--- 用法: daobiao
--- 功能: 执行导表，更新服务器导表数据
function gm.daobiao(args)
	if not cserver.isinnersrv() then
		gm.notify("仅开发服支持导表指令")
		return
	end
	local warsrv = skynet.getenv("warsrv")
	-- 忽略导表报错,导表报错将错误信息记录到文件中，开发服老是报:IOError
	local cmds = {
		{"逻辑服","cd ../logicshell/ && sh exportxls.sh",},
		{"战斗服",string.format("cd ../../%s/logicshell/ && sh exportxls.sh",warsrv),}
	}
	for i,list in ipairs(cmds) do
		local srvname = list[1]
		local cmd = list[2]
		gm.say(string.format("%s开始导表...",srvname))
		os.execute(cmd)
	end
	gm.say("导表执行完毕")
	gm.notify("导表执行完毕")
end

function gm.update(args)
	if not cserver.isinnersrv() then
		return
	end
	local isok,args = checkargs(args,"string")
	local subpath = args[1]
	local path
	if string.find(subpath,"^gamelogic%.") or string.find(subpath,"^proto%.") then
		path = subpath
	else
		path = string.format("gamelogic.%s",args[1])
	end
	hotfix.hotfix(path)
end

gm.reload = gm.update

return gm
