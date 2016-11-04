return {
	p = "navigation",
	si = 7100, --[7100,7200)
	src = [[

# 请求活动导航数据,打开导航界面时有更新标记才请求否则使用本地缓存，拿到数据后清除标记
navigation_activitydata 7100 {
	request {
		base 0 : basetype
	}
}

# 领取活动完成奖励
navigation_activityaward 7101 {
	request {
		base 0 : basetype
		hid 1 : integer
	}
}

# 领取活跃度奖励
navigation_livenessaward 7102 {
	request {
		base 0 : basetype
		awardid 1 : integer
	}
}

# 查看每日活动进度
navigation_lookstat 7103 {
	request {
		base 0 : basetype
	}
}

]]
}
