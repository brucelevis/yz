gm = require "gamelogic.gm.init"

--- 指令: buildgmdoc
--- 功能: 构建GM指令文档.txt
function gm.buildgmdoc()
	local tmpfilename = ".gmdoc.tmp"
	local gmcode_path = "../src/gamelogic/gm/"
	local docpath = "../../design_doc/GM/"   -- 确保策划文档路径检出了!
	local docfilename = docpath .. "GM指令文档.txt"
	-- all filename in $gmcode_path
	os.execute("ls -l " .. gmcode_path .. " | awk '{print $9}' > " .. tmpfilename)

	local fdin = io.open(tmpfilename,"rb")
	local fdout = io.open(docfilename,"wb")
	for filename in fdin:lines("*l") do
		--print(filename)
		if not string.match(filename,"^%s*$") then
			if filename:sub(-4) == ".lua" then
				local fd = io.open(gmcode_path .. filename,"rb")	
				local tbl = {}
				local open = false
				for line in fd:lines("*l") do
					line = string.match(line,"^%-%-%-%s*(.+)$")	
					if line then
						table.insert(tbl,line .. "\n")	
						open = true	
					else
						if open then
							table.insert(tbl,"\n")
						end
						open = false
					end
				end
				fd:close()
				filename = string.gsub(filename,"%.lua","")
				fdout:write(string.format("[%s]\n",filename))
				for _,line in pairs(tbl) do
					fdout:write(line)
				end
				fdout:write("\n\n")
			end
		end
	end
	fdin:close()
	fdout:close()
	os.execute("rm -rf " .. tmpfilename)
	gm.__doc = nil
	os.execute(string.format("svn add %s",docfilename))
	os.execute(string.format("svn commit %s -m 'buildgmdoc'",docfilename))
end

--- 指令: help
--- 功能: 查找包含关键字的相关指令
--- 用法: help 关键字
function gm.help(args)
	local isok,args = checkargs(args,"string")
	if not isok then
		return "用法: help 关键字"
	end
	local patten = args[1]
	local doc = gm.getdoc()
	local emptyline,startlineno = 1,1
	local maxlineno = #doc
	local findlines = {}
	local lineno = 0
	while lineno < maxlineno do
		lineno = lineno + 1
		local line = doc[lineno]
		if not line then
			break
		end
		if line == "" or line == "\r" or line == "\n" or line == "\r\n" then
			emptyline = lineno
		else
			if string.find(line,patten) then
				for i=emptyline+1,maxlineno do
					local curline = doc[i]
					if not (curline == "" or curline == "\r" or curline == "\n" or curline == "\r\n") then
						table.insert(findlines,curline)
					else
						table.insert(findlines,string.rep("-",20))
						emptyline = i
						if i > lineno then
							lineno = i
						end
						break
					end
				end
			end
		end
	end
	return table.concat(findlines,"\n")
end

function gm.getdoc()
	if not gm.__doc then
		gm.__doc = {}
		local doc_filename = "../../design_doc/GM/GM指令文档.txt"
		local isok,fd = pcall(io.open,doc_filename,"rb")
		if not isok then
			gm.buildgmdoc()
			fd = io.open(doc_filename,"rb")
		end
		while true do
			local line = fd:read("*l")
			if not line then
				break
			else
				table.insert(gm.__doc,line)
			end
		end
	end
	return gm.__doc
end

return gm
