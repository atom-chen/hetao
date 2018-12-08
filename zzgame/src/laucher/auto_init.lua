-------------------------
-- 文件生成器，只在windows下使用
-------------------------
if device.platform ~= "windows" then return end 

require("lfs")

local tbl_2_string = function(tb, tb_deep)
	if type(tb) ~= "table" then return end

	tb_deep = tb_deep or 20
	local cur_deep = 1
	local tb_cache = {}
	
	local function save_table(tb_data)
		-- 存储当前层table
		if type(tb_data) ~= "table"  then
			logger.error("Error", "存储类型必须为table:", tb, tb_deep)
			return
		end
		if tb_cache[tb_data] then
			logger.error("Error", "无法继续存储，table中包含循环引用，", tb, tb_deep)
			return
		end
		tb_cache[tb_data] = true
		
		local k, v
		cur_deep = cur_deep + 1
		if cur_deep > tb_deep then
			logger.error("Error", "待存储table超过可允许的table深度", tb, tb_deep)
			cur_deep = cur_deep -  1
			return
		end
		
		local tab = string.rep(" ", (cur_deep - 1)*4)
		local dststr = { "{\n" }

		-- 调整table存储顺序，按照key排序
		local keys_num = {}
		local keys_str = {}
		for k, v in pairs(tb_data) do
			if type(k) == "number" then
				table.insert(keys_num, k)
			elseif type(k) == "string" then
				table.insert(keys_str, k)
			end
		end
		table.sort(keys_str)
		table.sort(keys_num)

		local keys = {}
		for i, k in ipairs(keys_num) do
			table.insert(keys, k)
		end
		for i, k in ipairs(keys_str) do
			table.insert(keys, k)
		end
		for k, v in pairs(tb_data) do
			if type(k) ~= "number" and type(k) ~= "string" then
				table.insert(keys, k)
			end
		end

		-- 保存调整后的table
		local i
		for i, k in ipairs(keys) do
			v = tb_data[k]
			local arg, value
			
			local typeK = type(k)
			if typeK == "number" then
				arg = string.format("[%d]", k)   --认为key一定是整数
			elseif typeK == "string" then
				arg = string.format("[\"%s\"]", string.gsub(k,"\\","\\\\"))
			elseif typeK == "boolean" then
				arg = string.format("[%s]", tostring(k))
			end
			
			local typeV = type(v)
			if typeV == "number" then
				--value = string.format("%f", v)
				value = tostring(v)
			elseif typeV == "string" then
				value = string.format("\"%s\"", string.gsub(v,"\\","\\\\"))
			elseif typeV == "table" then
				value = save_table(v)
			elseif typeV == "boolean" then
				value = tostring(v)
			end
			
			if arg and value then
				dststr[#dststr+1] = string.format("%s%s = %s,\n", tab, arg, value)
			end
		end
		
		cur_deep = cur_deep -  1
		local tab = string.rep(" ", (cur_deep - 1) * 4)
		tb_cache[tb_data] = false
		
		return string.format("%s%s}", table.concat(dststr), tab)
	end

	local tb_str = save_table(tb)
	return tb_str
end

local function FindInDir(path, wefind, r_table, intofolder)
	if device.platform ~= "windows" then return end
	
	for file in lfs.dir(path) do
		if file ~= "." and file ~= ".." then
			local f = path .. "/" .. file
			if string.find(f, wefind) ~= nil then
--				print(f)
				table.insert(r_table, f)
			end
			local attr = lfs.attributes(f)
			assert(type(attr) == "table")
			if attr.mode == "directory" and intofolder then
				FindInDir(f, wefind, r_table, intofolder)
			end
		end
	end
end

local function FixFilePath(filepath)
	local fixedname = string.gsub(filepath, "\\", "/")
	fixedname = string.gsub(fixedname, "//", "/")
	return fixedname
end

--@ 输入 res/icon/normal_bkg.png
--@ 返回 normal_bkg
local function GetFileName(filename)
	local fixname = FixFilePath(filename)
	local name = string.match(fixname, ".+/([^/]*%.%w+)$")
	return string.split(name,".")[1]
end

--是否全为空白字符
local function IsWhiteSpace(Str)
	return not string.find(Str, "%S")
end

-- 变量名检测
local function IsValidVarName(Name)
	if IsWhiteSpace(Name) or string.gsub(Name, "[_%a][_%w]*", "") ~= "" then
		return false
	end
	return true
end

local function check_res_path()
	if device.platform ~= "windows" then return end
	
	local WORK_DIR = lfs.currentdir()
	local INPUT_DIR = "res"
	
	local AllImages = {}
	
	local path_list = {}
	FindInDir(WORK_DIR.."/"..INPUT_DIR, "%.png", path_list, true)
	local pathcut = WORK_DIR .. "/"
	for i, sss in ipairs(path_list) do 
		local filepath = string.gsub(sss, pathcut, "")
		local filename = GetFileName(filepath)
		if AllImages[filename] then
		--	print("【警告】 检测到同名文件", filename, filepath)
		end
		AllImages[filename] = filepath
	--	print(filename, filepath)
		if not IsValidVarName(filename) then
			print("命名不规范：", filename, filepath)
		end
	end 
	
	local path_list = {}
	FindInDir(WORK_DIR.."/"..INPUT_DIR, "%.png", path_list, true)
	local pathcut = WORK_DIR .. "/"
	for i, sss in ipairs(path_list) do 
		local filepath = string.gsub(sss, pathcut, "")
		local filename = GetFileName(filepath)
		if AllImages[filename] then
		--	print("【警告】 检测到同名文件", filename, filepath)
		end
		AllImages[filename] = filepath
	--	print(filename, filepath)
		if not IsValidVarName(filename) then
			print("命名不规范：", filename, filepath)
		end
	end 
end

check_res_path()

local function init_res_path()
	if device.platform ~= "windows" then return end
	
	local WORK_DIR = lfs.currentdir()
	local INPUT_DIR = "res/uistu"
	local OUT_PATH = "src/app/arpg/consts/IMG_CONFIG.lua"
	
	local AllImages = {}
	
	local path_list = {}
	FindInDir(WORK_DIR.."/"..INPUT_DIR, "%.png", path_list, true)
	local pathcut = WORK_DIR .. "/"
	for i, sss in ipairs(path_list) do 
		local filepath = string.gsub(sss, pathcut, "")
		local key = string.gsub(filepath, "/", "_")
		key = string.sub(key, 1, -5)
		key = string.gsub(key, "res_uistu_", "")
		if AllImages[key] then
			print("【警告】 检测到同名文件", filepath)
		end
		AllImages[key] = filepath
	end 
	
	local path_list = {}
	FindInDir(WORK_DIR.."/"..INPUT_DIR, "%.jpg", path_list, true)
	local pathcut = WORK_DIR .. "/"
	for i, sss in ipairs(path_list) do 
		local filepath = string.gsub(sss, pathcut, "")
		local key = string.gsub(filepath, "/", "_")
		key = string.sub(key, 1, -5)
		key = string.gsub(key, "res_uistu_", "")
		if AllImages[key] then
			print("【警告】 检测到同名文件", filepath)
		end
		AllImages[key] = filepath
	end 
	
--	print(tbl_2_string(AllImages))
	
	local fout = io.open(OUT_PATH,"w")
	if not fout then assert(false, "无法自动生成"..OUT_PATH) return end
	fout:write("-------------------------------\n")
	fout:write("-- 该文件自动生成，请勿更改\n")
	fout:write("-------------------------------\n")
	fout:write("IMG_CONFIG = ")
	fout:write(tbl_2_string(AllImages))
	fout:close()
end

local function init_modules()
	if device.platform ~= "windows" then return end
	
	local WORK_DIR = lfs.currentdir()
	local INPUT_DIR = "src/app/arpg/modules"
	local OUT_PATH = INPUT_DIR .. "/init.lua"
	local skipFile = "app.arpg.modules.init"
	
	local path_list = {}
	FindInDir(WORK_DIR.."/"..INPUT_DIR, "%.lua", path_list, true)
	local cut = WORK_DIR .. "/src/"
	for i, sss in ipairs(path_list) do 
		path_list[i] = string.gsub(sss, cut, "")
		path_list[i] = string.gsub(path_list[i], "/", ".")
		path_list[i] = string.sub(path_list[i], 1, -5)
	end 
	
	local fout = io.open(OUT_PATH,"w")
	if not fout then assert(false, "无法自动生成"..OUT_PATH) return end
	fout:write("-------------------------------\n")
	fout:write("-- 该文件自动生成，请勿更改\n")
	fout:write("-------------------------------\n")
	for i, filestr in ipairs(path_list) do 
		if filestr ~= skipFile then
			fout:write( string.format("require(\"%s\") \n",filestr) )
		end
	end
	fout:close()
end

local function init_games()
	if device.platform ~= "windows" then return end
	
	local WORK_DIR = lfs.currentdir()
	local INPUT_DIR = "src/app/arpg/games"
	local OUT_PATH = INPUT_DIR .. "/init.lua"
	local skipFile = "app.arpg.games.init"
	
	local path_list = {}
	FindInDir(WORK_DIR.."/"..INPUT_DIR, "%.lua", path_list, true)
	local cut = WORK_DIR .. "/src/"
	for i, sss in ipairs(path_list) do 
		path_list[i] = string.gsub(sss, cut, "")
		path_list[i] = string.gsub(path_list[i], "/", ".")
		path_list[i] = string.sub(path_list[i], 1, -5)
	end 
	
	local fout = io.open(OUT_PATH,"w")
	if not fout then assert(false, "无法自动生成"..OUT_PATH) return end
	fout:write("-------------------------------\n")
	fout:write("-- 该文件自动生成，请勿更改\n")
	fout:write("-------------------------------\n")
	for i, filestr in ipairs(path_list) do 
		if filestr ~= skipFile then
			fout:write( string.format("require(\"%s\") \n",filestr) )
		end
	end
	fout:close()
end

--init_res_path()
init_modules()
init_games()

---------------------------------------------------------------------------

--[[
local function init_xiaoxiaole()
	if device.platform ~= "windows" then return end
	
	local WORK_DIR = lfs.currentdir()
	local INPUT_DIR = "src/app/xiaoxiaole"
	local OUT_PATH = INPUT_DIR .. "/init.lua"
	local skipFile = "app.xiaoxiaole.init"
	
	local path_list = {}
	FindInDir(WORK_DIR.."/"..INPUT_DIR, "%.lua", path_list, true)
	local cut = WORK_DIR .. "/src/"
	for i, sss in ipairs(path_list) do 
		path_list[i] = string.gsub(sss, cut, "")
		path_list[i] = string.gsub(path_list[i], "/", ".")
		path_list[i] = string.sub(path_list[i], 1, -5)
	end 
	
	local fout = io.open(OUT_PATH,"w")
	if not fout then assert(false, "无法自动生成"..OUT_PATH) return end
	fout:write("-------------------------------\n")
	fout:write("-- 该文件自动生成，请勿更改\n")
	fout:write("-------------------------------\n")
	for i, filestr in ipairs(path_list) do 
		if filestr ~= skipFile then
			fout:write( string.format("require(\"%s\") \n",filestr) )
		end
	end
	fout:close()
end

init_xiaoxiaole()
]]

---------------------------------------------------------------------------
--[[
local function init_star()
	if device.platform ~= "windows" then return end
	
	local WORK_DIR = lfs.currentdir()
	local INPUT_DIR = "src/fegg/disstar"
	local OUT_PATH = INPUT_DIR .. "/init.lua"
	local skipFile = "fegg.disstar.init"
	
	local path_list = {}
	FindInDir(WORK_DIR.."/"..INPUT_DIR, "%.lua", path_list, true)
	local cut = WORK_DIR .. "/src/"
	for i, sss in ipairs(path_list) do 
		path_list[i] = string.gsub(sss, cut, "")
		path_list[i] = string.gsub(path_list[i], "/", ".")
		path_list[i] = string.sub(path_list[i], 1, -5)
	end 
	
	local fout = io.open(OUT_PATH,"w")
	if not fout then assert(false, "无法自动生成"..OUT_PATH) return end
	fout:write("-------------------------------\n")
	fout:write("-- 该文件自动生成，请勿更改\n")
	fout:write("-------------------------------\n")
	for i, filestr in ipairs(path_list) do 
		if filestr ~= skipFile then
			fout:write( string.format("require(\"%s\") \n",filestr) )
		end
	end
	fout:close()
end

init_star()
]]