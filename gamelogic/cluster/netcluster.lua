netcluster = netcluster or {}

function netcluster.init()
	--netcluster.route = require "gamelogic.cluster.route"
	netcluster.playermethod = require "gamelogic.cluster.playermethod"
	netcluster.modmethod = require "gamelogic.cluster.modmethod"
	netcluster.forward = require "gamelogic.cluster.forward"
	netcluster.resumemgr = require "gamelogic.resume.resumemgr"
	netcluster.rpc = require "gamelogic.cluster.rpc"
	netcluster.war = require "gamelogic.cluster.war"
end

function __hotfix(oldmod)
	netcluster.init()
end

return netcluster
