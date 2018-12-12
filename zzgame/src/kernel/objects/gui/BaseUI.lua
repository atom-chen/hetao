-------------------------
-- UI基类
-------------------------
clsBaseUI = class("clsBaseUI", function() return cc.Layer:create() end, clsCoreObject)

function clsBaseUI:ctor(parent, sCfgFile, bSkipFontAdapt)
	self:EnableNodeEvents()
	clsCoreObject.ctor(self)
	if parent then KE_SetParent(self, parent) end

	if sCfgFile then 
		local rootlayer = utils.LoadCsb(sCfgFile)
		self:addChild(rootlayer)
		utils.getNamedNodes(rootlayer, self)
		self._root_layer_ = rootlayer
		if not bSkipFontAdapt then
			utils.AdaptCsbFonts(rootlayer)
		end
	end
	self:ForceAdapt()
	
	g_EventMgr:AddListener(self, "syswnd_size_changed", function()
		self:ForceAdapt()
	end)
end

function clsBaseUI:dtor()
	
end

function clsBaseUI:GetAdaptInfo()
	return self._adapt_info
end

function clsBaseUI:ForceAdapt()
	if self._root_layer_ and self.RootView then
		self._adapt_info = utils.AdaptLayout(self._root_layer_)
	end
end

function clsBaseUI:_FixMaskPos()
	if self.mMaskSpr and self.bShowMask then
		local pos = self.mBlockLayer:convertToNodeSpace(cc.p(GAME_CONFIG.DESIGN_W_2, GAME_CONFIG.DESIGN_H_2))
		self.mMaskSpr:setPosition(pos)
	end
end

function clsBaseUI:SetCloseWhenClickMask(bFlag)
	self.bCloseWhenClickMask = bFlag
end

-- bModal：是否模态
-- bShowMask：是否显示遮罩 
-- bCloseWhenClickMask：点击遮罩时是否关闭界面
function clsBaseUI:SetModal(bModal, bShowMask, bCloseWhenClickMask, sMaskPath)
	assert(bModal==true or bModal==false)
	assert(bShowMask==true or bShowMask==false)
	self.bCloseWhenClickMask = bCloseWhenClickMask
	self._bModal = bModal
	self.bShowMask = bShowMask
	
	-- 创建阻挡
	if self.mBlockLayer then
		self.mBlockLayer:setVisible(bModal)
	elseif bModal then
		local btnmask = ccui.Layout:create()
		self.mBlockLayer = btnmask
		btnmask:setContentSize(GAME_CONFIG.DESIGN_W+20, GAME_CONFIG.DESIGN_H*20)
		btnmask:setAnchorPoint({ x = 0, y = 0 })
		btnmask:setTouchEnabled(true)
		btnmask:addTouchEventListener( function(sender, touchType)
			if touchType ~= 2 then return end
			if self.OnClickBlock then 
				self.OnClickBlock() 
			else
				if self.bCloseWhenClickMask then
					self:removeSelf()
				end
			end
		end )
		self:addChild(btnmask,-1)
	end

	-- 创建遮罩
	if self.mMaskSpr then
		self.mMaskSpr:setVisible(bShowMask)
	elseif bShowMask then
		self.mMaskSpr = cc.Scale9Sprite:create(sMaskPath or "uistu/common/mask.png")
		self.mMaskSpr:setPreferredSize(cc.size(GAME_CONFIG.DESIGN_W+2, GAME_CONFIG.DESIGN_H*2))
		self.mBlockLayer:addChild(self.mMaskSpr)
	end
	
	-- 调整遮罩位置
	self:_FixMaskPos()
end

function clsBaseUI:PlayPopAni()
--	if self.mPopAni then return end
--	self:setScale(0.8)
--	self.mPopAni = self:runAction(cc.Sequence:create(
--		cc.ScaleTo:create(0.15, 1.15),
--		cc.ScaleTo:create(0.1, 1),
--		cc.CallFunc:create(function() self.mPopAni=nil end)
--	))
	if self.mPopAni then return end
	self:setPositionX(360)
	self.mPopAni = self:runAction(cc.Sequence:create(
		cc.MoveTo:create(0.1, cc.p(0,self:getPositionY())),
		cc.CallFunc:create(function() self.mPopAni=nil end)
	))
end

function clsBaseUI:removeSelf()
	if not self._playCloseAni then return KE_SafeDelete(self) end
	if self._closing then return end
	self._closing = true
	self:runAction(cc.Sequence:create(
		cc.MoveTo:create(0.24, cc.p(720,self:getPositionY())),
		cc.RemoveSelf:create()
	))
end
