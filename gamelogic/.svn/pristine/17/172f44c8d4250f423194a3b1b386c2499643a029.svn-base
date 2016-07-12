service = service or {}

local scene = {}

function scene.test(...)
	print("scene.test",...)
end

service.scene = scene

function service.dispatch(_,session,source,_,protoname,cmd,...)

	logger.log("debug","netservice",format("[recv] source=%s session=%d protoname=%s cmd=%s request=%s",source,session,protoname,cmd,{...}))
	local tbl = service[protoname]
	local func = tbl[cmd]
	return func(...)
end

return service
