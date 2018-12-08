-------------------------
-- 扩展
-------------------------
local _InstTextureCache = cc.Director:getInstance():getTextureCache()
local _InstSpriteFrameCache = cc.SpriteFrameCache:getInstance()
local _InstAnimationCache = cc.AnimationCache:getInstance()
local _InstArmatureDataMgr = ccs.ArmatureDataManager:getInstance()

local Button = ccui.Button

Button.__origin_create = Button.create
function Button:create(resNormal, resPressed, resDisabled, resType)
	if resType then
		return Button:__origin_create(resNormal, resPressed, resDisabled, resType)
	end
	
	local sprFrame = _InstSpriteFrameCache:getSpriteFrame(resNormal)
	if sprFrame then
		return Button:__origin_create(resNormal, resPressed, resDisabled, ccui.TextureResType.plistType)
	else
		return Button:__origin_create(resNormal, resPressed, resDisabled)
	end
end

Button.__origin_loadTextureNormal = Button.loadTextureNormal
function Button:loadTextureNormal(respath)
	local sprFrame = _InstSpriteFrameCache:getSpriteFrame(respath)
	if sprFrame then
		self:__origin_loadTextureNormal(respath, ccui.TextureResType.plistType)
	else
		self:__origin_loadTextureNormal(respath)
	end
end

Button.__origin_loadTexturePressed = Button.loadTexturePressed
function Button:loadTexturePressed(respath)
	local sprFrame = _InstSpriteFrameCache:getSpriteFrame(respath)
	if sprFrame then
		self:__origin_loadTexturePressed(respath, ccui.TextureResType.plistType)
	else
		self:__origin_loadTexturePressed(respath)
	end
end

Button.__origin_loadTextureDisabled = Button.loadTextureDisabled
function Button:loadTextureDisabled(respath)
	local sprFrame = _InstSpriteFrameCache:getSpriteFrame(respath)
	if sprFrame then
		self:__origin_loadTextureDisabled(respath, ccui.TextureResType.plistType)
	else
		self:__origin_loadTextureDisabled(respath)
	end
end