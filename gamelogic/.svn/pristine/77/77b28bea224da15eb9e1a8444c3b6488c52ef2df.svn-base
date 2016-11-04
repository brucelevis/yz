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
	logger.log("debug","request",string.format("[response] id=%s statuscode=%s body=%s header=%s",id,statuscode,bodyfunc,header))
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

function upload(host,url,filename,recvheader)
	local header = {
		["content-type"] = "multipart/form-data",
		["unescape_body"] = "ok",
	}
	local form = {
		filename = filename,
	}
	local filename = assert(form.filename)
	local fd = io.open(filename,"rb")
	local content = fd:read("*a")
	fd:close()
	local status,response
	local length = string.len(content)
	local id
	for i=1,length,4196 do
		form.content = nil
		form.id = id
		local data = string.sub(content,i,i+4196-1)
		form.content = data
		status,response = httpc.request("POST",host,url,recvheader,header,cjson.encode(form))
		if status ~= 200 then
			return status,response
		end
		local errcode,result = unpack_response(response)
		if errcode ~= STATUS_OK then
			return status,response
		end
		id = result.id
	end
	return status,response
end

function download(host,url,filename,recvheader)
	local header = {
		["content-type"] = "multipart/form-data",
		["unescape_body"] = "ok",
	}
	local form = {
		filename = filename,
		readfrom = 0,
	}
	local data = {}
	while not form.finish do
		local status,response = httpc.request("POST",host,url,recvheader,header,cjson.encode(form))
		if status ~= 200 then
			return
		end
		local errcode,result = unpack_response(response)
		if errcode ~= STATUS_OK then
			return
		end
		local length = string.len(result.content)
		if length == 0 then
			break
		end
		form.readfrom = form.readfrom + length
		table.insert(data,result.content)
		--print(filename,status,result.finish,form.readfrom,length)
		form.finish = result.finish
	end
	return table.concat(data,"")
end

function httpc.postx(host,url,body,recvheader)
	-- 框架层修改了httpc.postx接口参数，接口顶入如下:
	-- httpc.post(host,url,recvheader,header,body)
	return httpc.post(host,url,recvheader,nil,body)
end

