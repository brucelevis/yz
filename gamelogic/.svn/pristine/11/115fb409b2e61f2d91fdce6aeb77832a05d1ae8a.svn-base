-- 神秘商店

csecretshop = class("csecretshop",cshop)

function csecretshop:init(conf)
	cshop.init(self,conf)
	self.refresh_num = conf.refresh_num or 10 -- 刷出商品数量
end

function csecretshop:onlogin(player)
	if self.len == 0 then
		self:_refresh("onlogin")
	end
	self:sync_allgoods()
end

function csecretshop:_refresh(reason)
	local group_ids = {}
	for id,v in pairs(data_1401_SecretShop) do
		if v.sumnum ~= 0 then	 -- 0表示不开放该商品
			local group = v.group
			if not group_ids[group] then
				group_ids[group] = {}
			end
			table.insert(group_ids[group],id)
		end
	end
	--pprintf("%s\n",group_ids)
	local id_ratio = {}
	for group,ids in pairs(group_ids) do
		local id = randlist(ids)
		local data = data_1401_SecretShop[id]
		id_ratio[id] = data.ratio
	end

	--pprintf("%s\n",id_ratio)
	local show_id = {}
	local goodslst = {}
	local num = math.min(self.refresh_num,table.count(id_ratio))
	for i = 1,num do
		local id = choosekey(id_ratio,function (id,ratio)
			if show_id[id] then
				return 0
			end
			return ratio
		end)
		if not show_id[id] then
			show_id[id] = true
			local data = data_1401_SecretShop[id]
			table.insert(goodslst,{
				id = id,
				itemtype = data.itemtype,
				num = data.num,
				sumnum = data.sumnum,
				price = data.price,
				restype = data.restype,
				bind = data.bind == 1 and 1 or nil,
			})
		end
	end
	logger.log("info","shop",format("[%s] [refresh] goodslst=%s reason=%s",self.name,goodslst,reason))
	self:clear()
	self:gen_goods(goodslst)
end

function csecretshop:refresh()
	-- check resouce
	self:_refresh("refresh_bygold")
	self:sync_allgoods()
end

function csecretshop:buygoods(player,goods_id,buynum)
	if self.pid ~= 0 and player.pid ~= self.pid then
		return
	end
	-- dosomething()
	self:buy(player,goods_id,buynum)
end

function csecretshop:pack_goods(goods)
	return goods
end

function csecretshop:sync_allgoods()
	local goodslst = {}
	for id,goods in pairs(self.objs) do
		table.insert(goodslst,self:pack_goods(goods))
	end
	sendpackage(self.pid,"shop","allgoods",{
		shopname = self.name,
		goodslst = goodslst,
	})
end

function csecretshop:onupdate(id,attrs)
	attrs.id = id
	sendpackage(self.pid,"shop","updategoods",{
		shopname = self.name,
		goods = attrs,
	})
end

return csecretshop
