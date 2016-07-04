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

]]
}

