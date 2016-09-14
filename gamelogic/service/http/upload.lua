local function upload(agent,query,header,body)
	body = cjson.decode(body)
	local filename = body.filename
	local content = body.content
	local id = body.id
	local fd
	if not id then
		id = uuid()
		fd = io.open("upload/" .. id,"wb")
	else
		fd = io.open("upload/" .. id,"ab")
	end
	fd:write(content)
	fd:close()
	return STATUS_OK,{id=id}
end

return upload
