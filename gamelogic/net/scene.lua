netscene = netscene or {
	C2S = {},
	S2C = {},
}
local C2S = netscene.C2S
local S2C = netscene.S2C

function netscene.isvalid_move(srcpos,topos)
	local distance = getdistance(srcpos,topos)
	if distance > 320 then  -- 32*10
		return false
	end
	return true
end

function C2S.move(player,request)
	if table.equal(player.pos,request.srcpos) then
		return
	end
	local scene = scenemgr.getscene(player.sceneid)
	if not scene:isvalidpos(request.srcpos) then
		request.srcpos = scene:fixpos(request.srcpos)
	end
	if not scene:isvalidpos(request.dstpos) then
		request.dstpos = scene:fixpos(request.dstpos)
	end
	if not player:canmove() then
		return
	end
	if not netscene.isvalid_move(player.pos,request.srcpos) then
		sendpackage(player.pid,"scene","fixpos",{pos=player.pos})
		logger.log("warning","scene",format("[invalid_move->fixpos] pid=%s pos=%s->%s",player.pid,player.pos,request.srcpos))
		return
	end
	player:move(request)
end

function C2S.enter(player,request)
	-- 是否禁止同场景跳转?
	--if request.sceneid == player.sceneid then
	--	return
	--end
	local scene = scenemgr.getscene(request.sceneid)
	if not scene then
		return
	end
	player:enterscene(request.sceneid,request.pos)
end

function C2S.query(player,request)
	local sceneid = player.sceneid
	local targetid = assert(request.targetid)
	local scene = scenemgr.getscene(sceneid)
	scene:query(player.pid,targetid)
end

function C2S.fucknpc(player,request)
	local npcid = assert(request.npcid)
	local sceneid = player.sceneid
	local npc = scenemgr.getnpc(npcid,sceneid)
	if not npc then
		net.msg.S2C.notify(player.pid,language.format("怪物不存在"))
		return
	end
	print(table.dump(npc))
	if npc.purpose == "baotu" then
		huodongmgr.playunit.baotu.startwar(player,npc)
	end
end

-- s2c

return netscene

