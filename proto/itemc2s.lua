return {
	p = "item",
	si = 5500, -- [5500,6000)
	src = [[

item_useitem 5500 {
	request {
		base 0 : basetype
		itemid 1 : integer		#物品ID
		targetid 2 : integer	#目标ID，不发默认对主角使用
		num 3 : integer			#使用数量，不发由服务端决定数量
	}
}

item_sellitem 5501 {
	request {
		base 0 : basetype
		itemid 1 : integer
		num 2 : integer		#出售数量，不发默认出售1个
	}
}

item_produceitem 5502 {
	request {
		base 0 : basetype
		itemtype 1 : integer	#物品类型
		num 2 : integer			#制造数量，不发默认制造1个
	}
}

# 销毁物品，如某些无法出售的物品，为了防止占用格子，主动销毁
item_destroyitem 5503 {
	request {
		base 0 : basetype
		itemid 1 : integer
	}
}

#将from_itemid物品合并到to_itemid物品
item_mergeto 5504 {
	request {
		base 0 : basetype
		from_itemid 1 : integer
		to_itemid 2 : integer
		num 3 : integer			#合并过去的数量，不发尝试合并整个from_itemid物品
	}
}

# 卸下装备
item_wield 5505 {
	request {
		base 0 : basetype
		itemid 1 : integer
	}
}

# 装备
item_unwield 5506 {
	request {
		base 0 : basetype
		itemid 1 : integer
	}
}

#变更套装suitno
item_changesuit 5507 {
	request {
		base 0 : basetype
		suitno 1 : integer 		#1--套装1,2--套装2,3--套装3
	}
}

# 设置套装
item_setsuit 5508 {
	request {
		base 0 : basetype
		suitno 1 : integer
	}
}

# 拾取物品
item_pickitem 5509 {
	request {
		base 0 : basetype
		itemid 1 : integer
		sceneid 2 : integer
	}
}

# 精炼装备
item_refineequip 5511 {
	request {
		base 0 : basetype
		itemid 1 : integer
	}
}

# 顶替附魔属性
item_replacefumo 5512 {
	request {
		base 0 : basetype
		from_itemid 1 : integer
		to_itemid 2 : integer
		attrtype 3 : string			# 附魔属性类型:见ItemFumoAttrType
	}
}


# 嵌入/插入卡片
item_insertcard 5514 {
	request {
		base 0 : basetype
		itemid 1 : integer
		cardid 2 : integer
	}
}

# 升级卡片
item_upgradecard 5515 {
	request {
		base 0 : basetype
		cardid 1 : integer
	}
}

# 设置背包排序方式
item_sortbag 5517 {
	request {
		base 0 : basetype
		bagtype 1 : integer			#背包类型:1-- 普通背包，2--时装背包，3--卡片背包

		sorttype 4 : integer		#排序类型(0--自然排序,1--装备优先,2--材料优先，3--药物优先，4--任务优先)
	}
}

# 扩展背包格子
item_expandspace 5518 {
	request {
		base 0 : basetype
		bagtype 1 : integer			#背包类型:1-- 普通背包，2--时装背包，3--卡片背包
	}
}

# 取消挖宝
item_cancel_baotu 5519 {
	request {
		base 0 : basetype
		type 1 : string			# baotu--普通宝图，gaoji_baotu--高级宝图
	}
}

# 卸下卡片
item_takeout_card 5520 {
	request {
		base 0 : basetype
		pos 1 : integer			# 装备格位置
	}
}
]]
}
