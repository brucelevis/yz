-- 适配框架
require "adapterlib.serverinfo"

g_serverinfo.gameflag = "ro"

local serverinfo = g_serverinfo
g_serverinfo.rlAllowedPrefixes["proto."] = true
-----------------------------------------------------
-----------------------------------------------------

function serverinfo:startgame()
	net.dispatch()
	if self.initAll then
		self:initAll()
	end
end

function serverinfo:loadfromdb(attrName)
	if self.serverAttribute then
		assert(self.sidbname)
		local db = dbmgr.getdb()
    	if attrName then
    		local attrData = self.serverAttribute[attrName]
    		if attrData then
				local dbData = db:get(db:key(self.sidbname,attrData.saveName))
    			if dbData then
    				self[attrName] = dbData
    			else
					db:set(db:key(self.sidbname,attrData.saveName),self[attrName])
    			end
    		end
    	else
    		for attrName,attrData in pairs(self.serverAttribute) do
				local dbData = db:get(db:key(self.sidbname,attrData.saveName))
    			if dbData then
    				self[attrName] = dbData
    			else
					db:set(db:key(self.sidbname,attrData.saveName),self[attrName])
    			end
    		end	
    	end
    end
end

function g_serverinfo:_save(attrName)
	local db = dbmgr.getdb()
	if attrName then
		local attrData = self.serverAttribute[attrName]
		if attrData then
			db:set(db:key(self.sidname,attrData.saveName),self[attrName])
		end
	else
		for attrName,attrData in pairs(self.serverAttribute) do
			db:set(db:key(self.sidname,attrData.saveName),self[attrName])
		end	
	end
end

function g_serverinfo:save(attrName)
	return self:_save(attrName)
end


function g_serverinfo.exeGmshell(gmstr,pid,args)
	local cmdline = string.format("%s %s",gmstr,table.concat(args," "))
	local tbl = {pcall(gm.docmd,pid,cmdline)}
	local pcall_ok = table.remove(tbl,1)
	local issuccess = table.remove(tbl,1)
	local result
	if next(tbl) then
		for i,v in ipairs(tbl) do
			tbl[i] = mytostring(v)
		end
		result = table.concat(tbl,",")
	end
	logger.log("info","gmshell",format("[exeGmshell] docmd='%s' pcall_ok=%s issuccess=%s return=%s",cmdline,pcall_ok,issuccess,result))
end

function g_serverinfo:_reloadmodule(modname)
	local result = hotfix.hotfix(modname)
	return result and "[ok]" or "[no change]"
end


