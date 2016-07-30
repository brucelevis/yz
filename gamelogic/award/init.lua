
--[[
奖励控制表格式:
{
	{
		type = 1/2 #1--独立计算概率(概率基数为1000000)，2-－互斥概率
		value = {
			[awardid1] = ratio1,
			[awardid2] = ratio2,
			...
		}
	},
	...
}

奖励项格式：
{
	gold = 金币,
	silver = 银币,
	coin = 铜钱,
	items = {
		物品类型,
		...
	},
	pets = {
		宠物类型,
		...
	},
}
]]

award = award or {}
function award.orgaward(orgid,reward)
end

local BASE_RATIO = BASE_RATIO or 1000000
function award.__player(pid,bonus,reason,btip)
	local player = playermgr.getplayer(pid)
	if player then
		local num
		if bonus.__formula then -- 后续可能去掉
			bonus = deepcopy(bonus)
			bonus.__formula = nil
			bonus.num = execformula(player,bonus.num)
		end
		local has_lackbonus = false
		local lackbonus = {
		}
		for name,id in pairs(RESTYPE) do -- RESTYPE == data_ResType
			if type(name) == "string" then
				name = string.lower(name)
				local resnum = bonus[name]
				if resnum and resnum > 0 then
					local hasbonus_num = player:addres(name,resnum,reason,btip)
					if resnum - hasbonus_num > 0 then
						lackbonus[name] = resnum - hasbonus_num
					end
				end
			end
		end
		if not table.isempty(bonus.items) then
			lackbonus.items = {}
			for i,item in ipairs(bonus.items) do
				item = deepcopy(item)
				local itemdb = player:getitemdb(item.type)
				local hasbonus_num = itemdb:additem2(item,reason)
				if btip then
					-- dosomething
				end
				item.num = item.num - hasbonus_num
				if item.num > 0 then
					has_lackbonus = true
					table.insert(lackbonus.items,item)
				end
			end
		end
		if not table.isempty(bonus.pets) then
			lackbonus.pets = {}
			for i,pet in ipairs(bonus.pets) do
				pet = deepcopy(pet)
				-- dosomething
			end
		end
		if has_lackbonus and not table.isempty(lackbonus) then
			return lackbonus
		end
	else
		return deepcopy(bonus)
	end

end

function award.player(pid,bonus,reason,btip)
	local lackbonus = award.__player(pid,bonus,reason,btip)
	-- 1.玩家不在线，2.由于背包不足/资源过剩没有加到的资源/物品,需要发邮件
	if not table.isempty(lackbonus) then
		local attach = lackbonus
		mailmgr.sendmail(pid,{
			srcid = SYSTEM_MAIL,
			author = "系统",
			title = "奖励",
			content = "",
			attach = attach,
		})
	end
end

function award.org(orgid,bonus,reason,btip)
end

function award.mergebonus(bonuss)
	local merge_bonus = {
		gold = 0,
		silver = 0,
		coin = 0,
		items = {},
		pets = {}
	}
	for i,bonus in ipairs(bonuss) do
		merge_bonus.gold = merge_bonus.gold + (bonus.gold or 0)
		merge_bonus.silver = merge_bonus.silver + (bonus.silver or 0)
		merge_bonus.coin = merge_bonus.coin + (bonus.coin or 0)
		if not table.isempty(bonus.items) then
			table.extend(merge_bonus.items,bonus.items)
		end
		if not table.isempty(bonus.pets) then
			table.extend(merge_bonus.pets,bonus.pets)
		end
	end
	return merge_bonus
end

-- rewards: 奖励控制表
function award.getaward(reward,func)
	func = func or getawarddata
	local bonuss = {}
	if reward.type == 1 then
		reward = reward.value
		for awardid,ratio in pairs(reward) do
			if ishit(ratio,BASE_RATIO) then
				local bonus = func(awardid)
				table.insert(bonuss,bonus)
			end
		end
	else
		assert(reward.type==2)
		reward = reward.value
		local awardid = choosekey(reward)
		local bonus = func(awardid)
		table.insert(bonuss,bonus)	
	end
	return award.mergebonus(bonuss)
end

function doaward(typ,id,reward,reason,btip)
	local func = assert(award[typ],"Invalid type:" .. tostring(typ))

	local srvname = getsrvname(typ,id)
	logger.log("info","award",format("[doaward] srvname=%s typ=%s id=%d reward=%s reason=%s btip=%s",srvname,typ,id,reward,reason,btip))
	return func(id,reward,reason,btip)
end

function getsrvname(typ,id)
	if typ == "player" then
		return route.getsrvname(id)
	elseif typ == "org" then
		-- TODO:
	end
end

function isres(typ)
	return data_GameID.resource.startid <= typ and typ < data_GameID.resource.endid
end

function isitem(typ)
	return data_GameID.item.startid <= typ and typ < data_GameID.item.endid
end

-- just for test
function getawarddata(awardid)
	local data = data_TemplAward[awardid]
	if data then
		return data.award
	end
end

return award
