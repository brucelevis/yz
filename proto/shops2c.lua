return {
	p = "shop",
	si = 6900, --[6900,7000)
	src = [[

.ShopGoodsType {
	id 0 : integer				# 商品ID
	itemtype 1 : integer		# 物品类型
	num 2 : integer				# 单词购买数量
	bind 3 : integer			# 是否绑定: 0/空--不绑定 其他--绑定
	leftnum 4 : integer			# 物品剩余数量(==0--售罄,<0--无限库存)
	restype 5 : integer			# 消耗的资源类型，资源类型分类见导表：资源ID分类.xls

	price 6 : integer			# 当前价格
}

shop_allgoods 6900 {
	request {
		base 0 : basetype
		shopname 1 : string		# 商店名:secret--神秘商店
		exceedtime 2 : integer  # 过期时间(空--表示永久商店)
		goodslst 3 : *ShopGoodsType
	}
}

# 增量更新（只会更新变动的属性，如：购买商品后剩余数量变动)
shop_updategoods 6901 {
	request {
		base 0 : basetype
		shopname 1 : string		# 商店名:secret--神秘商店
		goods 2 : ShopGoodsType
	}
}

# 删除商店（部分动态带生命期，过期后会自动删除)
shop_delshop 6902 {
	request {
		base 0 : basetype
		shopname 1 : string		# 商店名:secret--神秘商店
	}
}
]]
}
