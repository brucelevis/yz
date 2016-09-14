
gm = require "gamelogic.gm.init"

--- 指令: playerset
--- 用法: playerset 属性名 属性值 [玩家ID]
--- 举例: playerset gold 10 <=> 不指定玩家ID，将自身金币设置成10
--- 举例: playerset gold 10 1000001 <=> 将1000001玩家金币设置成10
function gm.playerset(args)
	local isok,args = checkargs(args,"string","string","*")
	if not isok then
		net.msg.S2C.notify(master_pid,"用法: playerset 属性名 属性值 [玩家ID]")
		return
	end
	local key = args[1]
	local chunk = loadstring("return " .. args[2])
	local pid = tonumber(args[3]) or master_pid
	local val = chunk()
	local player = playermgr.getplayer(pid)
	if not player then
		net.msg.S2C.notify(master_pid,string.format("玩家(%s)不在线",pid))
		return
	end
	local oldval = table.getattr(player,key)
	if type(oldval) == "function" then
		net.msg.S2C.notify(master_pid,"非法属性")
		return
	end
	if key == "lv" then
		local addval = val - player.lv
		player:addlv(addval,"gm")
	elseif key == "gold" then
		local addval = val - player.gold
		player:addgold(addval,"gm")
	elseif key == "silver" then
		local addval = val - player.silver
		player:addsilver(addval,"gm")
	elseif key == "coin" then
		local addval = val - player.coin
		player:addcoin(addval,"gm")
	else
		table.setattr(player,key,val)
		net.msg.S2C.notify(master_pid,string.format("重新登录生效"))
	end
end

--- 指令: addqualitypoint
--- 用法: addqualitypoint 增加的素质点 [玩家ID]
--- 举例: addqualitypoint 10 <=> 不指定玩家ID，将自身素质点增加10
--- 举例: addqualitypoint 10 1000001 <=> 将1000001玩家素质点增加10点
function gm.addqualitypoint(args)
	local isok,args = checkargs(args,"int","*")
	if not isok then
		net.msg.S2C.notify(master_pid,"用法: addqualitypoint 增加的素质点 [玩家ID]")
		return
	end
	local val = args[1]
	local pid = tonumber(args[2]) or master_pid
	local player = playermgr.getplayer(pid)
	if not player then
		net.msg.S2C.notify(master_pid,string.format("玩家(%s)不在线",pid))
		return
	end
	player:add_qualitypoint(val,"gm")
end

--- 指令: resetqualitypoint
--- 用法: resetqualitypoint [玩家ID]
--- 举例: resetqualitypoint <=> 不指定玩家ID，将自身素质点重置
--- 举例: resetqualitypoint 1000001 <=> 将1000001玩家素质点重置
function gm.resetqualitypoint(args)
	local isok,args = checkargs(args,"*")
	if not isok then
		net.msg.S2C.notify(master_pid,"用法: resetqualitypoint [玩家ID]")
		return
	end
	local pid = tonumber(args[1]) or master_pid
	local player = playermgr.getplayer(pid)
	if not player then
		net.msg.S2C.notify(master_pid,string.format("玩家(%s)不在线",pid))
		return
	end
	player:reset_qualitypoint()
end

--- 指令: addexp
--- 用法: addexp 经验值 [玩家ID]
--- 举例: addexp 100 <=> 不指定玩家ID，将自身经验值增加100点
--- 举例: addexp 100 1000001 <=> 将1000001玩家经验值增加100点
function gm.addexp(args)
	local isok,args = checkargs(args,"int","*")
	if not isok then
		net.msg.S2C.notify(master_pid,"用法: addexp 经验值 [玩家ID]")
		return
	end
	local val = args[1]
	local pid = tonumber(args[2]) or master_pid
	local player = playermgr.getplayer(pid)
	if not player then
		net.msg.S2C.notify(master_pid,string.format("玩家(%s)不在线",pid))
		return
	end
	player:addexp(val,"gm")
end

--- 指令: addjobexp
--- 用法: addjobexp 经验值 [玩家ID]
--- 举例: addjobexp 100 <=> 不指定玩家ID，将自身职业经验值增加100点
--- 举例: addjobexp 100 1000001 <=> 将1000001玩家职业经验值增加100点
function gm.addjobexp(args)
	local isok,args = checkargs(args,"int","*")
	if not isok then
		net.msg.S2C.notify(master_pid,"用法: addjobexp 经验值 [玩家ID]")
		return
	end
	local val = args[1]
	local pid = tonumber(args[2]) or master_pid
	local player = playermgr.getplayer(pid)
	if not player then
		net.msg.S2C.notify(master_pid,string.format("玩家(%s)不在线",pid))
		return
	end
	player:addjobexp(val,"gm")
end

--- 指令: newplayerday
--- 用法: newplayerday 玩家刷天，重置相关数据，不指定玩家ID，将自己刷天
function gm.newplayerday(args)
	local pid = tonumber(args[1]) or master_pid
	local player = playermgr.getplayer(pid)
	if not player then
		net.msg.S2C.notify(master_pid,string.format("玩家(%s)不在线",pid))
		return
	end
	player.today.dayno = 1
	player:onfivehourupdate()
end

