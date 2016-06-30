-- version: 1.0.0
-- author: linguangliang
-- creation time: 2016-06-24
-- [[
-- 流程:
-- 1. 玩家进入游戏后，将其加入场景
-- 2. 玩家移动时定时通知服务器，服务器将其移动信息广播给可看见他的玩家
--    并将自身可见的新增玩家通知给自己
-- 3. 当场景切换时，会存在若干是否可以切换场景的判定条件，因此切场景必
--    需经过服务端判定，即由服务端控制“强制跳转”
-- 4. 完全下线后（非托管下线）将玩家从场景中移除
--
-- 上诉流程中会引入视野的概念，玩家的默认视野可以根据设备类型得知(服务端计算/客户端告知)
-- 为了简化通信，约定C2S/S2C涉及到的坐标均用像素坐标,
-- 
-- 根据上诉流程，大致有以下通信
-- 1. C2S
--    1.1 移动
--    1.2 跳场景（需要服务端允许跳转才能跳)
--    1.3 查询玩家场景信息(全量更新),主要为了防止转发给客户端的移动包，客户端没有该玩家的完整场景信息
--
-- 2. S2C
--	  1.1 转发移动(同步坐标)
--	  1.2 强制跳转，分两个动作：1. 离开场景；2. 进入场景指定位置
--	  1.3 移除(隐藏)玩家/新增(显示)玩家
--	  1.4 同步玩家场景信息(只更新变动属性)
-- ]]
package.path = package.path  .. ";../src/?.lua;../src/?.luo;../src/?/init.lua;../src/?/init.luo"
--print("package.path:",package.path)
--print("package.cpath:",package.cpath)
require "gamelogic.constant.init"
require "gamelogic.base.util.init"
require "gamelogic.logger.init"
local skynet = require "gamelogic.skynet"

local MAINSRV_NAME="SKYNETSERVICE"

local function sendpackage(agent,protoname,subprotoname,request)
	print(format("agent=%s protoname=%s subprotoname=%s request=%s",agent,protoname,subprotoname,request))
	skynet.send(agent,"lua","senddata",{
		p = protoname,
		s = subprotoname,
		a = request,
	})
end

local scene = {}

function scene.init(param)
	--[[
		key: pid
		value:{
			pid 玩家ID
			teamid	 队伍ID
			teamstate 队伍状态
			warid    战斗ID
			pos {
				x
				y
				dir
			}
			scene_strategy	同步策略(1--显示所有，2--只显示队长(包括暂离玩家和散人)，3--只显示自己队伍/自身)
			一些玩家简介属性，如:
			name
			lv
			roletype

			agent 
			row 所在块行号
			col 所在块列号
		}
	]]
	scene.players = {}
	scene.sceneid = assert(param.sceneid)
	scene.mapid = assert(param.mapid)
	scene.address = skynet.self()
	scene.initblocks(param)
	logger.log("info","scene",format("[init] address=%s param=%s",scene.address,param))
end

function scene.getplayer(pid)
	return scene.players[pid]
end

function scene.set(pid,attrs,nosync)
	local player = scene.getplayer(pid)
	if player then
		local bupdate = false
		for k,v in pairs(attrs) do
			if player[k] ~= v then
				player[k] = v
				bupdate = true
			end
		end
		if bupdate and not nosync then
			attrs.pid = pid
			scene.broadcast_around(player.row,player.col,function (uid)
				scene.sendpackage(uid,"scene","update",attrs)
			end)
		end
	end
end

-- 受限发包
function scene.sendpackage(uid,protoname,cmd,package)
	local pid = package.pid
	local obj = scene.getplayer(uid)
	local player = scene.getplayer(pid)
	if not obj or not player then
		return
	end
	if obj.agent then
		if obj.scene_strategy then
			if obj.scene_strategy == STRATEGY_SEE_SELF_TEAM then
				if obj.teamid and obj.teamid == player.teamid then
					sendpackage(obj.agent,protoname,cmd,package)
				end
			elseif obj.scene_strategy == STRATEGY_SEE_CAPTAIN then
				if player.teamstate == TEAM_STATE_CAPTAIN or
					player.teamstate == TEAM_STATE_LEAVE or
					not player.teamid then
					sendpackage(obj.agent,protoname,cmd,package)
				end
			elseif obj.scene_strategy == STRATEGY_SEE_ALL then
				sendpackage(obj.agent,protoname,cmd,package)
			end
		end
	end
