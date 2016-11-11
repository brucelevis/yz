return {
	p = "playunit",
	si = 7200, --[7200,7300)
	src = [[

# 呼出答题玩法界面(回复用msg.respondanswer协议)
playunit_opendati 7200 {
	request {
		base 0 : basetype
		questionid 1 : integer
		respondid 2 : integer
		cnt 3 : integer			#当前题数
		maxcnt 4 : integer		#总题数
		exceedtime 5 : integer	#答题时间
		npcname 6 : string
		npcshape 7 : integer	#造型
		questionbank 8 : string #题库表名
	}
}

.RedPacketType {
	id 0 : integer				# 红包ID
	type 1 : integer			# 1--世界红包,2--公会红包
	money 2 : integer			# 总金额
	leftmoney 3 : integer		# 剩余总金额
	num 4 : integer				# 红包总数
	leftnum 5 : integer			# 剩余红包数
	restype 6 : integer			# 资源类型ID
	owner 7 : integer			# 拥有者玩家ID
	owner_name 8 : string		# 拥有者名字
	createtime 9 : integer			# 派发时间
}

# 一个红包信息
playunit_redpacket 7201 {
	request {
		base 0 : basetype
		redpacket 1 : RedPacketType
		isshare 2 :	 boolean			# true--分享出来的，其他--新建的红包
	}
}

.RedPacketRankType {
	pid 0 : integer
	pos 1 : integer		# 排名
	name 2 : string
	money 3 : integer
}


# 抢红包结果(发给领取红包的人)
playunit_spell_luck_result 7202 {
	request {
		base 0 : basetype
		state 1 : integer	#0--成功,1--已经领取过,2--没有剩余红包了
		# 以下字段仅当state==0有效
		rank 2 : RedPacketType
		restype 3 : integer   # 资源类型ID
	}
}


# 红包排名信息
playunit_redpacket_ranks 7203 {
	request {
		base 0 : basetype
		ranks 1 : *RedPacketRankType
		restype 2 : integer		# 资源ID类型
	}
}

# 枪红包成功后广播进度
playunit_spell_luck_succ 7204 {
	request {
		base 0 : basetype
		redpacket 1 : RedPacketType
		rank 2 : RedPacketRankType		# 领取红包者的具体信息
	}
}
]]
}
