data_0201_SkillFormula = {
	[1] = function(ins_skill, ins_logic, attacker, target)
			local value = (ins_skill.bdWeiLiPer-0.1)*(0.5+0.5*ins_skill.curLv/ins_skill.maxLv)
			return value
		end,

	[10001] = function(ins_skill, ins_logic, attacker, target)
			local value = ins_logic.powerValue*ins_skill.m_skillLvFix*(0.5+0.5*ins_skill.m_curLv/ins_skill.maxLv)
			if value < 0 then value = 0 end
			return value
		end,

	[10002] = function(ins_skill, ins_logic, attacker, target)
			local value = ins_logic.powerValue*ins_skill.m_skillLvFix*(0.5+0.5*ins_skill.m_curLv/ins_skill.maxLv)
			return value
		end,

}

