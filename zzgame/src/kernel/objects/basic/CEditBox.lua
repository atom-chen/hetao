------------------
-- 扩展
------------------
local _InstTextureCache = cc.Director:getInstance():getTextureCache()
local _InstSpriteFrameCache = cc.SpriteFrameCache:getInstance()
local _InstAnimationCache = cc.AnimationCache:getInstance()
local _InstArmatureDataMgr = ccs.ArmatureDataManager:getInstance()


local EditBox = ccui.EditBox

EditBox.__origin_create = EditBox.create
function EditBox:create(size, normal9SpriteBg, resType)
	if resType then
		return EditBox:__origin_create(size, normal9SpriteBg, resType)
	end
	
	local sprFrame = _InstSpriteFrameCache:getSpriteFrame(normal9SpriteBg)
	if sprFrame then
		return EditBox:__origin_create(size, normal9SpriteBg, ccui.TextureResType.plistType)
	else
		return EditBox:__origin_create(size, normal9SpriteBg)
	end
end

function EditBox:setString(text)
	self:setText(text)
end

function EditBox:getString()
	return self:getText()
end

function EditBox:SetSensitive(b)
	self._bSensitive = b
	if b then
		self:setInputFlag(cc.EDITBOX_INPUT_FLAG_PASSWORD)
	else
		self:setInputFlag(cc.EDITBOX_INPUT_FLAG_INITIAL_CAPS_WORD)
	end
	self:setText( self:getText() )
end

function EditBox:IsSensitive()
	return self._bSensitive
end

function EditBox:ToggleSensitive()
	self:SetSensitive(not self._bSensitive)
end

if device.platform ~= "ios" then
	EditBox.__origin_registerScriptEditBoxHandler = EditBox.registerScriptEditBoxHandler
	function EditBox:registerScriptEditBoxHandler(callback)
		if self._bAllReadey then 
			self._callback = callback
			return 
		end
		self._bAllReadey = true
		EditBox.__origin_registerScriptEditBoxHandler(self, function(evenName, sender)
			if evenName == "began" then
				g_CurEditY = sender._worldY
				print("---------", evenName, sender:getPositionY(), g_CurEditY)
			end
			if self._callback then self._callback(evenName, sender) end
		end)
	end
end

function EditBox:FixWorldY()
	local Point = self:convertToWorldSpace(cc.p(0,0))
	self._worldY = Point.y
end
