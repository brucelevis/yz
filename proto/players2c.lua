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
		silver 2 : integer
		coin 3 : integer
		dexppoint 4 : integer		#双倍经验点
	}
}

# 玩家自身的开关，登录时发送所有数据，游戏中增量更新
player_switch 5002 {
	request {
		base 0 : basetype
		switchs 1 : *SwitchType
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
		usehorncnt 13 : integer # 今日使用喇叭次数
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
		usehorncnt 13 : integer # 今日使用喇叭次数
	}
}

# 充值列表
player_chongzhilist 5005 {
	request {
		base 0 : basetype
		seen 1 : *integer		# 可见的充值项ID列表(见data_1401_ChongZhi)
	}
}

# 显示玩家简介
player_syncresumes 5006 {
	request {
		base 0 : basetype
		resumes 1 : *ResumeType
	}
}

# 增量更新玩家简介
player_updateresume 5007 {
	request {
		base 0 : basetype
		resume 1 : ResumeType
	}
}

# 按pid/name搜索简介的结果
player_searchresume_result 5008 {
	request {
		base 0 : basetype
		resumes 1 : *ResumeType
	}
}
]]
}
