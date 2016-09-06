local function test(srvname,account,passwd,callback)
	local roletype = 10001
	function onlogin(srvname,response)
		local errcode = assert(response.errcode)	
		pprintf("login:%s,roles:%s",errcode,response.result)
		if errcode == STATUS_ACCT_NOEXIST then
			sendpackage(srvname,"login","register",{
				acct = account,
				passwd = passwd,
				channel = "inner",
			})
			wait("login","register_result",onregister)
		elseif errcode == STATUS_OK then
			local roles = response.result
			if not roles or #roles == 0 then
				sendpackage(srvname,"login","createrole",{
					acct = account,
					roletype = roletype,
					sex = 1,
					name = account,
				})
				wait("login","createrole_result",oncreaterole)
			else
				local role = assert(roles[1],"no role")
				sendpackage(srvname,"login","entergame",{
					roleid = role.roleid,
				})
				wait("login","entergame_result",onentergame)
			end
			
		end
	end

	function onregister(srvname,response)
		local errcode = assert(response.errcode)
		print("register:",errcode)
		if errcode == STATUS_OK then
			sendpackage(srvname,"login","login",{
				acct = account,
				passwd = passwd,
			})
			wait("login","login_result",onlogin)
		end
	end

	function oncreaterole(srvname,response)
		local errcode = assert(response.errcode)
		print("createrole:",errcode) 
		if errcode == STATUS_OK then
			local role = assert(response.result)
			sendpackage(srvname,"login","entergame",{
				roleid = role.roleid,
			})
			wait("login","entergame_result",onentergame)
		end
	end

	function onentergame(srvname,response)
		local errcode = assert(response.errcode)
		print("entergame ",errcode==0 and "ok" or "fail",errcode)
		if callback and false then
			callback()
		end
	end

	sendpackage(srvname,"login","login",{
		acct = account,
		passwd = passwd,
	})
	wait("login","login_result",onlogin)
end



return test
