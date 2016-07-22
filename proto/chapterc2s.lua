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
]]
}
