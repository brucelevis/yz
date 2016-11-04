-- 手气红包
credpacket = class("credpacket",{
	GOT_SUCC = 0,		-- 领取成功
	IS_GOT = 1,			-- 已经领取过了
	NO_MORE = 2,		-- 没有更多红包
})

function credpacket:init(conf)
	self.id = conf.id
	self.type = assert(conf.type)
	self.owner = assert(conf.owner)
	self.owner_name = assert(conf.owner_name)
	self.restype = conf.restype or RESTYPE.COIN
	self.money = assert(conf.money)
	self.leftmoney = self.money
	self.num = assert(conf.num)
	self.leftnum = self.num
	-- 单次领取的最高金额
	self.maxmoney_per_get = math.floor(self.money/2)
	self.createtime = os.time()
	self.lifetime = 900
	self.ranks = cranks.new("redpacket",{"pid"},{"money"},{desc=true})
end

function credpacket:pack()
	return {
		id = self.id,
		type = self.type,
		restype = self.restype,
		money = self.money,
		leftmoney = self.leftmoney,
		num = self.num,
		leftnum = self.leftnum,
	}
end

function credpacket:isgot(pid)
	return self.ranks:get(pid)
end

function credpacket:randmoney()
	local money = math.min(self.leftmoney,self.maxmoney_per_get)
	if self.leftnum == 1 then
		return self.leftmoney
	else
		return math.random(1,money)
	end
end

-- 拼手气
-- player:{pid=xxx,name=xxx}
function credpacket:spell_luck(player)
	local pid = player.pid
	local name = player.name
	if self:isgot(pid) then
		return credpacket.IS_GOT
	end
	if self.leftnum <= 0 then
		return credpacket.NO_MORE
	end
	local money = self:randmoney()
	local rank = {
		pid = pid,
		money = money,
		name = name,
	}
	self.ranks:add(rank)
	self.leftmoney = self.leftmoney - money
	self.leftnum = self.leftnum - 1
	return credpacket.GOT_SUCC,rank,self.restype
end

return credpacket
