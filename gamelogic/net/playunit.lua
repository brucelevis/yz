netplayunit = netplayunit or {
	C2S = {},
	S2C = {},
}

local C2S = netplayunit.C2S
local S2C = netplayunit.S2C

function C2S.new_redpacket(player,request)
	local typ = assert(request.type)
	local num = assert(request.num)
	local money = assert(request.money)
	local restype = RESTYPE.COIN
	local min_money = data_GlobalVar.RedPacketMinMoney
	local max_money = data_GlobalVar.RedPacketMaxMoney
	if money < min_money then
		net.msg.S2C.notify(player.pid,language.format("单个红包最低限额为{1}",min_money))
		return
	end
	if money > max_money then
		net.msg.S2C.notify(player.pid,language.format("单个红包最高限额为{1}",max_money))
		return
	end

	local redpacket_data = {
		type = typ,
		num = num,
		money = money,
		owner = player.pid,
		owner_name = player:getname(),
		restype = restype,
	}
	local needlv = data_GlobalVar.NewRedPacketNeedLv
	if player.lv < needlv then
		net.msg.S2C.notify(player.pid,language.format("需要{1}级以上才能参加公会红包活动",needlv))
		return
	end
	if not player:validpay(restype,money,true) then
		return
	end

	if typ == REDPACKET_TYPE.WORLD then
		net.playunit.C2S._world_new_redpacket(player.pid,redpacket_data)
	elseif typ == REDPACKET_TYPE.UNION then
		local unionid = player:unionid()
		if not unionid then
			net.msg.S2C.notify(player.pid,language.format("你没有公会"))
			return
		end
		local isok,errmsg
		if cserver.isunionsrv() then
			isok,errmsg = net.playunit.C2S._union_new_redpacket(player.pid,redpacket_data)
		else
			isok,errmsg = rpc.call(cserver.unionsrv(),"rpc","net.playunit.C2S._union_new_redpacket",player.pid,redpacket_data)
		end
		if not isok then
			if errmsg then
				net.msg.S2C.notify(player.pid,errmsg)
			end
		else
			player:addres(restype,-money,"newpacket",true)
		end
	end
end

function C2S._world_new_redpacket(pid,redpacket_data)
	local redpacket = globalmgr.redpacketmgr:add(redpacket_data)
	playermgr.broadcast(function (player)
		sendpackage(player.pid,"playunit","redpacket",{
			redpacket = redpacket:pack(),
		})
	end)
end

function C2S._union_new_redpacket(pid,redpacket_data)
	local unionid = unionmgr:unionid(pid)
	if not unionid then
		return false,language.format("你没有公会")
	end
	local union = unionmgr:getunion(unionid)
	local needlv = data_GlobalVar.UnionNewRedPacketNeedDatingLv
	if union:getlv() < needlv then
		return false,language.format("需要{1}级以上公会才开放此功能")
	end
	local redpacket = globalmgr.redpacketmgr:add(redpacket_data)
	local pids = table.keys(union.members.objs)
	unionmgr:sendpackage(pids,"playunit","redpacket",{
		redpacket = redpacket:pack(),
	})
end

-- 抢红包
function C2S.spell_luck(player,request)
	local id = assert(request.id)
	local needlv = data_GlobalVar.NewRedPacketNeedLv
	if player.lv < needlv then
		net.msg.S2C.notify(player.pid,language.format("需要{1}级以上才能领取红包",needlv))
		return
	end
	local srvname = globalmgr.srvname(id)
	local self_srvname = cserver.getsrvname()
	local isok,state,rank,restype
	if self_srvname == srvname then
		isok,state,rank,restype = net.playunit.C2S._spell_luck({pid=player.pid,name=player:getname()},id)
	else
		isok,state,rank,restype = rpc.call(srvname,"rpc","net.playunit.C2S._spell_luck",{pid=player.pid,name=player:getname()},id)
	end
	if not isok then
		local errmsg = state
		if errmsg then
			net.msg.S2C.notify(player.pid,errmsg)
		end
	else
		if state == credpacket.GOT_SUCC then
			local money = rank.money
			player:addres(restype,money,"spell_luck",true)
		end
		sendpackage(player.pid,"playunit","spell_luck_result",{
			state = state,
			rank = rank,
			restype = restype,
		})
	end
