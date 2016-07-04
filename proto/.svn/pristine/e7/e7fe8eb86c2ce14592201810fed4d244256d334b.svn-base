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

item_wield 5505 {
	request {
		base 0 : basetype
		itemid 1 : integer
	}
}

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
		suitno 1 : integer
	}
}

item_setsuit 5508 {
	request {
		base 0 : basetype
		suitno 1 : integer
	}
}

item_pickitem 5509 {
	request {
		base 0 : basetype
		itemid 1 : integer
		sceneid 2 : integer
	}
}

]]
}
