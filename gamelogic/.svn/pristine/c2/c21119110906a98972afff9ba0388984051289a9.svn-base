gm = require "gamelogic.gm.init"

local chapter = {}

function gm.chapter(args)
	local funcname = args[1]
	local player = playermgr.getplayer(master_pid)
	if not player then
		return
	end
	local func = chapter[funcname]
	if not func then
		return
	end
	table.remove(args,1)
	func(player,args)
end

function chapter.rmaward(player,args)
	local isok,args = checkargs(args,"*")
	if not isok then
		gm.notify("chapter rmaward 奖励id(不填则全部清空)",player.pid)
		return
	end
	local awardid = args[1] and int(args[1]) or 0 
	if awardid ~= 0 then
		table.remove_val(player.chapterdb.awardrecord,awardid,1)
	else
		player.chapterdb.awardrecord = {}
	end
	net.chapter.S2C.awardrecord(player.pid,player.chapterdb.awardrecord)
end

function chapter.setstar(player,args)
	local isok,args = checkargs(args,"int","int")
	if not isok then
		gm.notify("chapter setstar 关卡id 星级",player.pid)
		return
	end
	local chapterid = args[1]
	local star = args[2]
	local chapter = player.chapterdb:get(chapterid)
	if not chapter then
		gm.notify("关卡未解锁",player.pid)
		return
	end
	local attrs = { star = star, }
	if star == 3 and not chapter.pass then
		attrs.pass = true
	end
	player.chapterdb:update(chapterid,attrs)
end