end

function scene.move(pid,package)
	local player = scene.getplayer(pid)
	if not player then
		return
	end
	local srcpos = package.srcpos	
	local dstpos = package.dstpos
	player.pos = {
		x = srcpos.x,
		y = srcpos.y,
		dir = srcpos.dir,
	}
	local oldrow,oldcol = player.row,player.col
	local row,col = scene.getrowcol(player.pos.x,player.pos.y)
	if row ~= oldrow or col ~= oldcol then
		scene.changeblock(player,oldrow,oldcol,row,col)
	end
	-- 减少跟随队员移动的发包，客户端会无视跟随队员的移动包
	if player.teamstate == TEAM_STATE_FOLLOW then
		return
	end
	package.pid = pid
	scene.broadcast_around(row,col,function (uid)
		-- 转发移动包给所有可以看见自己的玩家
		scene.sendpackage(uid,"scene","move",package)
	end)
end

function scene.enter(player)
	local pid = player.pid
	if scene.getplayer(pid) then  -- 正常流程不会走到这来，除非上层同场景切换时没有先调用离开场景
		logger.log("warning","scene",format("[reenter] address=%s sceneid=%d mapid=%d pid=%d player=%s",scene.address,scene.sceneid,pid,scene.mapid,pid,player))
		scene.leave(pid)
	end
	logger.log("info","scene",format("[enter] address=%s sceneid=%d mapid=%d pid=%d player=%s",scene.address,scene.sceneid,scene.mapid,pid,player))
	player.sceneid = scene.sceneid
	player.mapid = scene.mapid
	local row,col = scene.getrowcol(player.pos.x,player.pos.y)
	scene.players[pid] = player
	sendpackage(player.agent,"scene","enter",player)
	scene.addtoblock(player,row,col,function (uid)
		if uid == player.pid then
			return
		end
		local obj = scene.getplayer(uid)
		-- 广播给其他可以看见自己的玩家
		scene.sendpackage(obj.pid,"scene","addplayer",player)
		-- 同步自己可以看见的玩家
		scene.sendpackage(player.pid,"scene","addplayer",obj)
	end)
end

function scene.leave(pid)
	local player = scene.getplayer(pid)
	if not player then
		return
	end
	logger.log("info","scene",string.format("[leave] address=%s sceneid=%d mapid=%d pid=%d",scene.address,scene.sceneid,scene.mapid,pid))
	scene.delfromblock(player,player.row,player.col,function (uid)
		if uid == player.pid then
			return
		end
		-- 广播给其他可以看见自己的玩家
		scene.sendpackage(uid,"scene","delplayer",player)
	end)
	sendpackage(player.agent,"scene","leave",player)
	-- 放到最后
	scene.players[pid] = nil
end

-- 重新载入场景，功能上等价于scene.leave+scene.enter
-- 当玩家选用的场景策略改变时需要reload场景
function scene.reload(pid)
	local player = scene.getplayer(pid)
	assert(player,pid)
	scene.leave(pid)
	scene.enter(player)
end

function scene.query(pid,targetid)
	local player = scene.getplayer(pid)
	if not player then
		return
	end
	local target = scene.getplayer(targetid)
	if not target then
		sendpackage(player.agent,"scene","delplayer",{pid=targetid})
		return
	end
	sendpackage(player.agent,"scene","addplayer",target)
end

-- call方式
function scene.allpids(source)
	local pids = {}
	for pid,player in pairs(scene.players) do
		table.insert(pids,pid)
	end
	skynet.ret(skynet.pack(pids))
end

-- 退出服务
function scene.exit()
	logger.log("info","scene",string.format("[exit] address=%s sceneid=%d mapid=%d",scene.address,scene.sceneid,scene.mapid))
	for pid,player in pairs(scene.players) do
		scene.leave(pid)
	end
	skynet.exit()
end

function scene.broadcast_all(func)
	for pid,player in pairs(scene.players) do
		func(player)
	end
end

