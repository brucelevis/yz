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
	roletype 3 : integer
	# 1--队长;2--跟随队员;3--暂离队员;4--离线队员
	teamstate 4 : integer
}

.TeamType {
	teamid 0 : integer
	target 1 : integer
	# 组队等级
	lv 2 : integer
	members 3 : *MemberType
	automatch 4 : boolean		# 是否处于自动匹配中,true--是，false/空--否
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
}

# 物品精炼增加的属性类型（影响战斗属性)
.ItemRefineAttrType {
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

	cnt 20 : integer  #精炼次数
	succ_ratio 21 : integer #当前成功概率(若为空，客户端根据次数读导表显示)
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

	refine 6 : ItemRefineAttrType #精炼增加的属性
	fumo 7 : ItemFumoAttrType #附魔增加的属性
	tmpfumo 8 : ItemFumoAttrType #附魔后尚未点击确认生成的属性
	cardid 9 : integer    #插入的卡片物品ID
	isopen 10 : boolean		#仅对于卡片物品有用，true--开启，其他--未开启
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

.TaskType {
	taskid 0 : integer
	state 1 : integer		#1--接受状态，2--完成状态
	exceedtime 2 : integer	#任务过期时间
	type 3 : integer		#任务玩法类型
	findnpc 4 : integer
	patrol 5 : string		#巡逻目标坐标id
	progress 6 : integer	#进度条时间
	items 7 : *ItemType		#需求物品
	npcs 8 : *SceneNpcType	#客户端npc,即任务中可见
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

]]
}

