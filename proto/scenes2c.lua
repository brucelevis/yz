return {
	p = "scene",
	si = 2500, -- [2500,3000)
	src = [[

scene_move 2500 {  #移动
	request {
		base 0 : basetype
		pid 1 : integer
		srcpos 2 : PosType		#移动起点位置
		dstpos 3 : PosType		#移动到的目标位置
		time 4 : integer		#移动者发包时间(服务端时间)
	}
}

# 新增一个玩家
scene_addplayer 2501 {
	request {
		base 0 : basetype
		pid 1 : integer				#玩家ID
		name 2 : string
		lv 3 : integer
		roletype 4 : integer		#角色类型/职业ID
		teamid 5 : integer			#队伍ID
		teamstate 6 : integer		#队伍状态:0--无队伍，1--队长，2--跟随队员，3--暂离队员，4--离线队员
		warid 7 : integer			#战斗ID,不等于0/不为空，表示处于战斗状态
		pos 8 : PosType
		sceneid 9 : integer
		mapid 10 : integer
		sex 11 : integer			#1--男，2--女
		jobzs 12 : integer			#职业转数
		joblv 13 : integer			#职业等级
		weapontype 14 : integer		#武器类型(0/空--无)
		shieldtype 15 : integer		#盾牌类型(0/空--无)
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
		pid 1 : integer				#玩家ID
		name 2 : string
		lv 3 : integer
		roletype 4 : integer		#角色类型/职业ID
		teamid 5 : integer			#队伍ID
		teamstate 6 : integer		#队伍状态:0--无队伍，1--队长，2--跟随队员，3--暂离队员，4--离线队员
		warid 7 : integer			#战斗ID,不等于0/不为空，表示处于战斗状态
		sex 8 : integer			#1--男，2--女
		jobzs 9 : integer			#职业转数
		joblv 10 : integer			#职业等级
		weapontype 11 : integer		#武器类型(0/空--无)
		shieldtype 12 : integer		#盾牌类型(0/空--无)
	}
}

# 进入场景(发给自己的),收到该协议后才允许进入场景
scene_enter 2504 {
	request {
		base 0 : basetype
		pid 1 : integer				#玩家ID
		sceneid 2 : integer			#场景ID
		mapid 3 : integer			#地图ID
		pos 4 : PosType				#坐标
		mapname 5 : string			#地图名字
	}
}

#离开场景(发给自己的),收到该协议后才允许离开场景
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

# 当玩家移动跨度太大时（可能客户端移动作弊），服务端发一个将其强制拉回原来坐标的协议，即下面协议
scene_fixpos 2514 {
	request {
		base 0 : basetype
		pos 1 : PosType		#拉回到的坐标点
	}
}
]]
}