end

function C2S._spell_luck(player,id)
	local pid = player.pid
	local name = player.name
	local redpacket = globalmgr.redpacketmgr:get(id)
	if not redpacket then
		return false,language.format("该红包已过期")
	end
	local isok,state,rank,restype = globalmgr.redpacketmgr:spell_luck(player,id)
	print(isok,state,table.dump(rank),restype)
	if isok then
		if state == credpacket.GOT_SUCC then
			local pack = {
				redpacket = redpacket:pack(),
				rank = rank,
			}
			if redpacket.type == REDPACKET_TYPE.WORLD then
				playermgr.broadcast(function (player)
					sendpackage(player.pid,"playunit","spell_luck_succ",pack)
				end)
			elseif redpacket.type == REDPACKET_TYPE.UNION then
				local unionid = unionmgr:unionid(pid)
				if unionid then
					local union = unionmgr:getunion(unionid)
					local pids = table.keys(union.members.objs)
					unionmgr:sendpackage(pids,"playunit","spell_luck_succ",pack)
				end
			end
		end
	end
	return isok,state,rank,restype
end

function C2S.redpacket_lookranks(player,request)
	local id = assert(request.id)
	local srvname = globalmgr.srvname(id)
	local self_srvname = cserver.getsrvname()
	local isok,ranks,restype
	if self_srvname == srvname then
		isok,ranks,restype = globalmgr.redpacketmgr:lookranks(id)
	else
		isok,ranks,restype = rpc.call(srvname,"rpc","globalmgr.redpacketmgr:lookranks",id)
	end
	if not isok then
		local errmsg = ranks
		if errmsg then
			net.msg.S2C.notify(player.pid,errmsg)
		end
	else
		sendpackage(player.pid,"playunit","redpacket_ranks",{
			id = id,
			restype = restype,
			ranks = ranks,
		})
	end
end

function C2S.share_redpacket(player,request)
	local pid = player.pid
	local id = assert(request.id)
	local srvname = globalmgr.srvname(id)
	local self_srvname = cserver.getsrvname()
	local isok,errmsg
	if self_srvname == srvname then
		isok,errmsg = net.playunit.C2S._share_redpacket(pid,id)	
	else
		isok,errmsg = rpc.call(srvname,"rpc","net.playunit.C2S._share_redpacket",pid,id)
	end
	if not isok then
		if errmsg then
			net.msg.S2C.notify(pid,errmsg)
		end
		return
	end
end

function C2S._share_redpacket(pid,id)
	local redpacket = globalmgr.redpacketmgr:get(id)
	if not redpacket then
		return false,language.format("该红包已过期")
	end
	if redpacket.type == REDPACKET_TYPE.WORLD then
		playermgr.broadcast(function (player)
			sendpackage(player.pid,"playunit","redpacket",{
				redpacket = redpacket:pack(),
				isshare = true,
			})
		end)
	elseif redpacket.type == REDPACKET_TYPE.UNION then
		local unionid = unionmgr:unionid(pid)
		if not unionid then
			return false,language.format("你没有公会")
		end
		local union = unionmgr:getunion(unionid)
		local needlv = data_GlobalVar.UnionNewRedPacketNeedDatingLv
		if union:getlv() < needlv then
			return false,language.format("需要{1}级以上公会才开放此功能")
		end
		local pids = table.keys(union.members.objs)
		unionmgr:sendpackage(pids,"playunit","redpacket",{
			redpacket = redpacket:pack(),
			isshare = true,
		})
	end
	return true
end

-- s2c
function S2C.opendati(pid,questionid,respondid,data)
	sendpackage(pid,"playunit","opendati",{
		questionid = questionid,
		respondid = respondid,
		cnt = data.cnt,
		maxcnt = data.maxcnt,
		exceedtime = data.exceedtime,
		npcname = data.npcname,
		npcshape = data.npcshape,
		questionbank = data.questionbank,
	})
end

return netplayunit
