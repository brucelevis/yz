navigation = navigation or {}

function navigation.init()
	navigation.activity = {}
	for actid,activydata in pairs(data_1102_Navigation) do
		local huodong = huodongmgr.gethuodong(actid)
		if not huodong or huodong:isopen() then
			navigation.activity
		end
	end
end

function navigation.onlogin(player)
end

function navigation.ondayupdate()
end

function navigation.onhourupdate()
end

function navigation.onweekupdate()
end

function navigation.updateprogress(player,actid)
end

return navigation

