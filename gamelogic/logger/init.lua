-- 适配框架
--require "gamelogic.serverinfo" -- for register 'servicem' protocol
-- gamelogic.serverinfo导入后内存占用会大300k,这里自行注册servicem协议即可
local skynet = require "skynet"
pcall(skynet.register_protocol,{
	name = "servicem",
	id = 20,
	pack = function (...)
		return skynet.pack(...)
	end,
	unpack = function (...) 
		return skynet.unpack(...) 
	end,
})

logger = logger or {}
local LOGGERSRV=".NMGLOG"

function logger.debug(filename,...)
	if logger.loglevel > logger.LOG_DEBUG then
		return
	end
	skynet.send(LOGGERSRV,"servicem","log","send",filename,"[DEBUG]",...)
end

function logger.info(filename,...)
	if logger.loglevel > logger.LOG_INFO then
		return
	end
	skynet.send(LOGGERSRV,"servicem","log","send",filename,"[INFO]",...)
end

function logger.warning(filename,...)
	if logger.loglevel > logger.LOG_WARNING then
		return
	end
	skynet.send(LOGGERSRV,"servicem","log","send",filename,"[WARNING]",...)
end

function logger.error(filename,...)
	if logger.loglevel > logger.LOG_ERROR then
		return
	end
	skynet.send(LOGGERSRV,"servicem","log","send",filename,"[ERROR]",...)
end

function logger.critical(filename,...)
	if logger.loglevel > logger.LOG_CRITICAL then
		return
	end
	skynet.send(LOGGERSRV,"servicem","log","send",filename,"[CRITICAL]",...)

	local content = table.concat({...},"\t")
	logger.reportbymail("CRITICAL",content)
end

function logger.log(loglevel,filename,...)
	local log = assert(logger[loglevel],"invalid mode:" .. tostring(loglevel))
	assert(select("#",...) > 0,string.format("%s %s:null logname",loglevel,filename))
	log(filename,...)
end

local function escape(str) 
	local ret = string.gsub(str,"\"","\\\"")
	return ret
end

function logger.reportbymail(subject,content)
	local cmd = string.format("cd ../logicshell && sh reportbymail.sh %q %q",escape(subject),escape(content))
	--local cmd = string.format("cd ../logicshell && sh curl/reportbymail.sh %q %q",escape(subject),escape(content))
	local fd = io.popen(cmd)
	fd:close()
end

function logger.sendmail(to_list,subject,content)
	local cmd = string.format("cd ../logicshell && python sendmail.py '%s' %q %q",to_list,escape(subject),escape(content))
	--local cmd = string.format("cd ../logicshell && sh curl/sendmail.sh '%s' %q %q",to_list,escape(subject),escape(content))
	local fd = io.popen(cmd)
	fd:close()
end

-- console/print
function logger.print(...)
	if logger.loglevel > logger.LOG_DEBUG then
		return
	end
	print(string.format("[%s]",os.date("%Y-%m-%d %H:%M:%S")),...)
end

function logger.pprintf(fmt,...)
	if logger.loglevel > logger.LOG_DEBUG then
		return
	end
	pprintf(string.format("[%s] %s",os.date("%Y-%m-%d %H:%M:%S"),fmt),...)
end


function logger.setloglevel(loglevel)
	if type(loglevel) == "string" then
		loglevel = assert(logger.LOGLEVEL_NAME_ID[loglevel],"Invalid loglevel:" .. tostring(loglevel))
	end
	if not (logger.LOG_DEBUG <= loglevel and loglevel <= logger.LOG_CRITICAL) then
		error("Invalid loglevel:" .. tostring(loglevel))
	end
	logger.loglevel = loglevel
end

logger.LOG_DEBUG = 1
logger.LOG_INFO = 2
logger.LOG_WARNING = 3
logger.LOG_ERROR = 4
logger.LOG_CRITICAL = 5
logger.LOGLEVEL_NAME_ID = {
	debug = logger.LOG_DEBUG,
	info = logger.LOG_INFO,
	warning = logger.LOG_WARNING,
	["error"] = logger.LOG_ERROR,
	critical = logger.LOG_CRITICAL,
}


function logger.init()
	skynet = skynet or require "skynet"
	local loglevel = skynet.getenv("loglevel")
	logger.setloglevel(loglevel)
end

-- 载入模块就初始化
logger.init()

function logger.shutdown()
end

return logger
