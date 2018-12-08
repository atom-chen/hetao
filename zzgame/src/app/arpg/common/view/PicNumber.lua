-------------------------
-- 图片数字
-------------------------
module("ui", package.seeall)

clsPicNumber = class("clsPicNumber", function() return ccui.Layout:create() end)

function clsPicNumber:ctor(parent)
	self:EnableNodeEvents()
--	self.iValue = nil
	self.iWidth = 0
	self.iHeight = 0
	if parent then KE_SetParent(self, parent) end
end

function clsPicNumber:dtor()
	
end

function clsPicNumber:SetValue(iValue)
	assert(iValue>=0, "参数不可为负数: "..iValue)
	if self.iValue == iValue then return end
	self.iValue = iValue
	
	self.mSprList = self.mSprList or {}
	for _, spr in pairs(self.mSprList) do
		KE_SafeDelete(spr)
	end
	self.mSprList = {}
	
	local tblValue = math.Num2Tbl(iValue)
	local curX = 0
	for i = #tblValue, 1, -1 do
		local spr = utils.CreateSprite(string.format("uistu/common/texts/battle_num%d.png",tblValue[i]))
		spr:setAnchorPoint(cc.p(0,0.5))
		spr:setPositionX(curX)
		KE_SetParent(spr, self)
		table.insert(self.mSprList, spr)
		curX = curX + spr:getContentSize().width
	end
	
	self.iWidth = curX
	self.iHeight = self.mSprList[1]:getContentSize().height
end

function clsPicNumber:GetValue()
	return self.iValue
end

function clsPicNumber:GetSize()
	return self.iWidth, self.iHeight
end


function clsPicNumber:_FixMaskPos()
	if self.mMaskSpr and self.bShowMask then
		local pos = self.mBlockLayer:convertToNodeSpace(cc.p(GAME_CONFIG.DESIGN_W_2, GAME_CONFIG.DESIGN_H_2))
		self.mMaskSpr:setPosition(pos)
	end
end

-- bModal：是否模态
-- bShowMask：是否显示遮罩 
-- OnClickBlock：遮罩的点击回调
function clsPicNumber:SetModal(bModal, bShowMask, OnClickBlock, sMaskPath)
	assert(bModal==true or bModal==false)
	assert(bShowMask==true or bShowMask==false)
	if OnClickBlock then self.OnClickBlock = OnClickBlock end
	
	-- 阻挡
	if self.mBlockLayer then
		self.mBlockLayer:setVisible(bModal)
	elseif bModal then
		self.mBlockLayer = cc.Layer:create()
		self.mBlockLayer:setLocalZOrder(-1)
		KE_SetParent(self.mBlockLayer, self)
		
		local function onToucheBegan(touch, event)
			return utils.IsNodeRealyVisible(self.mBlockLayer)
		end
		local function onToucheMoved(touch, event) 
			
		end
		local function onToucheEnded(touch, event) 
			if self.OnClickBlock then self.OnClickBlock(self) end
		end
		local listener = cc.EventListenerTouchOneByOne:create()
		listener:registerScriptHandler(onToucheBegan, cc.Handler.EVENT_TOUCH_BEGAN)
		listener:registerScriptHandler(onToucheMoved, cc.Handler.EVENT_TOUCH_MOVED)
		listener:registerScriptHandler(onToucheEnded, cc.Handler.EVENT_TOUCH_ENDED)
		self.mBlockLayer:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self.mBlockLayer)
		listener:setSwallowTouches(true)
	end
	
	-- 遮罩
	self.bShowMask = bShowMask
	if self.mMaskSpr then
		self.mMaskSpr:setVisible(bShowMask)
	elseif bShowMask then
		self.mMaskSpr = utils.CreateScale9Sprite(sMaskPath or "uistu/common/mask.png")
		self.mMaskSpr:setPreferredSize(cc.size(GAME_CONFIG.DESIGN_W+2, GAME_CONFIG.DESIGN_H+2))
		KE_SetParent(self.mMaskSpr, self.mBlockLayer)
	end
	
	self:_FixMaskPos()
end