--- 用法: clear 容器类别
--- 举例: clear item		<=> 清空背包
function gm.clear(args)
	local isok,args = checkargs(args,"string")
	if not isok then
		net.msg.S2C.notify(master_pid,"用法: clear 容器类别")
		return
	end
	local typ = args[1]
	local container = master[typ]
	if not container.clear then
		net.msg.S2C.notify(master_pid,string.format("容器(%s)不存在",typ))
		return
	end
	container:clear()
end


--- 指令: 禁言
--- 用法: banspeak acct|ip|role 帐号|IP|角色ID 禁言多长时间 原因
--- 举例: banspeak acct lgl@sina.com 3600 脏话	<=> 帐号禁言1个小时
--- 举例: banspeak ip 192.168.1.20 3600 脏话	<=> IP禁言1个小时
--- 举例: banspeak role 100001 0 解除禁言		<=> 角色ID禁言(0表示解除禁言)
--- 举例: banspeak role 100001 -1 太污			<=> 角色ID禁言(-1表示永久禁言)
function gm.banspeak(args)
	local isok,args = checkargs(args,"string","string","int","string")
	if not isok then
		net.msg.S2C.notify(master_pid,"用法: banspeak acct|ip|role 帐号|IP|角色ID 禁言多长时间 原因")
		return
	end
	local what = args[1]
	local who = args[2]
	local howlong = args[3]
	local reason = args[4]
	local exceedtime
	if howlong > 0 then
		exceedtime = os.date("%Y/%m/%d %H:%M:%S",os.time()+howlong)
	end
	local detail = {
		exceedtime = exceedtime,
		reason = reason,
	}
	if what == "acct" then
		speak_acct_blacklist[who] = detail
	elseif what == "ip" then
		speak_ip_blacklist[who] = detail
	elseif what == "role" then
		-- 角色禁言存到玩家身上
		local roleid = tonumber(who)
		local player = playermgr.getplayer(roleid)
		if not player then
			player = playermgr.loadofflineplayer(roleid)
		end
		player:set("banspeak",detail)
	end
	if what ~= "role" then
		gm.say(string.format("帐号/IP禁言需要修改'白名单_黑名单.xls',下次启服后才会仍然生效"))
	end
end

--- 指令: 禁止登录
--- 用法: banlogin all|player|none|role 角色ID 禁止登录时间 原因
--- 举例: banlogin all									<=> 禁止所有玩家登录(包括白名单)
--- 举例: banlogin player								<=> 禁止普通玩家登录（白名单不受限)
--- 举例: banlogin none									<=> 解除禁止登录(对外开放服务器)
--- 举例: banlogin ip 100001 3600 非法交易				<=> 角色ID禁止登录1个小时
--- 举例: banlogin ip 100001 0 解除禁止登录				<=> 角色ID禁止登录(0表示解除禁止登录)
--- 举例: banlogin ip 100001 -1 利用游戏bug				<=> 角色ID禁止登录(-1表示永久禁止登录)
function gm.banlogin(args)
	local isok,args = checkargs(args,"string","*")
	if not isok then
		gm.say("用法: banlogin all|player|none|role 角色ID 禁止登录时间 原因")
		return
	end
	local what = args[1]
	local who = args[2]
	local howlong = args[3]
	local reason = args[4]
	if what == "all" or what == "player" or what == "none" then
		globalmgr.ban.alllogin = nil
		globalmgr.ban.playerlogin = nil
		if what == "all" then
			globalmgr.ban.alllogin = true
		elseif what == "player" then
			globalmgr.ban.playerlogin = true
		end
		return
	end
	howlong = tonumber(howlong)
	who = tostring(who)
	local exceedtime
	if howlong > 0 then
		exceedtime = os.date("%Y/%m/%d %H:%M:%S",os.time()+howlong)
	end
	local detail = {
		exceedtime = exceedtime,
		reason = reason,
	}
	
	if what == "role" then
		login_roleid_blacklist[who] = detail
	end
	gm.say(string.format("禁止登录需要修改'白名单_黑名单.xls',下次启服后才会仍然生效"))
end

function gm.changejob(args)
	local isok,args = checkargs(args,"int")
	if not isok then
		net.msg.S2C.notify(master.pid,"用法: changejob 职业id")
		return
	end
	local jobid = args[1]
	local jobdata = data_0101_Hero[jobid]
	if not jobdata then
		net.msg.S2C.notify(master.pid,"职业id不正确")
		return
	end
	local player = master
	player.roletype = jobid
	player.warskilldb:resetpoint()
	player.warskilldb:clear()
	player.warskilldb:openskills(jobid)
	while istrue(jobdata.ZSPRE) do
		jobid = jobdata.ZSPRE
		player.warskilldb:openskills(jobid)
		jobdata = data_0101_Hero[jobid]
	end
	net.msg.S2C.notify(player.pid,"重新登录后，显示新职业技能")
	sendpackage(player.pid,"player","update",{roletype = player.roletype})
end

function gm.setliveness(args)
	local isok,args = checkargs(args,"int")
	if not isok then
		net.msg.S2C.notify(master.pid,"用法: setliveness 100 <-->设置活跃度为100")
		return
	end
	local liveness = args[1]
	local navigatedata = navigation.getnavigation(master)
	navigatedata.liveness = liveness
	net.navigation.S2C.sendactivitydata(master,navigatedata)
end

return gm
