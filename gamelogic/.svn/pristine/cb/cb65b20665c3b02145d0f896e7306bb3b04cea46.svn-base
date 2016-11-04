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
	-- 位置一般是放入容器后才有的属性
	self.pos = param.pos
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
	self.pos = data.pos
end

function citem:save()
	local data = {}
	data.id = self.id
	data.type = self.type
	data.num = self.num
	data.bind = self.bind
	data.createtime = self.createtime
	data.pos = self.pos
	return data
end

function citem:canuse(player,target)
	local itemtype = self.type
	local itemdata = getitemdata(itemtype)
	--if not itemdata.canuse or itemdata.canuse == 0 then
	if not istrue(itemdata.canuse) then
		return false,language.format("该物品无法使用")
	end
	if player.lv < itemdata.needlv then
		return false,language.format("需要#<G>%d级#才能使用该物品",itemdata.needlv)
	end
	if itemdata.usecnt_perday and itemdata.usecnt_perday > 0 then
		local key = string.format("itemusecnt.%s",itemtype)
		local has_usecnt = player.today:query(key,0)
		if has_usecnt >= itemdata.usecnt_perday then
			return false,language.format("每天最多使用#<R>%d#次#<G>%s#",itemdata.usecnt_perday,itemdata.name)
		end
	end
	if itemdata.canuse_afterdays and itemdata.canuse_afterdays > 0 then
		local canuse_time = self.createtime + itemdata.canuse_afterdays * DAY_SECS
		canuse_time = getdayzerotime(canuse_time) + 5 * HOUR_SECS
		local now = os.time()
		if now < canuse_time then
			return false,language.format("%s后才可以使用该物品",os.date("%m/%d %H:%M",canuse_time))
		end
	end
	return true
end

function citem:afteruse(player,target,num)
	local itemtype = self.type
	local itemdata = getitemdata(itemtype)
	if itemdata.usecnt_perday and itemdata.usecnt_perday > 0 then
		local key = string.format("itemusecnt.%s",itemtype)
		player.today:add(key,1)
	end
end

-- 默认对目标使用时消耗的数量
function citem:getuseitem(target)
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
		net.msg.S2C.notify(player.pid,language.format("物品数量不足#<R>#个",num))
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
	local itemdata = getitemdata(self.type)
	return itemdata[what]
end

function __hotfix(oldmod)
	-- 重新初始化注册的使用函数
	hotfix.hotfix("gamelogic.item.use.drag")
end

return citem
