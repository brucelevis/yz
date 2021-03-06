citem = class("citem",{
	usefunc = {},
})

function citem:init(param)
	param = param or {}
	self.id = param.id
	self.type = param.type
	self.num = param.num
	self.bind = param.bind
	self.createtime = param.createtime

	-- 附魔增加的属性
	self.fumo = {
		maxhp = nil,			-- 血量上限
		maxmp = nil,			-- 魔法上限
		atk = nil,				-- 攻击力
		latk = nil,				-- 远程攻击力
		def = nil,				-- 防御
		sp = nil,				-- 速度
		fq = nil,				-- 法强
		mz = nil,				-- 命中
		bj = nil,				-- 暴击
		fsp = nil,				-- 法术攻击速度(咏唱速度)
		dfsp = nil,					-- 咏唱延迟(delay 法术攻击速度)
		fdef = nil,				-- 法术防御
		fsqd = nil,				-- 法术强度
		ds = nil,				-- 躲闪
		rx = nil,				-- 韧性
		hpr = nil,				-- 生命值回复
		mpr = nil,				-- 魔法值回复
		jzfs = nil,				-- 近战反伤
		ycfs = nil,				-- 远程反伤
		mffs = nil,				-- 魔法反伤
		hjct = nil,				-- 护甲穿透
		fsct = nil,				-- 法术穿透
		bt = nil,				-- 霸体
		xx = nil,				-- 吸血
		fsxx = nil,				-- 法术吸血
	}
	self.lv = 0		 -- 卡片等级(仅对卡片有效)
end

function citem:load(data)
	if not data or not next(data) then
		return
	end
	self.id = data.id
	self.type = data.type
	self.num = data.num
	self.bind = data.bind
	self.createtime = data.createtime or os.time()

	self.fumo = data.fumo or {}
	self.lv = data.lv or 0
end

function citem:save()
	local data = {}
	data.id = self.id
	data.type = self.type
	data.num = self.num
	data.bind = self.bind
	data.createtime = self.createtime
	data.pos = self.pos
	data.fumo = self.fumo
	data.lv = self.lv
	return data
end

-- for s2c
function citem:pack()
	local data = self:save()
	data.pos = self.pos --放入背包后产生的属性
	return data
end

function citem:canuse(player,target)
	local itemtype = self.type
	local itemdata = itemaux.getitemdata(itemtype)
	--if not itemdata.canuse or itemdata.canuse == 0 then
	if not istrue(itemdata.canuse) then
		return false,language.format("该物品无法使用")
	end
	if player.lv < itemdata.needlv then
		return false,language.format("需要#<G>{1}级#才能使用该物品",itemdata.needlv)
	end
	if itemdata.usecnt_perday and itemdata.usecnt_perday > 0 then
		local key = string.format("itemusecnt.%s",itemtype)
		local has_usecnt = player.today:query(key,0)
		if has_usecnt >= itemdata.usecnt_perday then
			return false,language.format("每天最多使用#<R>{1}#次#<G>{2}#",itemdata.usecnt_perday,itemdata.name)
		end
	end
	if itemdata.canuse_afterdays and itemdata.canuse_afterdays > 0 then
		local canuse_time = self.createtime + itemdata.canuse_afterdays * DAY_SECS
		canuse_time = getdayzerotime(canuse_time) + 5 * HOUR_SECS
		local now = os.time()
		if now < canuse_time then
			return false,language.format("{1}后才可以使用该物品",os.date("%m/%d %H:%M",canuse_time))
		end
	end
	return true
end

function citem:afteruse(player,target,num)
	local itemtype = self.type
	local itemdata = itemaux.getitemdata(itemtype)
	if itemdata.usecnt_perday and itemdata.usecnt_perday > 0 then
		local key = string.format("itemusecnt.%s",itemtype)
		player.today:add(key,1)
	end
end

-- 默认对目标使用时消耗的数量
function citem:getusenum(target)
	return 1
end


function citem:use(player,target,num)
	local itemid = self.id
	local itemtype = self.type
	local _,itemdb = player:getitem(itemid)
	assert(itemdb)
	local canuse,errmsg = self:canuse(player,target)
	if not canuse then
		net.msg.S2C.notify(player.pid,errmsg)
		return
	end
	if not num then
		num = self:getusenum(target)
	end
	if self.num < num then
		net.msg.S2C.notify(player.pid,language.format("物品数量不足#<R>{1}#个",num))
		return
	end

	local usefunc = citem.usefunc[itemtype]
	if usefunc then
		local isok,costnum = usefunc(self,player,target,num)
		if isok then
			-- 如果具体使用函数返回了消耗数量，则用它的，否则用指定的使用数量
			costnum = costnum or num
			local target_id = 0
			if target then
				target_id = target.pid and target.pid or target.id
			end
			local reason = string.format("use->%s",target_id)
			itemdb:costitembyid(itemid,costnum,reason)
			self:afteruse(player,target,num)
		end
		return isok,costnum
	else
		logger.log("error","error",string.format("[use] Unkonw itemtype:%s",itemtype))
	end
end

-- getter
function citem:get(what)
	local itemdata = itemaux.getitemdata(self.type)
	return itemdata[what]
end

function __hotfix(oldmod)
	-- 重新初始化注册的使用函数
	hotfix.hotfix("gamelogic.item.use.drag")
	hotfix.hotfix("gamelogic.item.use.baotu")
	hotfix.hotfix("gamelogic.item.use.box")
	hotfix.hotfix("gamelogic.item.use.consume")
	hotfix.hotfix("gamelogic.item.use.pet")
end

return citem
