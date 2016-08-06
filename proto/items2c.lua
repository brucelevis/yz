return {
	p = "item",
	si = 5500,
	src = [[

# 一次性最多发50个物品(服务端发所有物品时会拆分多个包发）
item_allitem 5500 {
	request {
		base 0 : basetype
		items 1 : *ItemType
	}
}

item_additem 5501 {
	request {
		base 0 : basetype
		item 1 : ItemType
	}
}


item_delitem 5502 {
	request {
		base 0 : basetype
		id 1 : integer
	}
}

# 只会更新变动的属性
item_updateitem 5503 {
	request {
		base 0 : basetype
		item 1 : ItemType
	}
}

# 使用宝图的结果
item_usebaotu_result 5504 {
	request {
		base 0 : basetype
		itemid 3 : integer				# 使用的宝图物品ID
		item  4 : ItemType				# 奖励的物品
		npc 5 : SceneNpcType			# 生成的场景NPC（该字段和item字段互斥，同时只会有一个字段存在)
		posid 6 : integer
		sceneid 7 : integer				# 藏宝图出现的场景ID
		mapid 8 : integer	# 藏宝图所在地图ID
		pos 9 : PosType			#优先使用坐标ID,没有坐标ID再使用mapid和pos
	}
}

# 背包信息(全量更新)
item_bag 5505 {
	request {
		base 0 : basetype
		type 1 : integer			#背包类型:1-- 普通背包，2--时装背包，3--卡片背包
		space 2 : integer			#空间大小
		expandspace 3 : integer		#扩展的空间大小，不发默认为0
	}
}

]]
}

