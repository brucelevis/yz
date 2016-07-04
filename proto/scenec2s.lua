return {
	p = "scene",
	si = 2250, -- [2250,3000)
	src = [[

scene_move 2500 {
	request {
		base 0 : basetype
		srcpos 1 : PosType
		dstpos 2 : PosType # 方便其他玩家寻路
		time 3 : integer # 发包时间(优化字段,服务端时间），如果不用，客户端不发
	}
}


#进入一个场景（玩家A进入场景S，服务端会通知所有可以看见他的玩家)
scene_enter 2501 {
	request {
		base 0 : basetype
		sceneid 1 : integer
		pos 2 : PosType
	}
}

# 场景玩家数据服务端都是主动同步的，加此协议只是为了以防万一
# 防止客户端在收到移动包时无此玩家数据
# 查询玩家场景信息
scene_query 2502 {
	request {
		base 0 : basetype
		targetid 1 : integer
	}
}

]]
}
