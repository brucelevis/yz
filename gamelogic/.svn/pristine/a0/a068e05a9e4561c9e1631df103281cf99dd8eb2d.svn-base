function pack_response(errcode,result)
	return cjson.encode({
		errcode = errcode,
		result = result,
	})
end

function unpack_response(body)
	local data = cjson.decode(body)
	return tonumber(data.errcode),data.result
end

function response(id,statuscode,bodyfunc,header)
	local ok,err = httpd.write_response(sockethelper.writefunc(id),statuscode,bodyfunc,header)
	if not ok then
		skynet.error(string.format("fd = %d,%s",id,err))
	end
end

C2AC_SECRET = "fc0d0ff048063e3523bb21946e450ea8"

function sortforsign(tbl)
	local params = {}
	for k,v in pairs(tbl) do
		if k ~= "sign" then
			table.insert(params,string.format("%s=%s",k,v))
		end
	end
	table.sort(params)
	return table.concat(params,"&")
end

function makesign(tbl)
	local str = sortforsign(tbl)
	return md5.sumhexa(string.format("%s%s",str,C2AC_SECRET))
end

function checksign(tbl)
	local str = sortforsign(tbl)
	return tbl.sign == md5.sumhexa(string.format("%s%s",str,C2AC_SECRET))
end

function make_request(tbl)
	tbl.sign = makesign(tbl)
	return tbl
end