-- 九宫格划分地图
--y
--^------
--|6|7|8|
--|3|4|5|
--|0|1|2|
--------->x
function scene.initblocks(param)
	scene.width = assert(param.width)
	scene.height = assert(param.height)
	scene.block_width = assert(param.block_width)
	scene.block_height = assert(param.block_height)
	scene.blocks = {}
	scene.rows = math.ceil(scene.height/scene.block_height)
	scene.cols = math.ceil(scene.width/scene.block_width)
	for i=0,scene.rows-1 do
		scene.blocks[i] = {}
		for j=0,scene.cols-1 do
			scene.blocks[i][j] = {}
		end
	end
end

-- 玩家可视范围内(九宫格范围内)广播
function scene.broadcast_around(row,col,func)
	for i=row-1,row+1 do
		if scene.isvalid_row(i) then
			for j=col-1,col+1 do
				if scene.isvalid_col(j) then
					local inblock_pids = scene.getblock(i,j)
					for pid,_ in pairs(inblock_pids) do
						func(pid)
					end
				end
			end
		end
	end
end

function scene.getblock(row,col)
	local blocks = assert(scene.blocks[row],string.format("Invalid row,mapid=%s,row=%s",scene.mapid,row))
	local block = assert(blocks[col],string.format("Invalid col,mapid=%s,col=%s",scene.mapid,col))
	return block
end

function scene.delfromblock(player,row,col,func)
	local pid = player.pid
	local inblock_pids = scene.getblock(row,col)
	if inblock_pids[pid] then
		logger.log("debug","scene",string.format("[delfromblock] pid=%s row=%s col=%s",pid,row,col))
		inblock_pids[pid] = nil
		if func then
			scene.broadcast_around(row,col,func)
		end
		return true
	end
	return false
end

function scene.addtoblock(player,row,col,func)
	player.row,player.col = row,col
	local pid = player.pid
	local inblock_pids = scene.getblock(row,col)
	if not inblock_pids[pid] then
		logger.log("debug","scene",string.format("[addtoblock] pid=%s row=%s col=%s",pid,row,col))
		inblock_pids[pid] = true
		if func then
			scene.broadcast_around(row,col,func)
		end
		return true
	end
	return false
end

function scene.getrowcol(x,y)
	x = math.max(0,math.min(x,scene.width))
	y = math.max(0,math.min(y,scene.height))
	local row = math.ceil(y/scene.block_height)
	local col = math.ceil(x/scene.block_width)
	return row,col
end

function scene.isvalid_row(row)
	if not (0 <= row and row < scene.rows) then
		return false
	end
	return true
end

function scene.isvalid_col(col)
	if not (0 <= col and col < scene.cols) then
		return false
	end
	return true
end

--[[
-- 切换格子时可以减少发"新增玩家/删除玩家包"，以下为示例，其中
-- f:移动前玩家所在格子，t:移动后玩家所在格子,d:需要通知删除玩家的格子,a:需要通知新增玩家的格子
-- 空白格子和f,t所在格子可以减少发新增玩家包/删除玩家包
-- 1.水平左移     2.水平右移      3.垂直上移        4.垂直下移
-- ---------      ---------       -------           -------
-- |a| | |d|      |d| | |a|       |a|a|a|           |d|d|d|
-- ---------      ---------       -------           -------
-- |a|t|f|d|      |d|f|t|a|       | |t| |           | |f| |
-- ---------      ---------       -------           -------
-- |a| | |d|      |d| | |a|       | |f| |           | |t| |
-- ---------      ---------       -------           -------
--                                |d|d|d|           |a|a|a|
--                                -------           -------
--
-- 5.左下移动     6.左上移动      7.右上移动        7.右下移动
--    -------      -------          -------         -------
--    |d|d|d|      |a|a|a|          |a|a|a|         |d|d|d|
--  ---------      ---------      ---------         ---------
--  |a| |f|d|      |a|t| |d|      |d| |t|a|         |d|f| |a|
--  ---------      ---------      ---------         ---------
--  |a|t| |d|      |a| |f|d|      |d|f| |a|         |d| |t|a|
--  ---------      ---------      ---------         ---------
--  |a|a|a|          |d|d|d|      |d|d|d|             |a|a|a|
--  -------          -------      -------             -------
--]]

