return {
	p = "item",
	si = 5500,
	src = [[

# 一次性最多发50个物品(服务端发所有物品时会拆分多个包发）
item_allitem 5500 {
	request {
		base 0 : basetype
		items 1 : *ItemType
		type 2 : integer			#背包类型:1-- 普通背包，2--时装背包，3--卡片背包
	}
}

item_additem 5501 {
	request {
		base 0 : basetype
		item 1 : ItemType
		type 2 : integer			#背包类型
	}
}


item_delitem 5502 {
	request {
		base 0 : basetype
		id 1 : integer
		type 2 : integer			#背包类型
	}
}

# 只会更新变动的属性
item_updateitem 5503 {
	request {
		base 0 : basetype
		item 1 : ItemType
		type 2 : integer			#背包类型
	}
}

# 使用宝图的结果
item_usebaotu_result 5504 {
	request {
		base 0 : basetype
		itemid 3 : integer				# 使用的宝图物品ID
		item  4 : ItemType				# 奖励的物品
		npc 5 : SceneNpcType			# 生成的场景NPC（该字段可能和item字段同时出现)
		posid 6 : integer
		sceneid 7 : integer				# 藏宝图出现的场景ID
		mapid 8 : integer	# 藏宝图所在地图ID
		pos 9 : PosType			#优先使用坐标ID,没有坐标ID再使用mapid和pos
		baotuid 10 : integer	# 宝图ID：见data_1100_BaoTu
		inuse 11 : boolean		# true--正在使用中
	}
}

# 背包信息(全量更新)
item_bag 5505 {
	request {
		base 0 : basetype
		type 1 : integer			#背包类型:1-- 普通背包，2--时装背包，3--卡片背包
		space 2 : integer			#空间大小
		sorttype 3 : integer		#排序类型(0--自然排序,1--装备优先,2--材料优先，3--药物优先，4--任务优先)
		beginpos 4 : integer		#背包内开始存放物品的位置
	}
}

# 单个背包所有物品发包结束(方便客户端)
# 发包时序是:item_bag -> all_item -> allitem_end
item_allitem_end 5506 {
	request {
		base 0 : basetype
		type 1 : integer			#背包类型:1-- 普通背包，2--时装背包，3--卡片背包
	}
}

# 精炼增加的属性类型（影响战斗属性)
.RefineAttrType {
	cnt 0 : integer  #精炼次数
	succ_ratio 1 : integer #当前成功概率(若为空，客户端根据次数读导表显示)
}


.EquipPosType {
	id 0 :	integer			#格子ID/格子位置
	refine 1 : RefineAttrType
	cardid 2 : integer		# 插入的卡片ID,0/空--未插入卡片
}

# 所有装备栏格子
item_all_equippos 5507 {
	request {
		base 0 : basetype
		equipposes 1 : *EquipPosType
	}
}

item_update_equippos 5508 {
	request {
		base 0 : basetype
		equippos 1 : EquipPosType
	}
}

# 成功打造装备
item_produceequip_succ 5509 {
	request {
		base 0 : basetype
		itemid 1 : integer	#打造生成的物品ID，服务端保证先发additem协议
	}
}

# 顶替附魔结果
item_replacefumo_res 5510 {
	request {
		base 0 : basetype
		result 1 : boolean
	}
}

]]
}

