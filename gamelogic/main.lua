-- 适配框架
local skynet = require "skynet"
require "gamelogic.game"

local function init(...)
	game.init()
end


local function main(...)
end


------------------------------------------------------------------------------
g_serverinfo.sidbname = "serverinfo"
g_serverinfo.m_project = "模版（逻辑）"

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