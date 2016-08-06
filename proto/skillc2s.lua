return {
	p = "skill",
	si = 6800, -- [6800,6900)
	src = [[

#装备技能
skill_wieldskill 6800 {
	request {
		base 0 : basetype
		skillid 1 : integer
		position 2 : integer	#技能槽中的位置(1-4)
	}
}

#选择当前使用哪一个技能槽
skill_setcurslot 6801 {
	request {
		base 0 : basetype
		slot 1 : integer	#技能槽编号(1-3)
	}
}

#学习技能
skill_learnskill 6802 {
	request {
		base 0 : basetype
		skillid 1 : integer
	}
}

#重置技能点
skill_resetpoint 6803 {
	request {
		base 0 : basetype
	}
}

#交换2个技能位置
skill_changepos 6804 {
	request {
		base 0 : basetype
		skillid1 1 : integer
		skillid2 2 : integer
	}
}

]]
}
