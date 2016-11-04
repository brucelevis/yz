--/*
-- 跨服流程:主要包括去跨服(去其他服),回原服
-- 假定存在玩家C，他在HS服，有其他GS1，GS2服
-- C从HS服到GS1服:
--	1. HS生成认证token，发到GS1
--	2. HS打包"连接指定服务器"({token=token,go_srvname=GS1,home_srvname=HS})给C
--	3. HS将C踢下线
--	4. C收到"连接指定服务器"时，开始连接GS1,并透传收到的信息(包括认证token)
--	5. GS1根据token认证，认证通过后允许C进入游戏
--	6. GS1通知HS，C跨服成功，HS将C标记成正在跨服GS1
--	7. C走进入游戏流程
--
--	C从GS1服回到原服HS
--	1. GS1生成认证token，发到HS
--	2. GS1打包"连接指定服务器"({token=token,go_srvname=HS})给C
--	3. GS1将C踢下线,并通知HS删除C的跨服标记
--	4. C收到"连接指定服务器"时，开始连接HS,并透传收到的信息(包括认证token)
--	5. HS根据token认证,认证通过后允许C进入游戏
--	6. C走进入游戏流程
--
--	C从GS1到GS2
--  1. GS1生成认证token，发到GS2
--	2. GS1打包"连接指定服务器"({token=token,go_srvname=GS2,home_srvname=HS})给C
--	3. GS1将C踢下线
--	4. C收到"连接指定服务器"时，开始连接GS2,并透传收到的信息(包括认证token)
--	5. GS2根据token认证，认证通过由允许C进入游戏
--	6. GS2通知HS，C跨服成功,HS将C的跨服标记置成GS2
--	7. C走进入游戏流程
--	
--	C从GS2下线流程
--	1. GS2将C下线
--	2. HS心跳检查C在GS2是否在线，如果不在线，则删除C的跨服标记
--*/

--/*
-- 跨服放到玩家身上数据有
-- home_srvname #原服名
-- player_data    #原服传来的信息[如原服服务器等级等]
--
-- 跨服标记中记录的数据有
-- go_srvname	#去往的跨服
--*/

playermgr = require "gamelogic.playermgr"
playermgr.kuafuplayers = playermgr.kuafuplayers or {}
playermgr.gokuafunum = playermgr.gokuafunum or 0

function playermgr.gosrv(player,go_srvname,home_srvname)
	-- player是连线对象，不一定是玩家对象
	local pid = player.pid
	local now_srvname = cserver.getsrvname()
	if not home_srvname then
		if player.home_srvname then
			home_srvname = player.home_srvname
		else
			home_srvname = now_srvname
		end
	end
	assert(go_srvname ~= home_srvname)
	local token = uuid()
	logger.log("info","kuafu",string.format("[gosrv] pid=%d home_srvname=%s srvname=%s->%s token=%s",pid,home_srvname,now_srvname,go_srvname,token))
	local player_data = playermgr.packplayer4kuafu(pid)
	rpc.call(go_srvname,"rpc","playermgr.addtoken",token,{
		pid=pid,
		home_srvname=home_srvname,
		player_data = player_data,
	})
	if player.ongosrv then
		player:ongosrv(go_srvname)
	end
	net.login.S2C.reentergame(player,{
		go_srvname = go_srvname,
		token = token,
	})
	playermgr.kick(pid)
end

function playermgr.gohome(player)
	local pid = player.pid
	local home_srvname = assert(player.home_srvname)
	local now_srvname = cserver.getsrvname()
	assert(home_srvname ~= now_srvname)
	local token = uuid()
	logger.log("info","kuafu",string.format("[gohome] pid=%d,srvname=%s->%s token=%s",pid,now_srvname,home_srvname,token))
	rpc.call(home_srvname,"rpc","playermgr.addtoken",token,{pid=pid,})
	if player.ongohome then
		player:ongohome(home_srvname)
	end
	net.login.S2C.reentergame(player,{
		go_srvname = home_srvname,
		token = token,
	})
	playermgr.kick(pid)
	rpc.call(home_srvname,"rpc","playermgr.delkuafuplayer",pid)
end


-- 原服只记录跨服标记
-- kuafuplayer: {go_srvname=去往的服务器,}
function playermgr.addkuafuplayer(kuafuplayer)
	local pid = kuafuplayer.pid
	if not playermgr.getkuafuplayer(pid) then
		playermgr.gokuafunum = playermgr.gokuafunum + 1
	end
	kuafuplayer.gotime = kuafuplayer.gotime or os.time()
	kuafuplayer.home_srvname = kuafuplayer.home_srvname or cserver.getsrvname()
	playermgr.kuafuplayers[pid] = kuafuplayer
	playermgr.keep_heartbeat(pid)
	return kuafuplayer
end

function playermgr.delkuafuplayer(pid)
	local kuafuplayer = playermgr.getkuafuplayer(pid)
	if kuafuplayer then
		playermgr.kuafuplayers[pid] = nil
		playermgr.gokuafunum = playermgr.gokuafunum - 1
		return kuafuplayer
	end
end

function playermgr.getkuafuplayer(pid)
	return playermgr.kuafuplayers[pid]
end

function playermgr.keep_heartbeat(pid)
	local kuafuplayer = playermgr.getkuafuplayer(pid)
	if kuafuplayer then
		local isonline = rpc.call(kuafuplayer.go_srvname,"rpc","playermgr.checkonline",pid)
		if not isonline then
			kuafuplayer.diecnt = (kuafuplayer.diecnt or 0) + 1
		else
			kuafuplayer.diecnt = 0
		end
		if kuafuplayer.diecnt > 3 then
			playermgr.delkuafuplayer(pid)
		else
			timer.timeout("kuafu.keep_heartbeat",60,functor(playermgr.keep_heartbeat,pid))
		end
	end
end

-- 打包与玩家相关的本服全局数据，如服务器等级，开服天数等
function playermgr.packplayer4kuafu(pid)
	local data = {}
	return data
end

return playermgr
