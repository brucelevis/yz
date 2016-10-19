return {
	p = "union",
	si = 7400, --[7400,7500)
	src = [[

# 公告/宗旨更改者
.UnionChangerType {
	time 0 : integer	# 更改时间
	jobid 1 : integer	# 职位ID
	name 2 : string		# 名字
}

.UnionPurposeType {
	changer 0 : UnionChangerType  # 空--无更改者
	msg 1 : string		# 宗旨
}

.UnionNoticeType {
	changer 0 : UnionChangerType  # 空--无更改者
	msg 1 : string		# 公告

}

.UnionType {
	id 0 : integer				# 公会ID
	name 1 : string				# 公会名字
	money 2 : integer			# 公会资金
	purpose 3 : UnionPurposeType		# 公会宗旨
	notice 4 : UnionNoticeType		# 公会公告
	badge 5 : UnionBadgeType	# 公会徽章
	dating_lv 6 : integer		# 大厅等级
	zuofang_lv 7 : integer		# 作坊等级
	jitan_lv 8 : integer		# 祭坛等级
	cangku_lv 9 : integer		# 仓库等级
	yingdi_lv 10 : integer		# 营地等级
	shangdian_lv 11 : integer	# 商店等级
}

# 全量同步一个公会
union_sync_union 7400 {
	request {
		base 0 : basetype
		union 1 : UnionType
	}
}

# 增量更新公会
union_update_union 7401 {
	request {
		base 0 : basetype
		union 1 : UnionType
	}
}

# 申请者列表
union_applyers 7402 {
	request {
		base 0 : basetype
		applyers 1 : *integer
	}
}

# 邀请者列表
union_inviters 7403 {
	request {
		base 0 : basetype
		inviters 1 : *integer
	}
}

# 成员类型
.UnionMemberType {
	pid 0 : integer			# 玩家ID
	jobid 1 : integer		# 职位ID
	offer 2 : integer		# 帮贡
	
}

# 成员列表(收到成员列表后,需要用player_lookresume同步第一页的成员信息)
union_members 7404 {
	request {
		base 0 : basetype
		members 1 : *UnionMemberType
	}
}

# 更新成员信息
union_updatemember 7405 {
	request {
		base 0 : basetype
		member 1 : UnionMemberType
	}
}

# 删除成员
union_delmember 7406 {
	request {
		base 0 : basetype
		pid 1 : integer
	}
}

# 删除若干申请者
union_delapplyer 7407 {
	request {
		base 0 : basetype
		pids 1 : *integer
	}
}

# 删除邀请者
union_delinviter 7408 {
	request {
		base 0 : basetype
		pid 1 : integer
	}
}

# 增加成员
union_addmember 7409 {
	request {
		base 0 : basetype
		member 1 : UnionMemberType
	}
}

# 增加申请者
union_addapplyer 7410 {
	request {
		base 0 : basetype
		applyer 1 : integer
	}
}

.LeaderType {
	pid 0 : integer
	name 1 : string
	lv 2 : integer
	joblv 3 : integer
	roletype 4 : integer
}

.UnionInfoType {
	id 0 : integer	# 公会ID
	name 1 : string # 公会名字
	lv 2 : integer	# 公会等级
	len 3 : integer # 公会人数
	leader 4 : LeaderType
	badge 5 : UnionBadgeType
	purpose 6 : UnionPurposeType
}

# 查看公会的信息
union_look_union 7411 {
	request {
		base 0 : basetype
		unioninfo 1 : UnionInfoType
	}
}

# 浏览的若干公会
union_scan_unions 7412 {
	request {
		base 0 : basetype
		unioninfos 2 : *UnionInfoType
		next_startpos 3 : integer	# 下一页查找开始点,-1:表示没有下一页了
	}
}

# 自身公会信息
union_selfunion 7413 {
	request {
		base 0 : basetype
		unionid 1 : integer
	}
}
]]
}
