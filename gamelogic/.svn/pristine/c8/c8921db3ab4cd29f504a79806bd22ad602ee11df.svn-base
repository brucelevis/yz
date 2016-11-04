-- 辅助库全局函数

INVALID_NAMES = {
	["$"] = true
}

function isvalid_name(name)
	local isok,filter_name = wordfilter.filter(name)
	if not isok or filter_name ~= name then
		return false,language.format("名字非法")
	end
	for ban_name in pairs(INVALID_NAMES) do
		if string.find(name,ban_name,1,true) then
			return false,language.format("名字包含非法单词")
		end
	end
	return true
end

function isvalid_roletype(roletype)
	if not data_0101_Hero[roletype] then
		return false
	end
	return true
end

function isvalid_sex(sex)
	return sex == 1 or sex == 2
end

function isvalid_accountname(account)
	--return string.match(account,"%w+@%w+%.%w+")
	return true
end

function isvalid_passwd(passwd)
	return string.match(passwd,"^[%w_]+$")
end

function gethideip(ip)
	local hideip = ip:gsub("([^.]+)","*",2)
	return hideip
end

