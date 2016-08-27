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
		sorttype 4 : integer		#排序类型(0--自然排序,1--装备优先,2--材料优先，3--药物优先，4--任务优先)
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
	maxhp 0 : integer  #血量上限
	maxmp 1 : integer  #魔法上限
	atk 2 : integer #攻击力
	latk 3 : integer #远程攻击力
	def 4 : integer  #防御
	sp 5 : integer  #速度
	fsp 6 : integer #法术攻击速度(咏唱速度)
	dfsp 7 : integer #咏唱延迟(delay 法术攻击速度)
	fdef 8 : integer #法术防御
	fsqd 9 : integer #法术强度
	hpr 10 : integer #生命值回复
	mpr 11 : integer #魔法值回复
	jzfs 12 : integer #近战反伤
	ycfs 13 : integer #远程反伤
	mffs 14 : integer #魔法反伤
	hjct 15 : integer #护甲穿透
	fsct 16 : integer #法术穿透
	bt 17 : integer #霸体
	xx 18 : integer #吸血
	fsxx 19 : integer #法术吸血

	cnt 20 : integer  #精炼次数
	succ_ratio 21 : integer #当前成功概率(若为空，客户端根据次数读导表显示)
}


.EquipPosType {
	id 0 :	integer			#格子ID/格子位置
	refine 1 : RefineAttrType
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
]]
}

