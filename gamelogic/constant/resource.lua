-- 资源

RESTYPE = {}
for resid,v in pairs(data_ResType) do
	RESTYPE[resid] = string.upper(v.flag)
	RESTYPE[string.upper(v.flag)] = resid
	RESTYPE[string.lower(v.flag)] = resid
end

function getresname(resid)
	if type(resid) == "string" then
		resid = RESTYPE[resid]
	end
	return data_ResType[resid].name
end

function getresflag(resid)
	if type(resid) == "string" then
		return string.lower(resid)
	end
	return data_ResType[resid].flag
end

function getresid(resid)
	if type(resid) == "string" then
		return RESTYPE[string.upper(resid)]
	end
	return resid
end
