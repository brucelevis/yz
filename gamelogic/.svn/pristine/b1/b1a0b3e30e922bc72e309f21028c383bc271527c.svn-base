data_0201_SkillFormula = {
	[1] = function(ins_skill, ins_logic, attacker, target, computeFixFunc)
			local value = (ins_skill.bdWeiLiPer-0.1)*(0.5+0.5*ins_skill.curLv/ins_skill.maxLv)
			if computeFixFunc ~= nil then
				value = computeFixFunc(value, 1, ins_skill, ins_logic, attacker, target)
			end
			return value
		end,

	[10001] = function(ins_skill, ins_logic, attacker, target, computeFixFunc)
			local value = math.pow(attacker:getProperty("WUGONG"), 2)/(attacker:getProperty("WUGONG")+target:getProperty("WUFANG")*2)*ins_logic.powerPer+ins_logic.powerValue*ins_skill.m_skillLvFix
			if computeFixFunc ~= nil then
				value = computeFixFunc(value, 1, ins_skill, ins_logic, attacker, target)
			end
			if value < 1 then value = 1 end
			return -value
		end,

	[10003] = function(ins_skill, ins_logic, attacker, target, computeFixFunc)
			local value = math.pow(attacker:getProperty("FAGONG"), 2)/(attacker:getProperty("FAGONG")+target:getProperty("FAFANG")*2)*ins_logic.powerPer+ins_logic.powerValue*ins_skill.m_skillLvFix
			if computeFixFunc ~= nil then
				value = computeFixFunc(value, 1, ins_skill, ins_logic, attacker, target)
			end
			if value < 1 then value = 1 end
			return -value
		end,

	[10004] = function(ins_skill, ins_logic, attacker, target, computeFixFunc)
			local value = math.pow(attacker:getProperty("FAGONG"), 2)/(attacker:getProperty("FAGONG")+target:getProperty("FAFANG")*2)*ins_logic.powerPer+ins_logic.powerValue*ins_skill.m_skillLvFix
			if computeFixFunc ~= nil then
				value = computeFixFunc(value, 1, ins_skill, ins_logic, attacker, target)
			end
			if value < 1 then value = 1 end
			return value
		end,

	[10005] = function(ins_skill, ins_logic, attacker, target, computeFixFunc)
			local value = attacker:getProperty("FAGONG")*ins_logic.powerPer+ins_logic.powerValue*ins_skill.m_skillLvFix
			if computeFixFunc ~= nil then
				value = computeFixFunc(value, 1, ins_skill, ins_logic, attacker, target)
			end
			if value < 1 then value = 1 end
			return value
		end,

	[10011] = function(ins_skill, ins_logic, attacker, target, computeFixFunc)
			local value = ins_logic.powerValue*ins_skill.m_skillLvFix
			if computeFixFunc ~= nil then
				value = computeFixFunc(value, 0, ins_skill, ins_logic, attacker, target)
			end
			if value < 0 then value = 0 end
			return value
		end,

	[10012] = function(ins_skill, ins_logic, attacker, target, computeFixFunc)
			local value = ins_logic.powerPer
			if computeFixFunc ~= nil then
				value = computeFixFunc(value, 0, ins_skill, ins_logic, attacker, target)
			end
			if value < 0 then value = 0 end
			return value
		end,

	[10013] = function(ins_skill, ins_logic, attacker, target, computeFixFunc)
			local value = ins_logic.powerPer
			if computeFixFunc ~= nil then
				value = computeFixFunc(value, 0, ins_skill, ins_logic, attacker, target)
			end
			if value < 0 then value = 0 end
			return -value
		end,

	[10014] = function(ins_skill, ins_logic, attacker, target, computeFixFunc)
			local value = ins_logic.powerValue
			if computeFixFunc ~= nil then
				value = computeFixFunc(value, 0, ins_skill, ins_logic, attacker, target)
			end
			if value < 0 then value = 0 end
			return value
		end,

	[10015] = function(ins_skill, ins_logic, attacker, target, computeFixFunc)
			local value = ins_logic.powerValue
			if computeFixFunc ~= nil then
				value = computeFixFunc(value, 0, ins_skill, ins_logic, attacker, target)
			end
			if value < 0 then value = 0 end
			return -value
		end,

	[10016] = function(ins_skill, ins_logic, attacker, target, computeFixFunc)
			local value = ins_logic.powerValue*ins_skill.m_skillLvFix
			if computeFixFunc ~= nil then
				value = computeFixFunc(value, 0, ins_skill, ins_logic, attacker, target)
			end
			if value < 0 then value = 0 end
			return -value
		end,

	[10101] = function(ins_skill, ins_logic, attacker, target, computeFixFunc)
			local value = ins_logic.powerValue*ins_skill.m_skillLvFix*(0.5+0.5*ins_skill.m_curLv/ins_skill.maxLv)
			if computeFixFunc ~= nil then
				value = computeFixFunc(value, 0, ins_skill, ins_logic, attacker, target)
			end
			if value < 0 then value = 0 end
			return value
		end,

	[10102] = function(ins_skill, ins_logic, attacker, target, computeFixFunc)
			local value = ins_logic.powerPer*ins_skill.m_skillLvFix/ins_skill.maxLv
			if computeFixFunc ~= nil then
				value = computeFixFunc(value, 0, ins_skill, ins_logic, attacker, target)
			end
			if value < 0 then value = 0 end
			return value
		end,

	[10103] = function(ins_skill, ins_logic, attacker, target, computeFixFunc)
			local value = 0.4
			if computeFixFunc ~= nil then
				value = computeFixFunc(value, 0, ins_skill, ins_logic, attacker, target)
			end
			if value < 0 then value = 0 end
			return -value
		end,

	[10104] = function(ins_skill, ins_logic, attacker, target, computeFixFunc)
			local value = 0.9
			if computeFixFunc ~= nil then
				value = computeFixFunc(value, 0, ins_skill, ins_logic, attacker, target)
			end
			if value < 0 then value = 0 end
			return value
		end,

	[20001] = function(ins_skill, ins_logic, attacker, target, computeFixFunc)
			local value = (ins_logic.powerPer-0.1)*(0.5+0.5*ins_skill.m_curLv/ins_skill.maxLv)
			if computeFixFunc ~= nil then
				value = computeFixFunc(value, 0, ins_skill, ins_logic, attacker, target)
			end
			if value < 0 then value = 0 end
			if value > 1 then value = 1 end
			return value
		end,

}

