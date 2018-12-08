-------------------------
-- 文件操作
-------------------------
local InstFileUtils = cc.FileUtils:getInstance()


FileHelper = {}

FileHelper.FixFilePath = function(filepath)
	local fixedname = string.gsub(filepath, "\\", "/")
	fixedname = string.gsub(fixedname, "//", "/")
	return fixedname
end

--@ 输入 res/icon/normal_bkg.png
--@ 返回 normal_bkg
FileHelper.GetFileName = function(filename)
	local fixname = FileHelper.FixFilePath(filename)
	local name = string.match(fixname, ".+/([^/]*%.%w+)$")
	return string.split(name,".")[1]
end

--@ 输入 res/icon/normal_bkg.png
--@ 返回 res/icon/  normal_bkg.png
FileHelper.StripFileName = function(filename)
-- 	local name = string.match(filename, “.+\\([^\\]*%.%w+)$”)
	local fixname = FileHelper.FixFilePath(filename)
	local name = string.match(fixname, ".+/([^/]*%.%w+)$")
	local dir = string.sub(filename, 1, string.len(filename)-string.len(name))
	return dir, name
end

-----------------------------------------------------------------

FileHelper.GetFullPath = function(filename)
	local fullname = GAME_CONFIG.LOCAL_DIR.."/"..filename
	return FileHelper.FixFilePath(fullname)
end

FileHelper.IsFileExist = function(filename)
	return InstFileUtils:isFileExist(FileHelper.GetFullPath(filename))
end

FileHelper.IsDirectoryExist = function(filename)
	return InstFileUtils:isDirectoryExist(FileHelper.GetFullPath(filename))
end

-- "haopeng/test.txt"
FileHelper.CreateDir = function(filename)
	local fullname = FileHelper.GetFullPath(filename)
	local List = string.split(fullname, "/")
	List[#List] = nil
	local dirPath = table.concat(List,"/")
	local bSucc = FileHelper.CheckDir(dirPath, true)
	if not bSucc then
		print("CreateDir fail: ", filename, fullname)
	end
	return bSucc
end

FileHelper.RemoveDir = function(DirPath)
	assert(false)
	return false
end

FileHelper.CreateFile = function(filename, sContent)
	assert(type(sContent)=="string")
	local bSucc = false
	
	if FileHelper.CreateDir(filename) then
		bSucc = InstFileUtils:writeStringToFile(sContent, FileHelper.GetFullPath(filename))
	end
	
	if not bSucc then
		print("FileHelper.CreateFile fail: ", filename)
	end
	
	return bSucc
end

FileHelper.RemoveFile = function(filename)
	assert(false)
	return false
end

FileHelper.RenameFile = function(oldname, newname)
	assert(false)
	return false
end

FileHelper.LoadFile = function(filepath)
	local fullname = FileHelper.GetFullPath(filepath)
	local Chunk = loadfile(fullname)
	if not Chunk then 
		print("LoadFile fail: "..filepath)
		return nil 
	end
	return Chunk
end

FileHelper.LoadTable = function(filepath)
	local fullname = FileHelper.GetFullPath(filepath)
	local Chunk = loadfile(fullname)
	if not Chunk then 
		print("LoadTable fail", filepath)
		return nil 
	end
	local tbl = Chunk()
	assert(type(tbl)=="table")
	return tbl
end

FileHelper.SaveTable = function(tbl, filepath, prefix_str)
	assert(type(tbl)=="table" and type(filepath)=="string")
	local str = table.to_string(tbl)
	if prefix_str then
		str = prefix_str .. str
	else
		str = "return " .. str
	end
	local bSucc = FileHelper.CreateFile(filepath, str)
	if not bSucc then
		print("SaveTable fail", filepath)
	end
	return bSucc
end

function FileHelper.CheckDir(_dir, isCreate)
	if not InstFileUtils:isDirectoryExist(_dir) then
		InstFileUtils:createDirectory(_dir)
	end
	if not InstFileUtils:isDirectoryExist(_dir) then
		if device.platform == "windows" then
			os.execute("mkdir \"" .. _dir .. "\"")
		else
			os.execute("mkdir -p \"" .. _dir .. "\"")
		end
	end 
	return InstFileUtils:isDirectoryExist(_dir)
end

