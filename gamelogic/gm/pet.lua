gm = require "gamelogic.gm.init"

local pet = {}

function gm.pet(args)
	local funcname = args[1]
	local player = playermgr.getplayer(master_pid)
	if not player then
		return
	end
	local func = pet[funcname]
	if not func then
		gm.notify("指令未找到，查看帮助:help pet")
		return
	end
	table.remove(args,1)
	func(player,args)
end

--- 指令: pet add pettype
--- 用法: pet add 20002 <=> 增加一只type为20002的宠物
function pet.add(player,args)
	local isok,args = checkargs(args,"int")
	if not isok then
		gm.notify("pet add 20002 <=> 增加一只20002宠物")
		return
	end
	local pettype = args[1]
	if player.petdb:getspace() - player.petdb.len <= 0 then
		gm.notify("宠物可携带数目已满")
		return
	end
	local pet = petaux.newpet(pettype)
	player.petdb:addpet(pet,"gm")
end

--- 指令: pet addexp exp petid(不填默认参战宠)
--- 用法: pet addexp 10000 <=> 为当前参战宠增加10000点经验
function pet.addexp(player,args)
	local isok,args = checkargs(args,"int","*")
	if not isok then
		gm.notify("pet addexp 10000 <=> 为当前参战宠增加10000点经验")
		return
	end
	local addexp = args[1]
	local petid = args[2] and tonumber(args[2]) or player.petdb.readywar_petid
	if not petid then
		gm.notify("没有设置参战宠物（也可增加宠物id参数）")
		return
	end
	player.petdb:addexp(petid,addexp,"gm")
end

--- 指令: pet addclose close petid(不填默认参战宠)
--- 用法: pet addclose 10000 <=> 为当前参战宠增加10000点亲密度
function pet.addclose(player,args)
	local isok,args = checkargs(args,"int","*")
	if not isok then
		gm.notify("pet addclose 10000 <=> 为当前参战宠增加10000点亲密度")
		return
	end
	local addclose = args[1]
	local petid = args[2] and tonumber(args[2]) or player.petdb.readywar_petid
	if not petid then
		gm.notify("没有设置参战宠物（也可增加宠物id参数）")
		return
	end
	player.petdb:addclose(petid,addclose,"gm")
end
