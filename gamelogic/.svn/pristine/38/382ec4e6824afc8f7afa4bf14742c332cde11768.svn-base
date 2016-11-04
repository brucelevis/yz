cshop = class("cshop",ccontainer)

-- conf: {pid=xxx,name=xxx}
function cshop:init(conf)
	ccontainer.init(self,conf)
	self.restype = conf.restype
end

-- 生成商品
-- 商品格式:{id=商品ID,itemtype=物品类型,num=单次购买的数量,price=单个商品价格,sumnum=总存量,restype=资源类型,bind=物品是否绑定}
-- 总存量sumnum < 0 表示该商品库存量无限
function cshop:gen_goods(goodslst)
	for i,goods in ipairs(goodslst) do
		assert(goods.itemtype)
		assert(goods.price)
		assert(goods.num)
		goods.sumnum = goods.sumnum or goods.num
		goods.leftnum = goods.leftnum or goods.sumnum
		local id = goods.id or i
		self:add(goods,id)
	end
end

function cshop:canbuy(player,goods_id,buynum)
	local goods = self:get(goods_id)
	if not goods then
		return false,language.format("非法商品ID")
	end
	buynum = buynum or goods.num
	assert(buynum > 0)
	if goods.sumnum >= 0 and buynum > goods.leftnum then
		return false,language.format("商品存量不足{1}个",buynum)
	end
	if buynum % goods.num ~= 0 then
		return false,language.format("该商品单次出售数量为{1}个",goods.num)
	end
	return true
end

function cshop:buy(player,goods_id,buynum)
	local isglobalshop = self.pid == 0 and true or false
	self._buy(player.pid,goods_id,buynum,self.name)
end

-- 仅为了闭包不引用对象
function cshop.getself(pid,name)
	local player = playermgr.getplayer(pid)
	if player.shopdb[name] then
		return player.shopdb[name]
	end
	return globalmgr.shop[name]
end

function cshop._buy(pid,goods_id,buynum,shopname,iscallback)
	--print("cshop._buy",pid,goods_id,buynum,shopname,iscallback)
	local player = playermgr.getplayer(pid)
	if not player then
		return
	end
	local self = cshop.getself(pid,shopname)
	local isok,errmsg = self:canbuy(player,goods_id,buynum)
	if not isok then
		net.msg.S2C.notify(pid,errmsg)
		return
	end
	local goods = self:get(goods_id)
	if not goods then
		return
	end
	local reason = string.format("shop_%s.buy",self.name)
	if not iscallback then
		local resname = getresname(goods.restype)
		local resval = buynum * goods.price
		local items
		if goods.need_itemtype and goods.need_itemnum > 0 then
			items = {
				{type=goods.need_itemtype,num=goods.need_itemnum * buynum /goods.num},
			}
		end
		player:oncostres({
			[resname] = resval,
			items = items,
		},reason,true,function (uid)
			cshop._buy(uid,goods_id,buynum,shopname,true)
		end)
		return
	end
	buynum = buynum or goods.num
	if goods.sumnum >= 0 then
		self:update(goods.id,{
			leftnum = goods.leftnum - buynum,
		})
	end
	player:additembytype(goods.itemtype,buynum,goods.bind,reason)
	net.msg.S2C.notify(pid,language.format("获得#<II{1}>#{2}+{3}",goods.itemtype,itemaux.itemlink(goods.itemtype),buynum))
	if self.onbuy then
		self:onbuy(pid,goods_id,buynum)
	end
	return true
end

function cshop:_refresh(data,reason)
	local group_ids = {}
	for id,v in pairs(data) do
		if v.sumnum ~= 0 then
			local group = v.group
			if not group_ids[group] then
				group_ids[group] = {}
			end
			table.insert(group_ids[group],id)
		end
	end
	local pos_ids = {}
	for group,ids in pairs(group_ids) do
		if group == 0 then
			for i,id in pairs(ids) do
				local data = data[id]
				local pos = data.pos
				if not pos_ids[pos] then
					pos_ids[pos] = {}
				end
				table.insert(pos_ids[pos],id)
			end
		else
			local id = randlist(ids)
			local data = data[id]
			local pos = data.pos
			if not pos_ids[pos] then
				pos_ids[pos] = {}
			end
			table.insert(pos_ids[pos],id)
		end
	end
	local goodslst = {}
	for pos,ids in pairs(pos_ids) do
		local id_ratio = {}
		for _,id in pairs(ids) do
			local data = data[id]
			id_ratio[id] = data.ratio
		end
		local id = choosekey(id_ratio)
		local data = data[id]
		table.insert(goodslst,{
			id = id,
			pos = data.pos,
			itemtype = data.itemtype,
			num = data.num,
			sumnum = data.sumnum,
			price = data.price,
			restype = data.restype,
			need_itemtype = data.need_itemtype,
			need_itemnum = data.need_itemnum,
			bind = data.bind == 1 and 1 or nil,
		})
	end
	logger.log("info","shop",format("[%s] [refresh] goodslst=%s reason=%s",self.name,goodslst,reason))
	self:clear()
	self:gen_goods(goodslst)
end

return cshop
