return {
	p = "chapter",
	si = 6700, --[6700,6800)
	src = [[

#关卡前往目标地后发起战斗
chapter_raisewar 6700 {
	request {
		base 0 : basetype
		chapterid 1 : integer #关卡ID
	}
}

#主线关卡领取星级奖励
chapter_getaward 6701 {
	request {
		base 0 : basetype
		awardid 1 : integer #奖励ID
	}
}

#获取解锁条件
chapter_get_unlockcondition 6702 {
	request {
		base 0 : basetype
		chapterid 1 : integer #关卡ID
	}
}

#剧情回顾
chapter_reviewstory 6703 {
	request {
		base 0 : basetype
		line 1 : integer #1-主线 2-支线
		section 2 : integer #章节
	}
}

]]
}
