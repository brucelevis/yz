netpet = netpet or {
	C2S = {},
	S2C = {},
}

local C2S = netpet.C2S
local S2C = netpet.S2C

function C2S.delpet(player,request)
	local id = assert(request.id)
	local pet = player.petdb:getpet(id)
	if not pet then
		return
	end
	player.petdb:delpet(id,"freepet")
end

function C2S.war_or_rest(player,request)
	local id = assert(request.id)
	local pet = player.petdb:getpet(id)
	if pet then
		if pet.readywar then
			player.petdb:unreadywar(id)
		else
			player.petdb:readywar(id)
		end
	end
end

function C2S.changestatus(player,request)
	local id = assert(request.id)
	local pet = player.petdb:getpet(id)
	if not pet then
		return
	end
	local costclose = data_1700_PetChangeStatusCost[pet.lv].costclose
	if pet.close < costclose then
		net.msg.S2C.notify(player.pid,language.format("亲密度不足"))
		return
	end
	player.petdb:addclose(id,-costclose,"changestatus")
	local status = randlist(table.keys(data_1700_PetStatus))
	player.petdb:change_petstatus(id,status,"useclose")
	net.msg.S2C.notify(player.pid,language.format("{1}变为了{2}状态",pet:getname(),data_1700_PetStatus[status].name))
end

function C2S.train(player,request)
	local id = assert(request.id)
	local pet = player.petdb:getpet(id)
	if not pet then
		return
	end
	local quality = pet:get("quality")
	local needitem
	if quality == 1 then
		needitem = data_1700_PetVar.NormalTrainItem
	elseif quality == 2 then
		needitem = data_1700_PetVar.RareTrainItem
	else
		needitem = data_1700_PetVar.HolyTrainItem
	end
	if player.itemdb:getnumbytype(needitem.item) < needitem.num then
		net.msg.S2C.notify(player.pid,language.format("所需训练物品不足"))
		return
	end
	player.itemdb:costitembytype(needitem.item,needitem.num,"trainpet")
	player.petdb:trainpet(id)
end

function C2S.forgetskill(player,request)
	local skillid = assert(request.skillid)
	local id = assert(request.id)
	local pet = player.petdb:getpet(id)
	if not pet then
		return
	end
	if not pet:hasskill(skillid) then
		return
	end
	local costclose = petaux.forgetskillcost(skillid)
	if pet.close < costclose then
		net.msg.S2C.notify(player.pid,language.format("亲密度不足{1}，无法遗忘技能",costclose))
		return
	end
	if table.find(pet:get("bind_skills"),skillid) or skillid == pet:getbianyiskill() then
		net.msg.S2C.notify(player.pid,language.format("无法遗忘绑定技能"))
		return
	end
	logger.log("info","pet",string.format("[forgetskill] pid=%d petid=%d skillid=%d",player.pid,id,skillid))
	player.petdb:addclose(id,-costclose,"forgetskill")
	pet:delskill(skillid)
	net.msg.S2C.notify(player.pid,language.format("{1}遗忘成功",petaux.getskillvalue(skillid,"name")))
end

function C2S.unwieldequip(player,request)
	local itemid = assert(request.itemid)
	local id = assert(request.id)
	player.petdb:unwieldequip(id,itemid)
end

function C2S.combine(player,request)
	local masterid = assert(request.masterid)
	local subid = assert(request.subid)
	player.petdb:combine(masterid,subid)
end

function C2S.rename(player,request)
	local id = assert(request.id)
	local name = assert(request.name)
	player.petdb:rename(id,name)
end

function C2S.setchat(player,request)
	local id = assert(request.id)
	local case = assert(request.case)
	local chat = assert(request.chat)
	player.petdb:setchat(id,case,chat)
end

function C2S.expandspace(player,request)
	local itemid = assert(request.itemid)
	local space = player.petdb:getspace()
	local data = data_1700_PetUnlockSpace[space + 1]
	if not data then
		net.msg.S2C.notify(player.pid,language.format("宠物可携带数目已达上限"))
		return
	end
	local item = player:getitem(itemid)
	if not item or item.type ~= data.item.item or item.num < data.item.num then
		net.msg.S2C.notify(player.pid,language.format("解锁所需物品不足"))
		return
	end
	player.itemdb:costitembyid(itemid,data.item.num,"petexpandspace")
	player.petdb:expand(1,"costitem")
end

function C2S.commenton(player,request)
	local pettype = assert(request.pettype)
	local msg = assert(request.msg)
	if cserver.isgamesrv() then
		local isok,errmsg = rpc.call(cserver.datacenter(),"rpc","net.pet.C2S._commenton",player.pid,pettype,msg,player.name,os.time())
		if not isok then
			if errmsg then
				net.msg.S2C.notify(player.pid,errmsg)
			end
			return
		end
		local comments = errmsg
		sendpackage(player.pid,"pet","sendcomments",{
			comments = comments,
			excedtime = os.time() + 60 * 5,
		})
	end
end

function C2S._commenton(pid,pettype,msg,name,time)
	if not cserver.isdatacenter() then
		return false
	end
	local petcomment,errmsg = globalmgr.petcommentmgr:getpetcomment(pettype)
	if not petcomment then
		return false,errmsg
	end
	local isok
	isok,errmsg = petcomment:addcomment(pid,name,msg,time)
	if not isok then
		return false,errmsg
	end
	return true,petcomment:pack(pid)
end

function C2S.getcomments(player,request)
	local pettype = assert(request.pettype)
	if cserver.isgamesrv() then
		local isok,errmsg = rpc.call(cserver.datacenter(),"rpc","net.pet.C2S._getcomments",player.pid,pettype)
		if not isok then
			if errmsg then
				net.msg.S2C.notify(player.pid,errmsg)
			end
			return
		end
		local comments = errmsg
		sendpackage(player.pid,"pet","sendcomments",{
			comments = comments,
			excedtime = os.time() + 60 * 5,
		})
	end
end

function C2S._getcomments(pid,pettype)
	if not cserver.isdatacenter() then
		return false
	end
	local petcomment,errmsg = globalmgr.petcommentmgr:getpetcomment(pettype)
	if not petcomment then
		return false,errmsg
	end
	return true,petcomment:pack(pid)
end

function C2S.likecomment(player,request)
	local pettype = assert(request.pettype)
	local id = assert(request.id)
	if cserver.isgamesrv() then
		local isok,errmsg = rpc.call(cserver.datacenter(),"rpc","net.pet.C2S._likecomment",player.pid,pettype,id)
		if errmsg then
			net.msg.S2C.notify(player.pid,errmsg)
		end
		sendpackage(player.pid,"pet","likeresult",{
			isok = isok,
		})
	end
end

function C2S._likecomment(pid,pettype,id)
	if not cserver.isdatacenter() then
		return false
	end
	local petcomment,errmsg = globalmgr.petcommentmgr:getpetcomment(pettype)
	if not petcomment then
		return false,errmsg
	end
	return petcomment:likecomment(pid,id)
end

-- s2c

return netpet
