------------------
-- 扩展
------------------
local _InstTextureCache = cc.Director:getInstance():getTextureCache()
local _InstSpriteFrameCache = cc.SpriteFrameCache:getInstance()
local _InstAnimationCache = cc.AnimationCache:getInstance()
local _InstArmatureDataMgr = ccs.ArmatureDataManager:getInstance()


local Scale9Sprite = cc.Scale9Sprite 

Scale9Sprite.__origin_create = Scale9Sprite.create
function Scale9Sprite:create(respath)
	local sprFrame = _InstSpriteFrameCache:getSpriteFrame(respath)
	if sprFrame then
		return Scale9Sprite:createWithSpriteFrameName(respath)
	else
		return Scale9Sprite:__origin_create(respath)
	end
end