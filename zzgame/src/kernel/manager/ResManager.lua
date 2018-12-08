-------------------------
-- 资源管理器
-------------------------
local _InstTextureCache = cc.Director:getInstance():getTextureCache()
local _InstSpriteFrameCache = cc.SpriteFrameCache:getInstance()
local _InstAnimationCache = cc.AnimationCache:getInstance()
local _InstSprite3DCache = cc.Sprite3DCache:getInstance()
local _InstArmatureDataMgr = ccs.ArmatureDataManager:getInstance()


ClsResManager = class("ClsResManager")
ClsResManager.__is_singleton = true

function ClsResManager:ctor()
	self._tSprFrameInfo = {}
end

function ClsResManager:dtor()
    assert(false)
end


function ClsResManager:ClearEngineCaches()
	cc.Director:getInstance():purgeCachedData()
	_InstSprite3DCache:removeAllSprite3DData()
	_InstSpriteFrameCache:removeUnusedSpriteFrames()
	_InstTextureCache:removeUnusedTextures()
	_InstAnimationCache:removeAnimation(name)
end

---------------------------------------------------------

-- plistPath: "role/dance.plist"
function ClsResManager:AddSpriteFrames(plistPath)
	if self._tSprFrameInfo[plistPath] then
		self._tSprFrameInfo[plistPath] = self._tSprFrameInfo[plistPath] + 1 
--		logger.normal("add", plistPath, self._tSprFrameInfo[plistPath])
		return 
	end
	self._tSprFrameInfo[plistPath] = 1
	_InstSpriteFrameCache:addSpriteFrames(plistPath)
--	logger.normal(plistPath, self._tSprFrameInfo[plistPath])
end

-- plistPath: "role/dance.plist"
function ClsResManager:SubSpriteFrames(plistPath)
	if not plistPath or not self._tSprFrameInfo[plistPath] then return end
	self._tSprFrameInfo[plistPath] = self._tSprFrameInfo[plistPath] - 1
--	logger.normal("sub", plistPath, self._tSprFrameInfo[plistPath])
	if self._tSprFrameInfo[plistPath] <= 0 then
		self._tSprFrameInfo[plistPath] = nil
    	_InstSpriteFrameCache:removeSpriteFramesFromFile(plistPath)
	end
end



-- jsonFile: "xxx.ExportJson"
function ClsResManager:AddArmatureFileInfo(...)
	_InstArmatureDataMgr:addArmatureFileInfo(...)
end

-- jsonFile: "xxx.ExportJson"
function ClsResManager:AddArmatureFileInfoAsync(...)
	_InstArmatureDataMgr:addArmatureFileInfoAsync(...)
end

-- jsonFile: "xxx.ExportJson"
function ClsResManager:SubArmatureFileInfo(jsonFile)
	_InstArmatureDataMgr:removeArmatureFileInfo(jsonFile)
end