function scene.changeblock(player,oldrow,oldcol,row,col)
	if oldrow == row and oldcol == col then
		return
	end
	scene.delfromblock(player,oldrow,oldcol)
	scene.addtoblock(player,row,col)
	if row == oldrow and col - oldcol == -1 then				-- 水平左移
		print(string.format("[block] move left:(%s,%s)->(%s,%s)",oldrow,oldcol,row,col))
		local col1 = oldcol + 1
		if scene.isvalid_col(col1) then
			for row1=oldrow-1,oldrow+1 do
				if scene.isvalid_row(row1) then
					local inblock_pids = scene.getblock(row1,col1)
					for uid,_ in pairs(inblock_pids) do
						scene.sendpackage(uid,"scene","delplayer",player)
					end
				end
			end
		end
		local col1 = col - 1
		if scene.isvalid_col(col1) then
			for row1=row-1,row+1 do
				if scene.isvalid_row(row1) then
					local inblock_pids = scene.getblock(row1,col1)
					for uid,_ in pairs(inblock_pids) do
						scene.sendpackage(uid,"scene","addplayer",player)
					end
				end
			end
		end
	elseif row == oldrow and col - oldcol == 1 then		-- 水平右移
		print(string.format("[block] move right:(%s,%s)->(%s,%s)",oldrow,oldcol,row,col))
		local col1 = oldcol - 1
		if scene.isvalid_col(col1) then
			for row1=oldrow-1,oldrow+1 do
				if scene.isvalid_row(row1) then
					local inblock_pids = scene.getblock(row1,col1)
					for uid,_ in pairs(inblock_pids) do
						scene.sendpackage(uid,"scene","delplayer",player)
					end
				end
			end
		end
		local col1 = col + 1
		if scene.isvalid_col(col1) then
			for row1=row-1,row+1 do
				if scene.isvalid_row(row1) then
					local inblock_pids = scene.getblock(row1,col1)
					for uid,_ in pairs(inblock_pids) do
						scene.sendpackage(uid,"scene","addplayer",player)
					end
				end
			end
		end
	elseif col == oldcol and row - oldrow == 1 then		-- 垂直上移
		print(string.format("[block] move up:(%s,%s)->(%s,%s)",oldrow,oldcol,row,col))
		local row1 = oldrow - 1
		if scene.isvalid_row(row1) then
			for col1=oldcol-1,oldcol+1 do
				if scene.isvalid_col(col1) then
					local inblock_pids = scene.getblock(row1,col1)
					for uid,_ in pairs(inblock_pids) do
						scene.sendpackage(uid,"scene","delplayer",player)
					end
				end
			end
		end
		local row1 = row + 1
		if scene.isvalid_row(row1) then
			for col1=col-1,col+1 do
				if scene.isvalid_col(col1) then
					local inblock_pids = scene.getblock(row1,col1)
					for uid,_ in pairs(inblock_pids) do
						scene.sendpackage(uid,"scene","addplayer",player)
					end
				end
			end
		end
	elseif col == oldcol and row - oldrow == -1 then			-- 垂直下移
		print(string.format("[block] move down:(%s,%s)->(%s,%s)",oldrow,oldcol,row,col))
		local row1 = oldrow + 1
		if scene.isvalid_row(row1) then
			for col1=oldcol-1,oldcol+1 do
				if scene.isvalid_col(col1) then
					local inblock_pids = scene.getblock(row1,col1)
					for uid,_ in pairs(inblock_pids) do
						scene.sendpackage(uid,"scene","delplayer",player)
					end
				end
			end
		end
		local row1 = row - 1
		if scene.isvalid_row(row1) then
			for col1=col-1,col+1 do
				if scene.isvalid_col(col1) then
					local inblock_pids = scene.getblock(row1,col1)
					for uid,_ in pairs(inblock_pids) do
						scene.sendpackage(uid,"scene","addplayer",player)
					end
				end
			end
		end
	elseif row - oldrow == -1 and col - oldcol == -1 then		-- 左下移动
		print(string.format("[block] move leftdown:(%s,%s)->(%s,%s)",oldrow,oldcol,row,col))
		local row1 = oldrow + 1
		if scene.isvalid_row(row1) then
			for col1=oldcol-1,oldcol+1 do
				if scene.isvalid_col(col1) then
					local inblock_pids = scene.getblock(row1,col1)
					for uid,_ in pairs(inblock_pids) do
						scene.sendpackage(uid,"scene","delplayer",player)
					end
				end
			end
		end
		local col1 = oldcol + 1
		if scene.isvalid_col(col1) then
			for row1=oldrow-1,row do
				if scene.isvalid_row(row1) then
					local inblock_pids = scene.getblock(row1,col1)
					for uid,_ in pairs(inblock_pids) do
						scene.sendpackage(uid,"scene","delplayer",player)
					end
				end
			end
		end
		local row1 = row - 1
		if scene.isvalid_row(row1) then
			for col1=col-1,col+1 do
				if scene.isvalid_col(col1) then
					local inblock_pids = scene.getblock(row1,col1)
					for uid,_ in pairs(inblock_pids) do
						scene.sendpackage(uid,"scene","addplayer",player)
					end
				end
			end
		end
		local col1 = col - 1
		if scene.isvalid_col(col1) then
			for row1=row,row+1 do
				if scene.isvalid_row(row1) then
					local inblock_pids = scene.getblock(row1,col1)
					for uid,_ in pairs(inblock_pids) do
						scene.sendpackage(uid,"scene","addplayer",player)
					end
				end
			end
		end
	elseif row - oldrow == 1 and col - oldcol == -1 then	-- 左上移动
		print(string.format("[block] move left_up:(%s,%s)->(%s,%s)",oldrow,oldcol,row,col))
		local row1 = oldrow - 1
		if scene.isvalid_row(row1) then
			for col1=oldcol-1,oldcol+1 do
				if scene.isvalid_col(col1) then
					local inblock_pids = scene.getblock(row1,col1)
					for uid,_ in pairs(inblock_pids) do
						scene.sendpackage(uid,"scene","delplayer",player)
					end
				end
			end
		end
		local col1 = oldcol + 1
		if scene.isvalid_col(col1) then
			for row1=oldrow,row+1 do
				if scene.isvalid_row(row1) then
					local inblock_pids = scene.getblock(row1,col1)
					for uid,_ in pairs(inblock_pids) do
						scene.sendpackage(uid,"scene","delplayer",player)
					end
				end
			end
		end
		local row1 = row + 1
		if scene.isvalid_row(row1) then
			for col1=col-1,col+1 do
				if scene.isvalid_col(col1) then
					local inblock_pids = scene.getblock(row1,col1)
					for uid,_ in pairs(inblock_pids) do
						scene.sendpackage(uid,"scene","addplayer",player)
					end
				end
			end
		end
		local col1 = col - 1
		if scene.isvalid_col(col1) then
			for row1=row-1,row do
				if scene.isvalid_row(row1) then
					local inblock_pids = scene.getblock(row1,col1)
					for uid,_ in pairs(inblock_pids) do
						scene.sendpackage(uid,"scene","addplayer",player)
					end
				end
			end
		end
	elseif row - oldrow == 1 and col - oldcol == 1 then	-- 右上移动
		print(string.format("[block] move right_up:(%s,%s)->(%s,%s)",oldrow,oldcol,row,col))
		local row1 = oldrow - 1
		if scene.isvalid_row(row1) then
			for col1=oldcol-1,oldcol+1 do
				if scene.isvalid_col(col1) then
					local inblock_pids = scene.getblock(row1,col1)
					for uid,_ in pairs(inblock_pids) do
						scene.sendpackage(uid,"scene","delplayer",player)
					end
				end
			end
		end
		local col1 = oldcol - 1
		if scene.isvalid_col(col1) then
			for row1=oldrow,oldrow+1 do
				if scene.isvalid_row(row1) then
					local inblock_pids = scene.getblock(row1,col1)
					for uid,_ in pairs(inblock_pids) do
						scene.sendpackage(uid,"scene","delplayer",player)
					end
				end
			end
		end
		local row1 = row + 1
		if scene.isvalid_row(row1) then
			for col1=col-1,col+1 do
				if scene.isvalid_col(col1) then
					local inblock_pids = scene.getblock(row1,col1)
					for uid,_ in pairs(inblock_pids) do
						scene.sendpackage(uid,"scene","addplayer",player)
					end
				end
			end
		end
		local col1 = col + 1
		if scene.isvalid_col(col1) then
			for row1=row-1,row do
				if scene.isvalid_row(row1) then
					local inblock_pids = scene.getblock(row1,col1)
					for uid,_ in pairs(inblock_pids) do
						scene.sendpackage(uid,"scene","addplayer",player)
					end
				end
			end
		end

	elseif row - oldrow == -1 and col - oldcol == 1 then	-- 右下移动
		print(string.format("[block] move right_down:(%s,%s)->(%s,%s)",oldrow,oldcol,row,col))
		local row1 = oldrow + 1
		if scene.isvalid_row(row1) then
			for col1=oldcol-1,oldcol+1 do
				if scene.isvalid_col(col1) then
					local inblock_pids = scene.getblock(row1,col1)
					for uid,_ in pairs(inblock_pids) do
						scene.sendpackage(uid,"scene","delplayer",player)
					end
				end
			end
		end
		local col1 = oldcol - 1
		if scene.isvalid_col(col1) then
			for row1=oldrow-1,oldrow do
				if scene.isvalid_row(row1) then
					local inblock_pids = scene.getblock(row1,col1)
					for uid,_ in pairs(inblock_pids) do
						scene.sendpackage(uid,"scene","delplayer",player)
					end
				end
			end
		end
		local row1 = row - 1
		if scene.isvalid_row(row1) then
			for col1=col-1,col+1 do
				if scene.isvalid_col(col1) then
					local inblock_pids = scene.getblock(row1,col1)
					for uid,_ in pairs(inblock_pids) do
						scene.sendpackage(uid,"scene","addplayer",player)
					end
				end
			end
		end
		local col1 = col + 1
		if scene.isvalid_col(col1) then
			for row1=row,row+1 do
				if scene.isvalid_row(row1) then
					local inblock_pids = scene.getblock(row1,col1)
					for uid,_ in pairs(inblock_pids) do
						scene.sendpackage(uid,"scene","addplayer",player)
					end
				end
			end
		end
	else															-- 非邻接格子移动(正常移动不会走到这)
		-- 移动包跨度是否过大，由上层逻辑检查，这里仅作警告日志
		logger.log("warning","scene",string.format("[changeblock too large] pid=%s block=(%s,%s)->(%s,%s)",player.pid,oldrow,oldcol,row,col))
		scene.broadcast_around(oldrow,oldcol,function (uid)
			if uid ~= player.pid then
				scene.sendpackage(uid,"scene","delplayer",player)
			end
		end)
		scene.broadcast_around(row,col,function (uid)
			if uid ~= player.pid then
				scene.sendpackage(uid,"scene","addplayer",player)
			end
		end)
	end
