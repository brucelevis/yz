return {
	p = "union",
	si = 7400, --[7400,7500)
	src = [[

# 创建公会
union_createunion 7400 {
	request {
		base 0 : basetype
		name 1 : string		# 公会名
		purpose 2 : string  # 宗旨
		badge 3 : UnionBadgeType # 公会徽章
	}
}

# 退位让贤
union_changeleader 7401 {
	request {
		base 0 : basetype
		pid 1 : integer			# 副会长玩家ID
	}
}

# 公会改名
union_changename 7402 {
	request {
		base 0 : basetype
		name 1 : string		# 新名
	}
}

# 公会改变徽章
union_changebadge 7403 {
	request {
		base 0 : basetype
		badge 1 : UnionBadgeType  # 新的公会徽章
	}
}

# 升级公会建筑
union_upgradebuild 7404 {
	request {
		base 0 : basetype
		type 1 : string			# dating--大厅,zuofang--作坊,jitan--祭坛,cangku--仓库，yingdi--营地,shangdian--商店
	}
}

# 改变职位
union_changejob 7405 {
	request {
		base 0 : basetype
		pid 1 : integer			# 接受职位玩家ID
		jobid 2 : integer		# 职位ID
	}
}

# 申请加入公会
union_apply_join 7406 {
	request {
		base 0 : basetype
		unionid 1 : integer			# 公会ID
	}
}

# 邀请加入公会
union_invite_join 7407 {
	request {
		base 0 : basetype
		pid 1 :	 integer			# 被邀请者玩家ID
	}
}

# 批准/同意加入公会
union_agree_join 7408 {
	request {
		base 0 : basetype
		pid 1 : integer				# 申请者玩家ID
	}
}

# 不同意加入公会(删除申请者)
union_disagree_join 7409 {
	request {
		base 0 : basetype
		pid 1 : integer			  # 申请者玩家ID(空--清空申请列表)
	}
}

# 踢出成员
union_kick_member 7410 {
	request {
		base 0 : basetype
		pid 1 : integer			# 玩家ID
	}
}

# 编辑宗旨
union_edit_purpose 7411 {
	request {
		base 0 : basetype
		purpose 1 : string	# 新的宗旨
	}
}

# 发布宗旨
union_publish_purpose 7412 {
	request {
		base 0 : basetype
	}
}

# 编辑公告
union_edit_notice 7413 {
	request {
		base 0 : basetype
		notice 1 : string		# 新的公告
	}
}

# 发布公告
union_publish_notice 7414 {
	request {
		base 0 : basetype
	}
}

# 打开界面
union_openui 7415 {
	request {
		base 0 : basetype
		# union--公会,applyer--申请者列表,inviter--邀请者列表,member--成员列表,huodong--公会活动,fuli--公会福利,info--公会信息
		type 1 : string
	}
}

# 关闭界面
union_closeui 7416 {
	request {
		base 0 : basetype
		# union--公会,其他界面的关闭无须告知服务端
		type 1 : string
	}
}

# 退出公会
union_quit 7417 {
	request {
		base 0 : basetype
	}
}

# 查看公会
union_look_union 7418 {
	request {
		base 0 : basetype
		unionid 1 : integer
	}
}

# 浏览公会列表（按页查看)
union_scan_unions 7419 {
	request {
		base 0 : basetype
		# 查询startpos开始（包含startpos）后len个公会
		startpos 1 : integer
		len 2 : integer
	}
}
]]
}
