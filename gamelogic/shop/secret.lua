-- 神秘商店(公会商店)

csecretshop = class("csecretshop",cshop)

function csecretshop:init(conf)
	cshop.init(self,conf)
end

function csecretshop:onlogin(player)
	if self.len == 0 then
		self:_refresh("onlogin")
	end
	self:sync_allgoods()
end

function csecretshop:open(player)
	local unionid = player:unionid()
	if not unionid then
		net.msg.S2C.notify(player.pid,language.format("你没有公会"))
		return
	end
	if self.len == 0 then
		self:_refresh("open")
	end
	self:sync_allgoods(player)
end

function csecretshop:_refresh(reason)
	local data = data_1401_SecretShop
	local player = playermgr.getplayer(self.pid)
	if not player then
		return
	end
	local unionid = player:unionid()
	if not unionid then
		return
	end
	local unioninfo = unionaux.getunion(unionid)
	if not unioninfo then
		return
	end
	local shangdian_lv = unioninfo.shangdian_lv
	local pos_ids = {}
	for id,goods in pairs(data) do
		if goods.sumnum ~= 0 and
			goods.group == shangdian_lv and
			player.lv >= goods.playerlv and
			table.find(goods.jobids,player.roletype) then
			if not pos_ids[goods.pos] then
				pos_ids[goods.pos] = {}
			end
			table.insert(pos_ids[goods.pos],id)
		end
	end
	local refresh_num = data_1800_UnionVar.UnionShopRefreshNum[shangdian_lv]
	local goodslst = {}
	for pos,ids in pairs(pos_ids) do
		local id_ratio = {}
		for _,id in pairs(ids) do
			local goods = data[id]
			id_ratio[id] = goods.ratio
		end
		local id = choosekey(id_ratio)
		local goods = data[id]
		table.insert(goodslst,{
			id = id,
			pos = goods.pos,
			itemtype = goods.itemtype,
			num = goods.num,
			sumnum = goods.sumnum,
			price = goods.price,
			restype = goods.restype,
			need_itemtype = goods.need_itemtype,
			need_itemnum = goods.need_itemnum,
			bind = goods.bind == 1 and 1 or nil,
		})
		if #goodslst >= refresh_num then
			break
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
	self:buy(player,goods_id,buynum)
end

function csecretshop:sync_allgoods()
	local goodslst = {}
	for id,goods in pairs(self.objs) do
		table.insert(goodslst,goods)
	end
	sendpackage(self.pid,"shop","allgoods",{
		shopname = self.name,
		goodslst = goodslst,
	})
end

function csecretshop:onbuy(pid,id,buynum)
	assert(self.pid == pid)
	local goods = self:get(id)
	sendpackage(pid,"shop","updategoods",{
		shopname = self.name,
		goods = goods,
	})
end

return csecretshop