end

function scene.dump()
	logger.log("info","dumpscene",string.format("sceneid=%s mapid=%s width=%s height=%s block_width=%s block_height=%s rows=%s cols=%s",scene.sceneid,scene.mapid,scene.width,scene.height,scene.block_width,scene.block_height,scene.rows,scene.cols))
	logger.log("info","dumpscene",string.format("players:\n%s",table.dump(scene.players)))

	logger.log("info","dumpscene",string.format("blocks:\n%s",table.dump(scene.blocks)))
end

-- 广播给本场景所有人
function scene.broadcast(package)
	scene.broadcast_all(function (player)
		sendpackage(player.agent,package.protoname,package.subprotoname,package.request)
	end)
end

local command = {
	init = scene.init,
	move = scene.move,
	enter = scene.enter,
	leave = scene.leave,
	reload = scene.reload,
	set = scene.set,
	query = scene.query,  -- 查询玩家场景信息
	allpids = scene.allpids,
	exit = scene.exit,
	broadcast = scene.broadcast,
	-- test
	dump = scene.dump,
}

skynet.start(function ()
	skynet.dispatch("lua",function (session,source,cmd,...)
		print("scene",scene.sceneid,session,source,cmd,...)
		local func = command[cmd]
		if not func then
			logger.log("warning","error",string.format("[scene] invalid_cmd=%s",cmd))
			return
		end
		func(...)
	end)
end)
