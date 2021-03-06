return {
	p = "navigation",
	si = 7100, --[7100,7200)
	src = [[

.ActivityType {
	hid 0 : integer
	progress 1 : integer #活动进度
	status 2 : integer #当前状态，0.时间未到 1.可前往 2.可领取 3.已完成
}

# 全量更新活动导航数据
navigation_sendactivitydata 7100 {
	request {
		base 0 : basetype
		activities 1 : *ActivityType
		liveness 2 : integer
		livenessawarded 3 : *integer
	}
}

# 活动数据更新标记
navigation_needupdate 7101 {
	request {
		base 0 : basetype
	}
}

# 活动按钮红点显示
navigation_showredpoint 7102 {
	request {
		baes 0 : basetype
	}
}

]]
}
