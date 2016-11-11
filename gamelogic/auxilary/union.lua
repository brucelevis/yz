unionaux = unionaux or {}

function unionaux.jobid(name)
	if not unionaux.name_jobid then
		unionaux.name_jobid = {}
		for jobid,v in pairs(data_1800_UnionJob) do
			unionaux.name_jobid[v.name] = jobid
		end
	end
	return unionaux.name_jobid[name]
end

function unionaux.jobname(jobid)
	local data = data_1800_UnionJob[jobid]
	return data.name
end

function unionaux.cando(jobid,what)
	local data = data_1800_UnionJob[jobid]
	local val = data.auth[what]
	if type(val) == "number" then
		return val == 1
	else
		return (not table.isempty(val)),val
	end
end

function unionaux.buildname(buildtype)
	if buildtype == "dating" then
		return "公会大厅"
	elseif buildtype == "yingdi" then
		return "公会营地"
	elseif buildtype == "cangku" then
		return "公会仓库"
	elseif buildtype == "zuofang" then
		return "公会作坊"
	elseif buildtype == "shangdian" then
		return "公会商店"
	elseif buildtype == "jitan" then
		return "公会祭坛"
	else
		error("Error BuildType:" .. tostring(buildtype))
	end
end

function unionaux.isvalid_badge(badge)
	for badge_type,badge_id in pairs(badge) do
		local data = data_1800_UnionBadge[badge_id]
		if not data then
			return false
		end
		local data = data[badge_type]
		if not data.gold or data.gold < 0 then
			return false
		end
	end
	return true
end

function unionaux.addmoney(unionid,addval,reason)
	local retval
	if cserver.isunionsrv() then
		local union = unionmgr:getunion(unionid)
		retval = union:addmoney(addval,reason)
	else
		retval = rpc.call(cserver.unionsrv(),"rpc","unionaux.addmoney",unionid,addval,reason)
	end
	return retval
end

function unionaux.getskilldata(skillid)
	return data_1800_UnionSkill[skillid]
end

function unionaux.build_lv_isok(union,cond)
	for buildtype,needlv in pairs(cond) do
		local haslv = union[buildtype]
		if haslv < needlv then
			buildtype = string.match(buildtype,"^(.*)_lv$")
			return false,language.format("{1}等级不足{2}级",unionaux.buildname(buildtype),needlv)
		end
	end
	return true
end

function unionaux.getunion(unionid)
	if cserver.isunionsrv() then
		local union = unionmgr:getunion(unionid)
		if not union then
			return
		end
		return union:pack()
	else
		return rpc.call(cserver.unionsrv(),"rpc","unionaux.getunion",unionid)
	end
end

function unionaux.member(unionid,pid)
	if cserver.isunionsrv() then
		local union = unionmgr:getunion(unionid)
		if not union then
			return
		else
			return union:member(pid)
		end
	else
		return rpc.pcall(cserver.unionsrv(),"rpc","unionaux.member",unionid,pid)
	end
end

function unionaux.unionmethod(unionid,...)
	if cserver.isunionsrv() then
		return unionmgr:unionmethod(unionid,...)
	else
		return rpc.call(cserver.unionsrv(),"rpc","unionmgr:unionmethod",unionid,...)
	end
end

function unionaux.gethuodong_collectitem(player)
	if not player:unionid() then
		return
	end
	local key = "union.huodong.collectitem"
	local huodong = player.today:query(key)
	if not huodong then
		local sumcnt = 10
		local cnt = sumcnt
		local show_ids = {}
		local tasks = {}
		while cnt > 0 do
			local taskid = choosekey(data_1800_UnionCollectItemTask,function (k,v)
				if show_ids[k] then
					return 0
				end
				return v.ratio
			end)
			show_ids[taskid] = true
			cnt = cnt - 1
			local task = data_1800_UnionCollectItemTask[taskid]
			table.insert(tasks,{
				taskid = taskid,
				itemtype = task.itemtype,
				neednum = task.neednum,
				hasnum = 0,
				donater = nil,
				isbonus = false,	-- 是否领取过奖励
			})
		end
		huodong = {
			tasks = tasks,
			finishcnt = 0,
			sumcnt = sumcnt,
		}
		player.today:set(key,huodong)
	end
	return huodong
end

function unionaux.gettask_collectitem(player,taskid)
	local huodong = unionaux.gethuodong_collectitem(player)
	if not huodong then
		return
	end
	for i,task in ipairs(huodong.tasks) do
		if task.taskid == taskid then
			return task
		end
	end
end

function unionaux.onlogin(player)
	local pid = player.pid
	local unionid = player:unionid()
	if unionid then
		rpc.pcall(cserver.unionsrv(),"rpc","unionmgr:onlogin",pid,cserver.getsrvname())
	end
	local skills = player:query("unionskill")
	if skills then
		skills = table.values(skills)
		sendpackage(player.pid,"union","sync_skills",{
			skills = skills,
		})
	end
end

function __hotfix(oldmod)
	unionaux.name_jobid = nil
end

return unionaux
