return {
	p = "inittypecommon",
	si = 0,
	src = [[
.RoleType {
	roleid 0 : integer
	roletype 1 : integer
	name 2 : string
	lv 3 : integer
}

.ResOrItemType {
	type 0 : integer #资源类型/物品类型
	num 1 : integer
}

.ItemType {
	id 0 : integer		#物品ID，对于邮件附件中的物品，ID为空
	type 1 : integer	#物品类型
	num 2 : integer		#物品数量
	bind 3 : integer	#0/空--未绑定，1--绑定
	createtime 4 : integer #创建时间，空表示无此属性
	pos 5 : integer #背包位置
}

.PetType {
	id 0 : integer		#宠物ID，对于邮件附件中的物品，ID为空
	type 1 : integer	#宠物类型
	createtime 2 : integer  #创建时间，空表示无此属性
}

.AttachType {
	items 0 : *ItemType
	pets 1 : *PetType
	gold 2 : integer
	silver 3 : integer
	coin 4 : integer
}

.MailType {
	mailid 0 : integer
	sendtime 1 : integer
	author 2 : string
	title 3 : string
	content 4 : string
	attach 5 : AttachType
	readtime 6 : integer
	srcid 7 : integer #邮件来源ID（0--系统，其他--玩家ID)
	pid 8 : integer  # 邮件拥有者ID(可能没用)
}

.PosType {
	x 0 : integer
	y 1 : integer
	dir 2 : integer
}

# 消息发言者玩家简介信息
.SendMsgPlayerType {
	pid 0 : integer
	name 1 : string
	lv 2 : integer
	roletype 3 : integer
}

.MemberType {
	pid 0 : integer
	name 1 : string
	lv 2 : integer
	roletype 3 : integer
	# 1--captain, 2--follow member,3--leave member,4--offline member
	teamstate 4 : integer
}

.TeamType {
	teamid 0 : integer
	target 1 : integer
	# 组队等级
	lv 2 : integer
	members 3 : *MemberType
	automatch 4 : boolean
}

.TaskType {
	taskid 0 : integer
	state 1 : integer #1--接受状态，2--完成状态
	data 2 : string #需要用json解包
}

.PublishTeamType {
	target 0 : integer
	lv 1 : integer
	time 2 : integer # 发布时间
	captain 3 : MemberType  # 队长信息
}

.SceneItemType {
	id 0 :	 integer		#物品ID(拾取物品时和服务端通信的ID)
	type 1 : integer		#物品类型
	sceneid 2 : integer		#场景ID(可能无用)
	pos 3 : PosType			#坐标
	exceedtime 4 : integer	#过期时间
	num 5 : integer			#物品数量
	bind 6 : integer		#绑定标志(0/空--未绑定，其他--绑定)
}

.SceneNpcType {
	id 0 : integer			#npcid
	type 1 : integer		#怪物类型
	name 2 : string			#怪物名字
	sceneid 3 : integer     #场景ID（可能无用)
	pos 4 : PosType			#坐标
	exceedtime 5 : integer  #过期时间
	cur_warcnt 6 : integer  #当前正在进行的战斗数(>0:战斗状态,==0:非战斗状态)
}

.PropertyType {
	name 0 : string
	type 1 : integer #属性类型1--int 2--bool 3--string
	value 2 : string
}

]]
}

