cdb = cdb or {}

function cdb.new(conf)
	local self = {}
	self.conf = conf
	self.dbsrv = skynet.newservice("gamelogic/service/redisd")
	setmetatable(self,{__index = function (t,k)
		local cmd = k
		local f = function (self,...)
			local func = cdb[cmd]
			if func then
				return func(self,...)
			else
				return skynet.call(self.dbsrv,"lua",cmd,...)
			end
		end
		t[k] = f
		return f
	end})
	self:connect()
	return self
end

function cdb:connect(conf)
	conf = conf or self.conf
	local result = skynet.call(self.dbsrv,"lua","connect",conf)
	logger.log("info","db",format("[connect to database] address=%s conf=%s conn=%s result=%s",skynet.address(skynet.self()),conf,self.dbsrv,result))
	return result
end

function cdb:disconnect()
	local dbsrv = self.dbsrv
	self.dbsrv = nil
	if dbsrv then
		local result = skynet.call(dbsrv,"lua","disconnect")
		logger.log("info","db",string.format("[disconnect] address=%s conn=%s result=%s",skynet.address(skynet.self()),tostring(dbsrv),result))
		return result
	end

end


function cdb:key(...)
	local args = {...}
	local ret = args[1] -- tblname
	for i = 2,#args do
		ret = ret .. ":" .. tostring(args[i])
	end
	return ret
end

function cdb:get(key)
	local value = skynet.call(self.dbsrv,"lua","get",key)
	logger.log("debug","db",format("[get] key=%s value=%s",key,value))
	if value then
		value = cjson.decode(value)
	end
	return value
end

function cdb:set(key,value)
	logger.log("debug","db",format("[set] key=%s value=%s",key,value))
	if (not value) or 
		(type(value) == "table" and not next(value)) then
		return
	end
	value = cjson.encode(value)
	return skynet.call(self.dbsrv,"lua","set",key,value)
end

return cdb
