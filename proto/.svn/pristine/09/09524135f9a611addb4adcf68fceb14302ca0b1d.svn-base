return {
	p = "scene",
	si = 2500, -- [2500,3000)
	src = [[

scene_move 2500 {  #移动
	request {
		base 0 : basetype
		pid 1 : integer
		srcpos 2 : PosType
		dstpos 3 : PosType
		time 4 : integer   #移动者发包时间(服务端时间)
	}
}

# 新增一个玩家
scene_addplayer 2501 {
	request {
		base 0 : basetype
		pid 1 : integer
		name 2 : string
		lv 3 : integer
		roletype 4 : integer
		teamid 5 : integer
		teamstate 6 : integer
		warid 7 : integer
		pos 8 : PosType
		sceneid 9 : integer
		mapid 10 : integer
	}
}

#删除一个玩家
scene_delplayer 2502 {
	request {
		base 0 : basetype
		pid 1 : integer
	}
}

# 更新玩家场景信息（不包括位置)
scene_update 2503 {
	request {
		base 0 : basetype
		pid 1 : integer
		name 2 : string
		lv 3 : integer
		roletype 4 : integer
		teamid 5 : integer
		teamstate 6 : integer
		warid 7 : integer
	}
}

# 进入场景(发给自己的),格式同addplayer
scene_enter 2504 {
	request {
		base 0 : basetype
		pid 1 : integer
		name 2 : string
		lv 3 : integer
		roletype 4 : integer
		teamid 5 : integer
		teamstate 6 : integer
		warid 7 : integer
		pos 8 : PosType
		sceneid 9 : integer
		mapid 10 : integer
	}
}

#离开场景(发给自己的),格式同delplayer
scene_leave 2505 {
	request {
		base 0 : basetype
		pid 1 : integer
	}
}

# 进入场景时，同步本场景所有npc
scene_allnpc 2506 {
	request {
		base 0 : basetype
		npcs 1 : *SceneNpcType
	}
}

scene_addnpc 2507 {
	request {
		base 0 : basetype
		npc 1 : SceneNpcType
	}
}

scene_delnpc 2508 {
	request {
		base 0 : basetype
		id 1 : integer			#npcid
		sceneid 2 : integer		#场景ID（可能无用)
	}
}

# 更新npc(只更新npc的部分/全部属性),格式同:addnpc
scene_updatenpc 2509 {
	request {
		base 0 : basetype
		npc 1 : SceneNpcType
	}
}

# 进入场景时，同步本场景所有item
scene_allitem 2510 {
	request {
		base 0 : basetype
		items 1 : *SceneItemType
	}

}

scene_additem 2511 {
	request {
		base 0 : basetype
		item 1 : SceneItemType
	}
}

scene_delitem 2512 {
	request {
		base 0 : basetype
		id 1 : integer
		sceneid 2 : integer		#场景ID(可能无用)
	}
}

# 更新物品(可能没太大用),格式同:additem
scene_updateitem 2513 {
	request {
		base 0 : basetype
		item 1 : SceneItemType
	}
}
]]
}
