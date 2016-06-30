-- 适配框架
require "gamelogic.serverinfo" -- for register 'servicem' protocol
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
end

function logger.log(loglevel,filename,...)
	local log = assert(logger[loglevel],"invalid mode:" .. tostring(loglevel))
	assert(select("#",...) > 0,string.format("%s %s:null logname",loglevel,filename))
	log(filename,...)
end

function logger.sendmail(to_list,subject,content)
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
