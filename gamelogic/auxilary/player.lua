-- 玩家辅助函数
playeraux = playeraux or {}


function playeraux.getmaxlv()
	if not playeraux.maxlv then
		playeraux.maxlv = table.count(data_1001_LvExp)
	end
	return playeraux.maxlv
end

function playeraux.getmaxexp(lv)
	local data = data_1001_LvExp[lv]
	return data.sumexp
end

function playeraux.getmaxjoblv(zs)
	local maxlv = playeraux.getmaxlv()
	local attr = string.format("jobzs%d_sumexp",zs)
	local maxjoblv_attr = string.format("jobzs%d_maxjoblv",zs)
	if not playeraux[maxjoblv_attr] then
		local maxjoblv = 0
		for lv=1,maxlv do
			local data = data_1001_LvExp[lv]
			local val = data[attr]
			if val == 0 then
				break
			end
			maxjoblv = maxjoblv + 1
		end
		playeraux[maxjoblv_attr] = maxjoblv
	end
	return playeraux[maxjoblv_attr]
end

function playeraux.getmaxjobexp(zs,joblv)
	local data = data_1001_LvExp[joblv]
	local attr = string.format("jobzs%d_sumexp",zs)
	return data[attr]
end

return playeraux