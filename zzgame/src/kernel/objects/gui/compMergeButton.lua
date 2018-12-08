-------------------------
-- 合批按钮
-------------------------
clsMergeButton = class("clsMergeButton", function() return ccui.Button:create() end)

function clsMergeButton:ctor(parent,texNormal,texPressed,texDisabled)
	self:EnableNodeEvents()
	if parent then KE_SetParent(self, parent) end
	self:setScale9Enabled(true)
	self:loadTextures(texNormal or "", texPressed or "", texDisabled or "")
end

function clsMergeButton:dtor()
	
end

function clsMergeButton:loadTextures(texNormal, texPressed, texDisabled)
	self:loadTextureNormal(texNormal)
	self:loadTexturePressed(texPressed)
	self:loadTextureDisabled(texDisabled)
end

function clsMergeButton:loadTextureNormal(texNormal)
	if self.mSprNormal then
		KE_SafeDelete(self.mSprNormal)
		self.mSprNormal = nil
	end
	
	if texNormal and texNormal ~= "" then
		self.mSprNormal = xianyou.TextureMerge:getInstance():createSprite(texNormal,false)
	end
	
	if self.mSprNormal then
		local sz = self.mSprNormal:getContentSize()
		self:setContentSize(sz)
		KE_SetParent(self.mSprNormal, self)
		self.mSprNormal:setPosition(sz.width/2, sz.height/2)
	end
end

function clsMergeButton:loadTexturePressed(texPressed)
	if self.mSprPressed then
		KE_SafeDelete(self.mSprPressed)
		self.mSprPressed = nil
	end
	
	if texPressed and texPressed ~= "" then
		self.mSprPressed = xianyou.TextureMerge:getInstance():createSprite(texPressed,false)
	end
	
	if self.mSprPressed then
		local sz = self:getContentSize()
		KE_SetParent(self.mSprPressed, self)
		self.mSprPressed:setPosition(sz.width/2, sz.height/2)
	end
end

function clsMergeButton:loadTextureDisabled(texDisabled)
	if self.mSprDisabled then
		KE_SafeDelete(self.mSprDisabled)
		self.mSprDisabled = nil
	end
	
	if texDisabled and texDisabled ~= "" then
		self.mSprDisabled = xianyou.TextureMerge:getInstance():createSprite(texDisabled,false)
	end
	
	if self.mSprDisabled then
		local sz = self:getContentSize()
		KE_SetParent(self.mSprDisabled, self)
		self.mSprDisabled:setPosition(sz.width/2, sz.height/2)
	end
end
