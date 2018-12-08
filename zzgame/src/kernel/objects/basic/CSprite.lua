------------------
-- 扩展
------------------
local _InstTextureCache = cc.Director:getInstance():getTextureCache()
local _InstSpriteFrameCache = cc.SpriteFrameCache:getInstance()
local _InstAnimationCache = cc.AnimationCache:getInstance()
local _InstArmatureDataMgr = ccs.ArmatureDataManager:getInstance()


local Sprite = cc.Sprite 

Sprite.__origin_create = Sprite.create
function Sprite:create(respath)
	if not respath then
		return Sprite:__origin_create()
	end
	local sprFrame = _InstSpriteFrameCache:getSpriteFrame(respath)
	if sprFrame then
		return Sprite:createWithSpriteFrameName(respath)
	else
		return Sprite:__origin_create(respath)
	end
end

Sprite.__origin_setTexture = Sprite.setTexture

function Sprite:setTexture(respath)
	local sprFrame = _InstSpriteFrameCache:getSpriteFrame(respath)
	if sprFrame then
		self:setSpriteFrame(sprFrame)
	else
		Sprite.__origin_setTexture(self, respath)
	end
end
