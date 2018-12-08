-------------------------
-- 引导界面
-------------------------
module("guide", package.seeall)

local FIX_INTERVAL = 10
local WAIT_SECONDS = 3

local clsGuidePanelBase = class("clsGuidePanelBase", function() return cc.Node:create() end)

function clsGuidePanelBase:ctor(parent)
	if parent then KE_SetParent(self, parent) end
end

function clsGuidePanelBase:dtor()
	
end

----------------------------------------

clsGuidePanel = class("clsGuidePanel", clsGuidePanelBase)

function clsGuidePanel:ctor(parent)
	logger.drama("创建指引面板", display.width, display.height)
	clsGuidePanelBase.ctor(self,parent)
	self:setContentSize(cc.size(display.width,display.height))
	
	--
	self._MAX_WAIT_TIME = utils.Second2Frame(WAIT_SECONDS) / FIX_INTERVAL	 --WAIT_SECONDS秒内检测不到指引按钮，强制中断
	self._CurWaitTime = self._MAX_WAIT_TIME		--WAIT_SECONDS秒内检测不到指引按钮，强制中断
	self._IsAgentSprVisible = true				--焦点按钮的可见性
	
	--
	self:InitView()
	self:FixAgentSprPos()
	
	self._tmr_fix_agent = KE_SetInterval(FIX_INTERVAL, function()
		self:FixAgentSprPos()
	end)
	ClsGuideMgr.GetInstance():AddListener(self, "step_changed", function(thisObj)
		self:FixAgentSprPos()
	end)
	ClsGuideMgr.GetInstance():AddListener(self, "reg_new_btn", function(thisObj)
		self:FixAgentSprPos()
	end)
end

function clsGuidePanel:dtor()
	ClsGuideMgr.GetInstance():DelListener(self)
	KE_KillTimer(self._tmr_fix_agent)
	self._tmr_fix_agent = nil 
	logger.drama("销毁指引面板")
end

function clsGuidePanel:IsTouchIn(pTouch, Btn)
	if not Btn then return false end
	local point = Btn:convertTouchToNodeSpace(pTouch)
	local szBtn = Btn:getContentSize()
	local x,y = point.x,point.y
	return x >= 0 and x <= szBtn.width and y >= 0 and y <= szBtn.height 
end

function clsGuidePanel:InitView()
	local bShowMask = true
	local bUseCircle = false
	
	-- 阻挡
	if not self._block_layer then
		self._block_layer = cc.Layer:create()
		KE_SetParent(self._block_layer, self)
		
		local function onToucheBegan(touch, event)
			return not self:IsTouchIn(touch, ClsGuideMgr.GetInstance():GetCurGuideBtn())
		end
		local function onToucheEnded(touch, event) 
			if self:IsTouchIn(touch, ClsGuideMgr.GetInstance():GetCurGuideBtn()) then
				self._CurWaitTime = self._MAX_WAIT_TIME
			else 
				self:TipFocusAgentSpr()
			end 
		end
		local listener = cc.EventListenerTouchOneByOne:create()
		listener:registerScriptHandler(onToucheBegan, cc.Handler.EVENT_TOUCH_BEGAN)
		listener:registerScriptHandler(onToucheEnded, cc.Handler.EVENT_TOUCH_ENDED)
		self._block_layer:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self._block_layer)
		listener:setSwallowTouches(true)
	end
	
	-- 再一层
	if not self._AgentSpr then
		self._AgentSpr = cc.Scale9Sprite:create("res/uiface/commons/frames/frame_choosed_1.png")
		self._AgentSpr:setAnchorPoint(cc.p(0.5,0.5))
		KE_SetParent(self._AgentSpr, self)
		
		local function onTouchBegan(pTouch,pEvent)
			return self:IsTouchIn(pTouch, ClsGuideMgr.GetInstance():GetCurGuideBtn())
		end
		local function onTouchEnded(pTouch,pEvent)
			if self:IsTouchIn(pTouch, ClsGuideMgr.GetInstance():GetCurGuideBtn()) then
				self._CurWaitTime = self._MAX_WAIT_TIME
				local OnCallback = ClsGuideMgr.GetInstance():GetCurGuideCallback()
				if OnCallback then
					OnCallback()
				end
				ClsGuideMgr.GetInstance():ToNextStep()
			end 
		end
		local listener = cc.EventListenerTouchOneByOne:create()
		listener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
		listener:registerScriptHandler(onTouchEnded, cc.Handler.EVENT_TOUCH_ENDED)
		listener:setSwallowTouches(false)
		local dispatcher = self._AgentSpr:getEventDispatcher()
		dispatcher:addEventListenerWithSceneGraphPriority(listener,self._AgentSpr)
	end 
	
	-- 遮罩
	if self.mMaskSpr then
		self.mMaskSpr:setVisible(bShowMask)
	elseif bShowMask then
		self.mMaskSpr = cc.Scale9Sprite:create(sMaskPath or "res/uiface/commons/others/mask.png")
		self.mMaskSpr:setAnchorPoint(cc.p(0,0))
		self.mMaskSpr:setPreferredSize(self:getContentSize())
		KE_SetParent(self.mMaskSpr, self)
	end
	
	-- 跳过指引按钮
	if not self._btnBreakGuide then
		self._btnBreakGuide = utils.CreateButton("res/uiface/commons/buttons/btn_guide_skip.png")
		self._btnBreakGuide:setAnchorPoint(cc.p(1,1))
		self._btnBreakGuide:setPosition(display.width, display.height)
		self._btnBreakGuide:setTitleText("跳过指引")
		KE_SetParent(self._btnBreakGuide, self)
		utils.RegClickEvent(self._btnBreakGuide, function()
			KE_KillTimer(self._tmr_fix_agent)
			self._tmr_fix_agent = nil 
			KE_SetTimeout(1,function() ClsGuideMgr.GetInstance():BreakGuide() end)
		end)
	end
