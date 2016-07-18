function update(path)
	path = "gamelogic."..path
	hotfix.hotfix(path)
end

function module(path)
	path = "gamelogic."..path
	return require(path)
end

