-- 应答模式
reqresp = reqresp or {
	id = 0,
	sessions = {},
}

function reqresp.init()
	reqresp.starttimer_checkallsession()
end

function reqresp.genid()
	if not reqresp.id then
		reqresp.id = 0
	end
	if reqresp.id > MAX_NUMBER then
		reqresp.id = 0
	end
	reqresp.id = reqresp.id + 1
	return reqresp.id
end

function reqresp.req(pid,request,callback)
	local id
	if callback then
		id = reqresp.genid()
	else
		id = 0
	end
	-- noneed response
	if id ~= 0 then
		local lifetime = request.lifetime or 300
		reqresp.sessions[id] = {
			request = request,
			callback = callback,
			exceedtime = os.time() + lifetime,
			pid = pid,
		}
	end
	return id
end

function reqresp.resp(pid,id,response)
	local session = reqresp.sessions[id]
	if session and session.pid == pid then
		reqresp.sessions[id] = nil
		if session.callback then
			session.callback(pid,session.request,response)
		end
		return session
	end
end

function reqresp.starttimer_checkallsession()
	local interval = reqresp.interval or 5
	timer.timeout("reqresp.starttimer_checkallsession",interval,reqresp.starttimer_checkallsession)
	local now = os.time()
	for id,session in pairs(reqresp.sessions) do
		if session.exceedtime and session.exceedtime < now then
			reqresp.sessions[id] = nil
			if session.callback then
				session.callback(0,session.request,response)
			end
		end
	end
end

return reqresp
