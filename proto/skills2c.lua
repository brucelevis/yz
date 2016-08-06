return {
	p = "skill",
	si = 6800, --[6800,6900)
	src = [[

#技能类型
.SkillType {
	id 0 : integer
	level 1 : integer
	pos 2 : integer
}


skill_addskill 6800 {
	request {
		base 0 : basetype
		skill 1 : SkillType
	}
}

#更新技能（增量更新)
skill_updateskill 6801 {
	request {
		base 0 : basetype
		skill 1 : SkillType
	}
}

#登陆、更新时同步当前技能方案(全量更新)
skill_updateslot 6802 {
	request {
		base 0 : basetype
		curslot 1 : integer
		skillids 2 : *integer
	}
}

#登陆时同步所有技能
skill_allskill 6803 {
	request {
		base 0 : basetype
		skills 1 : *SkillType
	}
}

#登陆、更新时同步当前剩余技能点
skill_updatepoint 6804 {
	request {
		base 0 : basetype
		point 1 : integer
	}
}

]]
}
