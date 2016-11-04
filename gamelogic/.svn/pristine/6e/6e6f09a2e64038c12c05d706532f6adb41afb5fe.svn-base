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
	request.srcpos = scene:fixpos(request.srcpos)
	request.dstpos = scene:fixpos(request.dstpos)
	if not netscene.isvalid_move(player.pos,request.srcpos) then
		sendpackage(player.pid,"scene","fixpos",{pos=player.pos})
		logger.log("warning","scene",string.format("[invalid_move] pid=%s pos=%s->%s",player.pid,player.pos,request.srcpos))
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
	request.pos = scene:fixpos(request.pos)
	player:enterscene(request.sceneid,request.pos)
end

function C2S.query(player,request)
	local sceneid = player.sceneid
	local targetid = assert(request.targetid)
	local scene = scenemgr.getscene(sceneid)
	scene:query(player.pid,targetid)
end

-- s2c

return netscene

