require "gamelogic.logger.init"
require "gamelogic.skynet"
require "gamelogic.base.init"
require "gamelogic.hotfix.init"
require "gamelogic.channel"
require "gamelogic.playermgr.init"
require "gamelogic.playermanager"
require "gamelogic.loginqueue"
require "gamelogic.db.init"
require "gamelogic.timectrl.init"
require "gamelogic.net.init"
require "gamelogic.console.init"
require "gamelogic.globalmgr"
require "gamelogic.cluster.init"
require "gamelogic.service.init"
require "gamelogic.loginqueue"
require "gamelogic.language.init"
require "gamelogic.object"
require "gamelogic.init"


local function _print(...)
	print(...)
	skynet.error(...)
end

game = game or {}
function game.init()
	local srvname = skynet.getenv("srvname")
	_print("Server start",srvname)
	_print("package.path:",package.path)
	_print("package.cpath:",package.cpath)
	os.execute("pwd")

	local fd = io.open("/dev/urandom","r")
	if fd then
		local d = fd:read(4)
		math.randomseed(os.time() + d:byte(1) + (d:byte(2) * 256) + (d:byte(3) * 65536) + (d:byte(4) * 4294967296))
		fd:close()
	end
	if skynet.getenv("servermode") == "DEBUG" then
		console.init()
		_print("console.init")
	end
	-- 载入logger就已初始化了
	--logger.init()
	_print("logger.init")
	dbmgr.init()
	_print("dbmgr.init")
	channel.init()
	_print("channel.init")
	globalmgr.init()
	_print("globalmgr.init")
	net.init()
	_print("net.init")
	playermgr.init()
	_print("playermgr.init")
	rpc.init()
	_print("rpc.init")
	gm.init()
	_print("gm.init")
	loginqueue.init()
	_print("loginqueue.init")
	mailmgr.init()
	_print("mailmgr.init")
	scenemgr.init()
	_print("scenemgr.init")
	cteammgr.startgame()
	_print("cteammgr.startgame")
	huodongmgr.init()
	_print("huodongmgr.init")
	event.init()
	_print("event.init")
	warmgr.init()
	_print("warmgr.init")
	timectrl.init()
	_print("timectrl.init")
	language.init({
		language_from = skynet.getenv("language_from"),
		language_to = skynet.getenv("language_to"),
	})
	wordfilter.init({
		filter_words = data_FilterWord,
		exclude_words = data_ExcludeWord,
	})

	game.initall = true
	game.startgame() -- 初始化完后启动的逻辑
	logger.log("info","startserver",string.format("[startgame] runno=%s",globalmgr.server:query("runno",0)))
end

function game.startgame()
	_print("Startgame...")
	cserver.starttimer_logstatus()
	_print("Startgame ok")
end

function game.shutdown(reason)
	game.initall = nil
	_print("Shutdown...")
	logger.log("info","startserver",string.format("[shutdown start] reason=%s",reason))
	_print("playermgr.kickall")
	playermgr.kickall("shutdown")
	_print("game.saveall")
	game.saveall()
	timer.timeout("timer.shutdown",20,function ()
		_print("dbmgr.shutdown")
		dbmgr.shutdown()
		_print("logger.shutdown")
		logger.log("info","startserver",string.format("[shutdown success] reason=%s",reason))
		logger.shutdown()
		_print("Shutdown ok")
		os.execute(string.format("cd ../logicshell/ && sh killserver.sh %s",skynet.getenv("srvname")))
	end)
end

function game.saveall()
	logger.log("info","startserver","[saveall]")

	--huodongmgr.savetodatabase()
	saveall()
end

return game
