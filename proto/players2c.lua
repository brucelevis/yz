return {
	p = "player",
	si = 5000, -- [5000,5500)
	src = [[
player_heartbeat 5000 {
	request {
		base 0 : basetype
	}
}

# 玩家资源信息
player_resource 5001 {
	request {
		base 0 : basetype
		gold 1 : integer
		chip 2 : integer
	}
}

# 玩家自身的开关
player_switch 5002 {
	request {
		base 0 : basetype
		gm 1 : boolean			# gm开关:true--是GM，其他--不是GM
		friend 2 : boolean		# 好友系统是否打开;true--打开;其他--不打开
		automatch 3 : boolean	# 组队是否默认自动匹配;true--自动匹配;其他--不自动匹配
	}
}

# 玩家基本数据（等级/角色类型等） -- 上线发送
player_sync 5003 {
	request {
		base 0 : basetype
		roletype 1 : integer  #角色类型(职业类型)
		name 2 : string		  #名字
		lv 3 : integer		  #等级
		exp 4 : integer		  #经验
		viplv 5 : integer	  #viplv
		sex 6 : integer		 #1--男，2--女
		jobzs 7 : integer	 #职业转数
		joblv 8 : integer	 #职业等级
		jobexp 9 : integer	 #职业经验
		qualitypoint 10 : QualityPointType  #素质点信
		huoli 11 : integer	 #活力
		storehp 12 : integer #储备生命
	}
}

# 更新玩家简介(只有变动的属性才更新)
player_update 5004 {
	request {
		base 0 : basetype
		roletype 1 : integer  #角色类型(职业类型)
		name 2 : string		  #名字
		lv 3 : integer		  #等级
		exp 4 : integer		  #经验
		viplv 5 : integer	  #viplv
		sex 6 : integer		 #1--男，2--女
		jobzs 7 : integer	 #职业转数
		joblv 8 : integer	 #职业等级
		jobexp 9 : integer	 #职业经验
		qualitypoint 10 : QualityPointType  #素质点信息
		huoli 11 : integer	 #活力
		storehp 12 : integer #储备生命
	}
}

]]
}
