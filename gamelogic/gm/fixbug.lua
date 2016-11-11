
gm = require "gamelogic.gm.init"

gm.fixbug = gm.fixbug or {}

function gm.fixbug.resumeref(args)
	if not cserver.isdatacenter() then
		resumemgr.recover_refs()
	end
end

return gm
