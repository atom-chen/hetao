-------------------------
-- 复选框
-------------------------
module("ui", package.seeall)

clsCheckButton = class("clsCheckButton", function() return ccui.Button:create() end)

function clsCheckButton:ctor(parent, normalImg, checkedImg, wid, hei)
	if parent then KE_SetParent(self, parent) end
	
	self._clickAble = true
	
	self:setScale9Enabled(true)
	
	if normalImg and normalImg ~= "" then
		self._normalSpr = cc.Scale9Sprite:create(normalImg)
		self:addChild(self._normalSpr)
	end
	if checkedImg and checkedImg ~= "" then
		self._checkedSpr = cc.Scale9Sprite:create(checkedImg)
		self:addChild(self._checkedSpr)
	end
	
	if self._normalSpr then
		local sz = self._normalSpr:getContentSize()
		wid = wid or sz.width
		hei = hei or sz.height
		self:setContentSize(wid,hei)
		
		self._normalSpr:setContentSize(wid,hei)
		self._normalSpr:setPosition(wid/2,hei/2)
		
		if self._checkedSpr then
			self._checkedSpr:setContentSize(wid,hei)
			self._checkedSpr:setPosition(wid/2,hei/2)
		end
	else
		wid = wid or 100
		hei = hei or 64
		self:setContentSize(wid,hei)
	end
	
	self:SetSelectedQuiet(false)
	
	utils.RegClickEvent(self, function() 
		if self._clickAble then 
			self:SetSelected(not self._bSelected)
		end
	end)
end

function clsCheckButton:dtor()
	
end

function clsCheckButton:SetClickAble(bFlag)
	self._clickAble = bFlag
end 

function clsCheckButton:SetSelectCallback(func)
	self._callback = func 
end

function clsCheckButton:SetSelected(bFlag)
	self:SetSelectedQuiet(bFlag)
	
	if self._callback then
		self._callback(self, self._bSelected)
	end
end

function clsCheckButton:SetSelectedQuiet(bFlag)
	self._bSelected = bFlag
	self:RefleshLook()
end

function clsCheckButton:RefleshLook()
	if self._bSelected then 
		if self._normalSpr then self._normalSpr:setVisible(false) end
		if self._checkedSpr then self._checkedSpr:setVisible(true) end
	else
		if self._normalSpr then self._normalSpr:setVisible(true) end
		if self._checkedSpr then self._checkedSpr:setVisible(false) end
	end
end

function clsCheckButton:GetNormalSpr()
	return self._normalSpr
end

function clsCheckButton:GetCheckedSpr()
	return self._checkedSpr
end

function clsCheckButton:IsSelected()
	return self._bSelected
end

function clsCheckButton:SetString(str)
	str = str or ""
	if not self._lblTitle then
		self._lblTitle = utils.CreateLabel(str, 28)
		self:addChild(self._lblTitle)
		local sz = self:getContentSize()
		self._lblTitle:setPosition(sz.width/2, sz.height/2)
		self._lblTitle:setColor(cc.c3b(111,111,111))
	else
		self._lblTitle:setString(str)
	end
end

function clsCheckButton:SetSize(wid, hei)
	self:setContentSize(cc.size(wid,hei))
	if self._lblTitle then self._lblTitle:setPosition(wid/2,hei/2) end
	if self._normalSpr then self._normalSpr:setContentSize(wid,hei) self._normalSpr:setPosition(wid/2,hei/2) end
	if self._checkedSpr then self._checkedSpr:setContentSize(wid,hei) self._checkedSpr:setPosition(wid/2,hei/2) end
end
