return {
	p = "shop",
	si = 7000, --[6900,7000)
	src = [[

shop_buygoods 6900 {
	request {
		base 0 : basetype
		shopname 1 : string		# 商店名:secret--神秘商店
		goods_id 2 : integer	# 商品ID
		num 3 : integer			# 购买数量（不发默认为导表中填的单次购买数量)
	}
}

shop_refresh 6901 {
	request {
		base 0 : basetype
		shopname 1 : string		# 商店名:secret--神秘商店
	}
}

shop_open 6902 {
	request {
		base 0 : basetype
		shopname 1 : string		# 商店名:grocery--杂货店
	}
}

]]
}
