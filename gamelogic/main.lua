-- 适配框架
local skynet = require "skynet"
require "gamelogic.game"

local function init(...)
	net.dispatch()
	game.init()
	g_serverinfo.sproto4shareinit()
end


local function main(...)
	-- 迟于init调用
end


------------------------------------------------------------------------------
g_serverinfo.sidbname = "serverinfo"
g_serverinfo.m_project = "RO（逻辑）"

function g_serverinfo:preinit()
	--g_gamedb:init()
end


function g_serverinfo:initAll()
	if g_serverinfo.serverOnDebug then
		g_serverinfo.profileThreshold = 0.01
	else
		g_serverinfo.profileThreshold = 0.5
	end
	init()
	main()
	g_gamenet:startlisten()
	--
end
