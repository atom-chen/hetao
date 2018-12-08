local f_secret = "LHP0522pp"
local crypto = require("kernel.framework.crypto")
local json = require("kernel.framework.json")
require("lfs")

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


UserDbCache = class("UserDbCache")
UserDbCache.__is_singleton = true

function UserDbCache:ctor()
	self._allUserData = {}
	self._allPublicData = {}
	self._allUserTmpData = {}
end

function UserDbCache:dtor()
	
end

function UserDbCache:ClearTmpData()
	self._allUserTmpData = {}
end

function UserDbCache:InitAllUserData()
	local dir = self:GetUserFileDir()
	if not dir then return end
	local path_list = {}
	FindInDir(dir, "%.lua", path_list, true)
	dump(path_list)
	for _, filepath in ipairs(path_list) do
		if not self._allUserData[filepath] then
			print("初始化读取", filepath)
			local contents = io.readfile(filepath)
			if contents then
				self._allUserData[filepath] = contents
			end
		end
	end
end

function UserDbCache:GetUserFilepath(sKey)
	if not sKey then print("获取用户缓存路径失败，未知Key") return nil end
	assert(type(sKey)=="string")
	local username = UserEntity.GetInstance():Get_username()
	if not username or username == "" then print("获取用户缓存路径失败，未知用户") return nil end
	return string.format("%s/userdb/%s/%s/%s.lua", GAME_CONFIG.LOCAL_DIR, HTTP_HEAD_VAL_1, username, sKey)
end

function UserDbCache:GetUserFileDir()
	local username = UserEntity.GetInstance():Get_username()
	if not username or username == "" then print("获取用户缓存路径失败，未知用户") return nil end
	return string.format("%s/userdb/%s/%s", GAME_CONFIG.LOCAL_DIR, HTTP_HEAD_VAL_1, username)
end


function UserDbCache:SaveUserTmpData(sKey, tData)
	tData = tData or {}
	local filepath = self:GetUserFilepath(sKey)
	if not filepath then return false end
	local contents = table.to_string(tData)
	self._allUserTmpData[filepath] = contents
	print("保存临时数据")
	return true
end

function UserDbCache:GetUserTmpData(sKey)
	if not sKey then print("读取用户缓存失败，未知Key") return nil end
	assert(type(sKey)=="string")
	local filepath = self:GetUserFilepath(sKey)
	if not filepath then return nil end
	print("获取临时数据", self._allUserTmpData[filepath])
	return self._allUserTmpData[filepath]
end

function UserDbCache:SaveUserData(sKey, tData)
	tData = tData or {}
	local filepath = self:GetUserFilepath(sKey)
	if not filepath then return false end
	local contents = table.to_string(tData)
	self._allUserData[filepath] = contents
	FileHelper.CheckDir(self:GetUserFileDir(), true)
	
	if XLog and XLog.syncSaveFile then
		XLog.syncSaveFile(filepath, contents)
		print("保存用户缓存成功", sKey, filepath)
		return true
	else
		local ret = io.writefile(filepath, contents)
		if not ret then
			print("保存用户缓存失败", sKey, filepath)
		else
			print("保存用户缓存成功", sKey, filepath)
		end
		return ret
	end
end

function UserDbCache:GetUserData(sKey)
	if not sKey then print("读取用户缓存失败，未知Key") return nil end
	assert(type(sKey)=="string")
	local filepath = self:GetUserFilepath(sKey)
	if not filepath then return nil end
	if self._allUserData[filepath] then return self._allUserData[filepath] end
	local contents = io.readfile(filepath)
	if contents then
	--	print("读取用户缓存成功", sKey, filepath)
		self._allUserData[filepath] = contents
		return contents
--	else
--		print("读取用户缓存失败", sKey, filepath)
	end
	return nil
end

-------------------------------------------------------------------

function UserDbCache:GetPublicFilepath(sKey)
	if not sKey then print("获取公用缓存路径失败，未知Key") return nil end
	assert(type(sKey)=="string")
	return string.format("%s/publicdb/%s/%s.lua", GAME_CONFIG.LOCAL_DIR, HTTP_HEAD_VAL_1, sKey)
end

function UserDbCache:GetPublicFileDir()
	return string.format("%s/publicdb/%s", GAME_CONFIG.LOCAL_DIR, HTTP_HEAD_VAL_1)
end

function UserDbCache:SavePublicData(sKey, tData)
	tData = tData or {}
	local filepath = self:GetPublicFilepath(sKey)
	if not filepath then return false end
	local contents = table.to_string(tData)
	self._allPublicData[filepath] = contents
	FileHelper.CheckDir(self:GetPublicFileDir(), true)
	
	if XLog and XLog.syncSaveFile then
		XLog.syncSaveFile(filepath, contents)
		print("保存公用缓存成功", sKey, filepath)
		return true
	else
		local ret = io.writefile(filepath, contents)
		if not ret then
			print("保存公用缓存失败", sKey, filepath)
		else
			print("保存公用缓存成功", sKey, filepath)
		end
		return ret
	end
end

function UserDbCache:GetPublicData(sKey)
	if not sKey then print("读取公用缓存失败，未知Key") return nil end
	assert(type(sKey)=="string")
	local filepath = self:GetPublicFilepath(sKey)
	if not filepath then return nil end
	if self._allPublicData[filepath] then return self._allPublicData[filepath] end
	local contents = io.readfile(filepath)
	if contents then
	--	print("读取公用缓存成功", sKey, filepath)
		self._allPublicData[filepath] = contents
		return contents
--	else
--		print("读取公用缓存失败", sKey, filepath)
	end
	return nil
end
