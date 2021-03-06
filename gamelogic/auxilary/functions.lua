-- 辅助库全局函数

INVALID_NAMES = {
	["$"] = true
}

function _isvalid_name(name)
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

function isvalid_name(name)
	local isok,errmsg = _isvalid_name(name)
	if not isok then
		return false,errmsg
	end
	-- 策划要求只做本服重名检查
	local db = dbmgr.getdb(cserver.datacenter())
	local srvname = cserver.getsrvname()
	local zonename = data_RoGameSrvList[srvname].zonename
	local isok = db:hget(db:key("allname",zonename),name)
	if isok then
		return false,language.format("名字重名")
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

function richtext(typ,info)
	local elem = {
		type = typ,
		info = info
	}
	elem = cjson.encode(elem)
	return string.format("#<REF>%s#",elem)
end

function markdown(typ,text,info)
	if text and info then
		assert(type(info) == "table")
		info = cjson.encode(info)
		return string.format("#<%s>[%s](%s)#",typ,text,info)
	else
		return string.format("#<%s>#",typ)
	end
end
