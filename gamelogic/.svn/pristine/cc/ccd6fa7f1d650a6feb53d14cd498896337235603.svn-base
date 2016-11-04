-- 资源

RESTYPE = {}
for resid,v in pairs(data_ResType) do
	RESTYPE[resid] = string.upper(v.type)
	RESTYPE[string.upper(v.type)] = resid
	RESTYPE[string.lower(v.type)] = resid
end

function getresname(resid)
	if type(resid) == "string" then
		resid = RESTYPE[resid]
	end
	return data_ResType[resid].name
end
