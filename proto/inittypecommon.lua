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
	roletype 3 : integer		#角色类型(职业ID)
	# 1--队长;2--跟随队员;3--暂离队员;4--离线队员
	teamstate 4 : integer
	jobzs 5 : integer			#职业转数
	joblv 6 : integer			#职业等级
}

.TeamType {
	teamid 0 : integer
	target 1 : integer		# 0--无目标，此时minlv/maxlv无用
	minlv 2 : integer
	maxlv 3 : integer
	members 4 : *MemberType
	automatch 5 : boolean		# 是否处于自动匹配中,true--是，false/空--否
	createtime 6 : integer		# 创建时间
}

.PublishTeamType {
	teamid 0 : integer
	target 26 : integer		# 0--无目标，此时minlv/maxlv无用
	minlv 2 : integer
	maxlv 3 : integer
	captain 4 : MemberType  # 队长信息
	time 5 : integer		# 发布时间
	len 6 : integer 		# 成员数
	fromsrv 7 : string		# 来自的服务器(空/本服名--来自本服)
}

.SceneItemType {
	id 0 :	 integer		#物品ID(拾取物品时和服务端通信的ID)
	type 1 : integer		#物品类型
	sceneid 2 : integer		#场景ID(可能无用)
	exceedtime 3 : integer	#过期时间
	num 4 : integer			#物品数量
	bind 5 : integer		#绑定标志(0/空--未绑定，其他--绑定)
	posid 6 : string		#坐标ID，包含mapid,x,y三份信息，见data_0401_MapDstPoint
	mapid 7 : integer		#地图ID
	pos 8 : PosType			#优先使用坐标ID,没有坐标ID再使用mapid和pos
}

.SceneNpcType {
	id 0 : integer			#npcid
	shape 1 : integer		#怪物造型
	name 2 : string			#怪物名字
	sceneid 3 : integer     #场景ID（可能无用)
	exceedtime 4 : integer  #过期时间
	cur_warcnt 5 : integer  #当前正在进行的战斗数(>0:战斗状态,==0/空:非战斗状态)
	purpose 6 : string		#用途分类:baotu--宝图怪
	posid 7 : string		#坐标ID，包含mapid,x,y三份信息，见data_0401_MapDstPoint
	mapid 8 : integer		#地图ID
	pos 9 : PosType			#优先使用坐标ID,没有坐标ID再使用mapid和pos
	nid 10 : integer		#任务表npcid,任务创建的npc特有
}

# 物品附魔增加的属性类型(影响战斗类型)
.ItemFumoAttrType {
	maxhp 0 : integer  #血量上限
	maxmp 1 : integer  #魔法上限
	atk 2 : integer #攻击力
	latk 3 : integer #远程攻击力
	def 4 : integer  #防御
	sp 5 : integer  #速度
	fsp 6 : integer #法术攻击速度(咏唱速度)
	dfsp 7 : integer #咏唱延迟(delay 法术攻击速度)
	fdef 8 : integer #法术防御
	fsqd 9 : integer #法术强度
	hpr 10 : integer #生命值回复
	mpr 11 : integer #魔法值回复
	jzfs 12 : integer #近战反伤
	ycfs 13 : integer #远程反伤
	mffs 14 : integer #魔法反伤
	hjct 15 : integer #护甲穿透
	fsct 16 : integer #法术穿透
	bt 17 : integer #霸体
	xx 18 : integer #吸血
	fsxx 19 : integer #法术吸血
}

.ItemType {
	id 0 : integer		#物品ID，对于邮件附件中的物品，ID为空
	type 1 : integer	#物品类型
	num 2 : integer		#物品数量
	bind 3 : integer	#0/空--未绑定，1--绑定
	createtime 4 : integer #创建时间，空表示无此属性
	pos 5 : integer #背包位置
	fumo 6 : ItemFumoAttrType #附魔增加的属性
	lv 7 : integer			# 卡片等级（仅对卡片有效，其他物品的等级读导表),空--0级
}

.PetType {
	id 0 : integer		# 宠物ID
	type 1 : integer	# 类型
	name 2 : string		# 名字
	pos 3 : integer		# 位置
	createtime 4 : integer	# 创建时间
	lv 5 : integer		# 等级
	exp 6 : integer		# 经验
	relationship 7 : integer	# 关系,见data_1700_PetRelationShip
	close 8 : integer	# 亲密度
	status 9 : integer	# 状态，见data_1700_PetStatus
	readywar 10 : boolean # true--出战状态,false/nil--休息状态
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
}

.TaskType {
	taskid 0 : integer
	state 1 : integer		#1--接受状态，2--完成状态
	exceedtime 2 : integer	#任务过期时间
	type 3 : integer		#任务玩法类型
	findnpc 4 : *integer
	respondtype 5 : integer #被找npc的应答模式
	patrol 6 : string		#巡逻目标坐标id
	collect 7 : string		#采集点坐标id
	collecttips 8 : string	#采集进度条文字显示
	items 9 : ItemType		#需求物品
	npcs 10 : *SceneNpcType	#客户端npc,即任务中可见
	submitnpc 11 : integer	#任务完成状态下，提交npcid
	ringnum 12 : integer	#当前环数
	donecnt 13 : integer	#当前次数（完成次数或者通过任务获得某道具的次数）
	donelimit 14 : integer	#上限次数（完成次数或者通过任务获得某道具的次数）
}

.QualityPointType {
	sum 0 : integer		# 总共的素质点（当前可用的素质点)
	expand 1 : integer	# 通过某些道具额外扩展的素质点（空值表示0）
	liliang 2 : integer # 力量
	minjie 3 : integer # 敏捷
	tili 4 : integer	# 体力
	lingqiao 5 : integer # 灵巧
	zhili 6 : integer	# 智力
	xingyun 7 : integer # 幸运
}

.SwitchType {
	id 1 : integer		#开关id
	state 2 : boolean	#开关状态
}

# 按钮类型
.ButtonType {
	content 0 : string		#按钮内容
	timeout 1 : integer		#超时时间,如:10表示倒计时10s
}

# 简介类型
.ResumeType {
	srvname 0 : string
	pid 1 : integer
	name 2 : string
	roletype 3 : integer
	lv 4 : integer
	online 5 : boolean		#是否在线
	fightpoint 6 : integer 	#战力
	joblv 7 : integer #职业等级
	jobzs 8 : integer
	# 1--队长;2--跟随队员;3--暂离队员;4--离线队员
	teamstate 9 : integer
	teamid 10 : integer
}

]]
}

