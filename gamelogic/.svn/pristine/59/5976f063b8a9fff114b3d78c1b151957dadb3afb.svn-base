local function download(agent,query,header,body)
	body = cjson.decode(body)
	local filename = assert(body.filename)
	local readfrom = body.readfrom or 1
	local result = {}
	local fd = io.open("upload/" .. filename,"rb")
	local size = fd:seek("end")
	fd:seek("set",readfrom)
	local content = fd:read(4096)
	fd:close()
	result.content = content
	if readfrom + 4096 >= size then
		result.finish = "ok"
	end
	return STATUS_OK,result
end

return download
