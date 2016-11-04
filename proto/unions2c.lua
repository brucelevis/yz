return {
	p = "union",
	si = 7400, --[7400,8000)
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

.UnionLeaderType {
	pid 0 : integer
	name 1 : string
	lv 2 : integer
	jobid 3 : integer
	roletype 4 : integer
	joblv 5 : integer
}

.UnionType {
	id 0 : integer				# 公会ID
	name 1 : string				# 公会名字
	money 2 : integer			# 公会资金
	purpose 3 : UnionPurposeType		# 公会宗旨
	notice 4 : UnionNoticeType		# 公会公告
	badge 5 : UnionBadgeType	# 公会徽章
	dating_lv 6 : integer		# 大厅等级(公会等级)
	zuofang_lv 7 : integer		# 作坊等级
	jitan_lv 8 : integer		# 祭坛等级
	cangku_lv 9 : integer		# 仓库等级
	yingdi_lv 10 : integer		# 营地等级
	shangdian_lv 11 : integer	# 商店等级
	# 下面属性update_union不会更新
	len 12 : integer			# 公会人数
	leader 13 : UnionLeaderType	# 会长信息
	fu_leaders 14 : *UnionLeaderType # 副会长信息
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
	sum_offer 3 : integer	# 历史贡献度
	week_offer 4 : integer	# 本周贡献度
	week_warcnt 5 : integer # 本周参与公会战次数
	banspeak 6 : integer	# 禁言过期时间,空/0/<=当前时间--未被禁言
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

# 查看公会的信息
union_look_union 7411 {
	request {
		base 0 : basetype
		unioninfo 1 : UnionType
	}
}

# 浏览的若干公会
union_scan_unions 7412 {
	request {
		base 0 : basetype
		unioninfos 2 : *UnionType
		next_startpos 3 : integer	# 下一页查找开始点,-1:表示没有下一页了
	}
}

# 自身公会信息
union_selfunion 7413 {
	request {
		base 0 : basetype
		unionid 1 : integer   # 空--无公会，否则--公会ID
		jobid 2 : integer	  # 自身职位
	}
}

.UnionSkillType {
	skillid 0 : integer		# 技能ID，见data_1800_UnionSkill
	lv 1 : integer			# 技能等级
}

# 公会技能信息(上线发送)
union_sync_skills 7414 {
	request {
		base 0 : basetype
		skills 1 : UnionSkillType
	}
}

# 更新公会技能
union_update_skill 7415 {
	request {
		base 0 : basetype
		skill 1 : UnionSkillType
	}
}

.UnionFinishCntType {
	name 0 : string		# 任务名
	cnt 1 : integer		# 完成次数
}

# 工会每周福利信息
union_weekfuli 7416 {
	request {
		base 0 : basetype
		finishcnt 1 : *UnionFinishCntType
		isbonus 2 : boolean		# true--已领取奖励，其他--未领取
	}
}

# 搜索的公会结果
union_search_union_result 7417 {
	request {
		base 0 : basetype
		unions 1 : *UnionType
	}
}

# 仓库:增加物品
union_additem 7418 {
	request {
		base 0 : basetype
		item 1 : ItemType
	}
}

# 仓库: 删除物品
union_delitem 7419 {
	request {
		base 0 : basetype
		uuid 1 : string	# 删除的仓库物品ID(==ItemType.uuid)
	}
}

# 仓库: 更新物品
union_updateitem 7420 {
	request {
		base 0 : basetype
		item 1 : ItemType
	}
}

# 仓库: 所有物品(打开仓库后同步)
union_allitem 7421 {
	request {
		base 0 : basetype
		items 1 : *ItemType
	}
}

.UnionCollectCardSessionType {
	id 0 : integer			# 会话ID
	cardtype 1 : integer	# 收集的卡片类型
	num 2 : integer			# 收集的卡片数量
	has_donate 3 : integer	# 已捐献数量
	createtime 4 : integer	# 创建时间
	lifetime 5 : integer	# 持续时间
	creater 6 : ResumeType # 集卡者信息(这里的简介可能只会发pid,name等)
}

# 所有的收集卡片信息(openui,type=jika时发给客户端)
union_all_collect_card 7422 {
	request {
		base 0 : basetype
		sessions 1 : *UnionCollectCardSessionType
	}
}

# 单个收集卡片信息
union_collect_card 7423 {
	request {
		base 0 : basetype
		session 1 : UnionCollectCardSessionType
	}
}

.UnionCollectItemTaskType {
	taskid 0 : integer		# 任务ID
	itemtype 1 : integer	# 物品类型
	neednum 2 : integer     # 需求物品数量
	hasnum 3 : integer		# 已有物品数量
	donater 4 : ResumeType  # 捐献者信息(这里简介只会发pid,name信息),空--无捐献者
	isbonus 5 : boolean		# true--已领取奖励
	inhelp 6 : boolean		# true--求助中
}

# 公会收集：求助任务
union_collectitem_askfor_help_task 7424 {
	request {
		base 0 : basetype
		pid 1 : integer			# 求助者玩家ID
		task 2 : UnionCollectItemTaskType  # 任务信息
	}
}

# 公会收集: 所有任务(openui#collectitem时发送)
union_collectitem_alltask 7425 {
	request {
		base 0 :  basetype
		tasks 1 : *UnionCollectItemTaskType
	}
}

# 公会收集:更新单个任务
union_collectitem_updatetask 7426 {
	request {
		base 0 : basetype
		task 1 : UnionCollectItemTaskType
	}
}
]]
}
