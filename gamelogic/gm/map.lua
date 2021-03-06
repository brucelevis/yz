---指令: jumpto
---用法: jumpto 场景ID 坐标
---举例: jumpto 1 800 800 <=> 把自身传送到女儿国坐标(800,800)
function gm.jumpto(args)
	local isok,args = checkargs(args,"int","int","int")
	if not isok then
		gm.notify("用法: jumpto 场景ID 坐标")
		return
	end
	local sceneid = args[1]
	local pos = {}
	pos.x = args[2]
	pos.y = args[3]
	pos.dir = 1
	master:jumpto(sceneid,pos)
end

--- 用法: addnpc 怪物造型 场景 x y [持续时间]
--- 举例: addnpc 20043 1 800 800 300 <=> 在(1,800,800) 位置生成20043造型NPC，持续300秒
function gm.addnpc(args)
	local isok,args = checkargs(args,"int","int","int","int","*")
	if not isok then
		gm.notify("用法: addnpc 怪物造型 场景 x y [持续时间]")
		return
	end
	local npcshape = args[1]
	local sceneid = args[2]
	local x = args[3]
	local y = args[4]
	local lifetime = tonumber(args[3]) or 300
	local exceedtime = os.time() + lifetime
	local isok = scenemgr.addnpc({
		shape = npcshape,
		name = "测试NPC",
		pos = { x = x, y = y, dir = 1},
		sceneid = sceneid,
		purpose = "test",
		exceedtime = exceedtime,
	})
	gm.notify(string.format("NPC生成%s",isok and "成功" or "失败"))
end

--- 用法: addnpcbypos 怪物造型 坐标ID [持续时间]
--- 举例: addnpcbypos 20043 8105001 300 <=> 在8105001位置生成20043造型NPC，持续300秒
function gm.addnpcbypos(args)
	local isok,args = checkargs(args,"int","string","*")
	if not isok then
		gm.notify("用法: addnpc 怪物造型 坐标ID [持续时间]")
		return
	end
	local npcshape = args[1]
	local posid = args[2]
	local lifetime = tonumber(args[3]) or 300
	local exceedtime = os.time() + lifetime
	local isok = scenemgr.addnpc({
		shape = npcshape,
		name = "测试NPC",
		posid = posid,
		purpose = "test",
		exceedtime = exceedtime,
	})
	gm.notify(string.format("NPC生成%s",isok and "成功" or "失败"))
end

return gm
