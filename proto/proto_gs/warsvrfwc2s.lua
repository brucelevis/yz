--
-- Author: Chens
-- Date: 2016-09-12 17:16:44
--
return {
	p = "warsvrfw",
	si = 6200, --[6200,6500)
	src = [[


warsvrfw_reqUseSkill 6200 { 		# 使用技能请求
	request {
		base 0 : basetype 
		warId  1 : integer 		  # 战斗id
		roleId 2 : integer 			# 角色id
		skillId 3 : integer 		# 技能id
		targetId 4 : integer 		# 目标id
	}
}


warsvrfw_changeWuGongTar 6201 { 		# 请求切换物理攻击目标
	request {
		base 0 : basetype 
		warId  1 : integer 		  # 战斗id
		roleId 2 : integer 			# 角色id
		targetId 3 : integer 		# 目标id
	}
}


warsvrfw_switchPos 6202 { 		# 请求换位
	request {
		base 0 : basetype 
		warId  1 : integer 		  # 战斗id
		roleId 2 : integer 			# 角色id
	}
}


]]
}