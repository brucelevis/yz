skillaux = skillaux or {}
local job_skills = {}

local function initjob2skills()
	job_skills = {}
	for skillid,data in pairs(data_0201_Skill) do
		local job = data.jobID
		if not job_skills[job] then
			job_skills[job] = {}
		end
		table.insert(job_skills[job],skillid)
	end
end

initjob2skills()

function skillaux.getskills_byjob(job)
	return job_skills[job]
end

return skillaux