end

function clsGuidePanel:TipFocusAgentSpr()
	utils.TellMe("请点击指定位置") 
	--[[
	if self._IsAgentSprVisible then
		local act_list = {
			cc.FadeTo:create(0.03, 200),
			cc.FadeTo:create(0.03, 255),
			cc.FadeTo:create(0.03, 200),
			cc.FadeTo:create(0.03, 255),
			cc.CallFunc:create(function() self._AgentSpr.ActFocus = nil end),
		}
		if self._AgentSpr.ActFocus then self._AgentSpr:stopAction(self._AgentSpr.ActFocus) end
		self._AgentSpr.ActFocus = self._AgentSpr:runAction(cc.Sequence:create(act_list))
	end
	]]--
end

function clsGuidePanel:ShowAgentSpr(bShow)
	if self._IsAgentSprVisible == bShow then return end
	self._IsAgentSprVisible = bShow
	self._AgentSpr:setVisible(bShow)
end

-- 使焦点始终覆盖在目标指引按钮上
function clsGuidePanel:FixAgentSprPos()
	if not self._AgentSpr then return end 
	
	local InstGuideMgr = ClsGuideMgr.GetInstance()
	local GuideTbl = InstGuideMgr:GetCurGuideTbl()
	self:ShowAgentSpr(GuideTbl~=nil)
	
	if not GuideTbl then 
		self._CurWaitTime = self._CurWaitTime - 1
		if self._CurWaitTime < 0 then
			KE_KillTimer(self._tmr_fix_agent)
			self._tmr_fix_agent = nil 
			InstGuideMgr:FaltalError("等待超时，强制中断")
		end
		return 
	end
	
	local GuideBtn = InstGuideMgr:GetCurGuideBtn()
	if not GuideBtn then
		KE_KillTimer(self._tmr_fix_agent)
		self._tmr_fix_agent = nil 
		InstGuideMgr:FaltalError("找不到指引按钮")
		return 
	end
	
	--
	local pos = utils.ConvertSpaceAR(self, GuideBtn)
	local x,y = pos.x, pos.y
	if self._x ~= x or self._y ~= y then 
		logger.drama("调整焦点位置")
		self._x = x
		self._y = y
		self._AgentSpr:setPosition(x,y)
	end
	
	local BtnSize = GuideBtn:getContentSize()
	local w,h = BtnSize.width, BtnSize.height
	if self._w ~= w and self._h ~= h then 
		logger.drama("调整焦点尺寸")
		self._w = w
		self._h = h
		self._AgentSpr:setPreferredSize(BtnSize)
	end
end
