return {
	p = "chapter",
	si = 6700, -- [6700,6800)
	src = [[

#关卡类型
.ChapterType {
	chapterid 0 : integer
	star 1 : integer # 星级，支线关卡忽略
	pass 2 : boolean # 通关标识
}

#关卡解锁
chapter_unlock 6700 {
	request {
		base 0 : basetype
		chapterid 1 : integer
	}
}

#关卡数据更新
chapter_update 6701 {
	request {
		base 0 : basetype
		chapter 1 : ChapterType
	}
}

chapter_allchapter 6702 {
	request {
		base 0 : basetype
		chapters 1 : *ChapterType
	}
}

#关卡奖励领取记录
chapter_awardrecord 6703 {
	request {
		base 0 : basetype
		records 1 : *integer # 奖励ID列表
	}
}

#发送解锁条件
chapter_send_unlockcondition 6704 {
	request {
		base 0 : basetype
		chapterid 1 : integer
		needtasks 2 : *integer
	}
}

#剧情回顾中相关的对白表id,transstr为转换字符串用cjson.decode解压后使用
chapter_sendstory 6705 {
	request {
		base 0 : basetype
		taskid 1 : integer
		textids 2 : *integer
		transstr 3 : string
	}
}

]]
}
