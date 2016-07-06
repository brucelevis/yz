-- 辅助库全局函数

function isvalid_name(name)
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
	return string.match(account,"%w+@%w+%.%w+")
end

function isvalid_passwd(passwd)
	return string.match(passwd,"^[%w_]+$")
end

function gethideip(ip)
	local hideip = ip:gsub("([^.]+)","*",2)
	return hideip
end

