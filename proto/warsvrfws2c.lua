--
-- Author: Chens
-- Date: 2016-09-12 17:16:38
--
return {
	p = "warsvrfw",
	si = 6200, --[6200,6500)
	src = [[
#####################战斗部分
#==========================================1基础组合类型
#----1.1小人buff数据
.warRoleBuff {
}
.warEquipSkill {
	pos 	0 	: integer 	# 位置
	skillId 1 	: integer 	# 技能Id
	lv 		2 	: integer 	# 等级
}
#----1.2战场小人
.warRoleData {
	pos			0	 : integer		#位置
	warObjId	1	 : integer 		# 战斗对象Id
	playerId	2	 : integer		# 玩家id
	objId		3	 : integer		# 角色id
	typeId		4	 : integer		# 角色类型
	job         5 	 : integer 		# 职业
	name		6	 : string 		# 角色名称
	baselv		7 	 : integer 		# 基础等级
	joblv		8 	 : integer 		# 职业等级
	hp			9	 : integer		# hp
	maxHp		10	 : integer		# hp上限
	mp			11	 : integer		# mp
	maxMp		12	 : integer		# mp上限
	team		14	 : integer		# 攻方守方标志（1为TEAM_ATTACK攻方，2为TEAM_DEFEND守方）
	buffList	20 	 : *warRoleBuff	#buff列表
	deadState 	21	 : integer		#死亡状态
	equipSkill  22 	 : *warEquipSkill 	# 装备技能列表
	effaniIds   23 	 : *integer 	# 技能特效列表
}
#----1.6 序列角色信息
.warSeqRoleData{
	warObjId 		0 	: integer 	# 战斗对象Id，不能少
	skillId 		1	: integer 	# 使用技能Id
	skillEffectId	2 	: integer 	# 技能效果Id
	addHp 			3 	: integer 	# 增加HP
	addMp 			4 	: integer 	# 增加Mp
	objHp 			5 	: integer 	# 序列之后的HP，如果nil，表示不变
	objMp 			6 	: integer 	# 序列之后的MP，如果nil，表示不变
	objMaxHp		7 	: integer 	# 序列之后的MaxHP，如果nil，表示不变
	objMaxMp		8 	: integer 	# 序列之后的MaxMP，如果nil，表示不变

	ljHp 			9 	: *integer 	# 连击伤害值，一个列表{连击伤害值1，连击伤害值2,...}。没有连击ljHp=nil，如果有连击，飘字用这个


	deadflag        12  : integer   # 死亡标志
}
.warActionHpMp{
	addHp 			1 	: integer 	# 增加HP
	addMp 			2 	: integer 	# 增加Mp
	objHp 			3 	: integer 	# 序列之后的HP，如果nil，表示不变
	objMp 			4 	: integer 	# 序列之后的MP，如果nil，表示不变
	objMaxHp		5 	: integer 	# 序列之后的MaxHP，如果nil，表示不变
	objMaxMp		6 	: integer 	# 序列之后的MaxMP，如果nil，表示不变
}
#----1.7 序列角色状态变化
#-- 动作参数: 101		-- 跳转到角色前面，结果是面对面
.warActionParam_101{
}
#-- 动作参数: 102		-- HPMP设置
.warActionParam_102{
	addHp 			0 	: integer 	# 增加HP
	addMp 			1 	: integer 	# 增加Mp
	objHp 			2 	: integer 	# 序列之后的HP，如果nil，表示不变
	objMp 			3 	: integer 	# 序列之后的MP，如果nil，表示不变
	objMaxHp		4 	: integer 	# 序列之后的MaxHP，如果nil，表示不变
	objMaxMp		5 	: integer 	# 序列之后的MaxMP，如果nil，表示不变
}
#-- 动作参数: 103		-- 重设位置和方向，动作不变
.warActionParam_103{
}
#-- 动作参数: 104		-- 技能喊招
.warActionParam_104{
	skillId 	0	: integer 	# 技能id
	warPos 		1 	: integer 	#战斗位置
}
#-- 动作参数: 105		-- 播放技能特效 
.warActionParam_105{
	effId 		1 	: integer 	# 播放特效id
}
#-- 动作参数: 106		-- 删除播放技能特效  
.warActionParam_106{
	effId 		1 	: integer 	# 播放特效id
}
#-- 动作参数: 110		-- 播放角色动画
.warActionParam_110{
	stateId 	0 : integer 	# 动作ID
	times 		1 : integer 	# 次数 默认1次
	type 		2 : integer 	# 类型, 1-正常，2-播放完之后角色不动 默认1
}
#-- 动作参数: 120		-- 设置角色技能状态
.warActionParam_120{
	state 	0 : integer 	# 状态 RoleSkillState_XXXXXX 系列
}
#-- 动作参数: 121		-- 删除角色技能状态
.warActionParam_121{
	state 	0 : integer 	# 状态 RoleSkillState_XXXXXX 系列
}
#-- 动作参数: 130 		-- 设置目标
.warActionParam_130{
	targetId 	0 : integer 	#目标id
}
#-- 动作参数: 201		-- 设置咏唱
.warActionParam_201{
	startRoundTime 	0 : integer 	# 开始时间
	endRoundTime 	1 : integer 	# 结束时间
}
#-- 动作参数: 202		-- 设置技能Cd
.warActionParam_202{
	skillId 		0 : integer 	# 技能Id
	startRoundTime 	1 : integer 	# 开始时间
	endRoundTime 	2 : integer 	# 结束时间
}
#-- 动作参数: 301		-- 被伤害
.warActionParam_301{
	addHp 			0 	: integer 	# 增加HP
	addMp 			1 	: integer 	# 增加Mp
	objHp 			2 	: integer 	# 序列之后的HP，如果nil，表示不变
	objMp 			3 	: integer 	# 序列之后的MP，如果nil，表示不变
	isMiss			4 	: integer 	# miss，如果miss，这个值是1
	isCrit			5	: integer 	# 是否暴击， 如果暴击，这个值是1
	effId 			6 	: integer 	# 播放特效id
}
#-- 动作参数: 401		-- 击退
.warActionParam_401{
	pos 			0 	: integer 	# 位置
}

#----1.7战斗(子)序列
.warSubSeqData{
	actionType 		0 	: integer 			# 序列动作类型
	startTime 		1	: integer 			# 开始时间，这个时间是以回合开始时间为0点
	actionTime      2   : integer 	   		# 动作时间, 如果没有，则读导表

	#目标参数  如果只有单个目标，放在integer对象里面; 如果有两个或者以上，防止列表里面;
	attObjId 	10  : integer 		#
	dstObjId 	11  : integer 		#
	attObjIds 	12  : *integer 		#
	dstObjIds 	13  : *integer 		#

	# 参数
	param_101 		101 : warActionParam_101
	param_102 		102 : warActionParam_102
	param_103 		103 : warActionParam_103
	param_104 		104 : warActionParam_104
	param_105 		105 : warActionParam_105
	param_106 		106 : warActionParam_106
	param_110 		110 : warActionParam_110
	param_120		120 : warActionParam_120
	param_121		121 : warActionParam_121
	param_130		130 : warActionParam_130
	param_201		201 : warActionParam_201
	param_202		202 : warActionParam_202
	param_301		301 : warActionParam_301
	param_401		401 : warActionParam_401
}
#==========================================2战斗表现需要的数据
#----2.1战斗序列
.warSeqData {
	warId 			0 	: integer 		# 战斗id
	round 			1 	: integer 		# 回合数
	roundTime 		3 	: integer 		# 回合时间，如果为nil，使用默认
	seqList 		4 	: *warSubSeqData  # 子序列
}
#----2.2战场初始（包括创建和每回合初始）
.warBaseData {
	warID 		0 : integer 		#战斗id
	warType		1 : integer			#战斗类型
	round 		2 : integer 		#回合数（0表示创建战斗）
	# state 		3 : warStateData	#战场状态
	roleList	4 : *warRoleData	#战场小人
	singleWarFlag 	5 : boolean					#单人战斗标志（1为true，其他为false）
	warFightID 		6 : integer					#怪物（导表战斗id）
	beginSeq 		7 : *warSeqData 			#round为0时，才有的战斗开始前的序列。
}
#----2.3序列结果（用于客户端表现的结果）
.warEndData {
	result 		0 : integer 		# 结果
	reason 		1 : integer 		# 结束类型
	endTime 	2 : integer 		# 结束回合时间
}

warsvrfw_startWar 6200 { 		# 开始战斗
	request {
		base 0 : basetype 
		warId  1 : integer 		  # 战斗id
		warType 2 : integer 		# 战斗类型
		warTime 3 : integer			# 战斗开始时间
		baseWarInfo 4 : warBaseData 	# 战斗开始数据
	}
}

warsvrfw_sendRoundSeq 6201 { 		# 发送回合战斗数据
	request {
		base 0 : basetype 
		warId  1 : integer 		  # 战斗id
		round 2 : integer 			# 回合数
		warSeqList 3 : *warSubSeqData 	# 回合数据
		warEndData  4 : warEndData 		# 回合结束数据
		roundTime  5 : integer 			# 回合时间
	}
}

warsvrfw_sendRealTimeSeq 6202 { 		# 发送实时战斗数据
	request {
		base 0 : basetype 
		warId  1 : integer 		  # 战斗id
		round 2 : integer 			# 回合数
		warSeqList 3 : *warSubSeqData 	# 回合数据
	}
}

warsvrfw_sendPrompt 6203 { 		# 发送 提示信息
	request {
		base 0 : basetype 
		warId  1 : integer 		  # 战斗id
		promptId 2 : integer
	}
}

warsvrfw_forceEndWar 6204 { 		# 强制结束战斗
	request {
		base 0 : basetype 
		warId  1 : integer 		  # 战斗id
	}
}

warsvrfw_setRoundTime 6205 { 		# 设置指定回合的最大时间，目前只设置0回合(准备回合)
	request {
		base 0 : basetype 
		warId  1 : integer 		  # 战斗id
		round  2 : integer 		  # 回合数
		time  3 : integer 		  # 时间
	}
}








]]
}


