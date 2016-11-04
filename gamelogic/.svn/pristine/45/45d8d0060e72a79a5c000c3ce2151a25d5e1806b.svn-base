data_0201_SkillFormula = {
	[1] = function(ins_skill, ins_logic, attacker, target)
			local value = (ins_skill.bdWeiLiPer-0.1)*(0.5+0.5*ins_skill.curLv/ins_skill.maxLv)
			return value
		end,

	[10001] = function(ins_skill, ins_logic, attacker, target)
			local value = math.pow(attacker:getProperty(WUGONG), 2)/(attacker:getProperty(WUGONG)+target:getProperty(WUFANG)*2)*ins_logic.powerPer+ins_logic.powerValue*ins_skill.m_skillLvFix
			if value < 1 then value = 1 end
			return -value
		end,

	[10101] = function(ins_skill, ins_logic, attacker, target)
			local value = ins_logic.powerValue*ins_skill.m_skillLvFix*(0.5+0.5*ins_skill.m_curLv/ins_skill.maxLv)
			if value < 0 then value = 0 end
			return value
		end,

}

