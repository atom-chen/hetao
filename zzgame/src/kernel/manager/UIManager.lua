-------------------------
-- UI管理器
-------------------------
ClsUIManager = class("ClsUIManager")
ClsUIManager.__is_singleton = true

function ClsUIManager:ctor()
	self.tAllGui = {}
	self.tViewList = {}
	self._viewStack = {}
	--
	self._allConfirm = {}
	--
	self.mNoticeWnd = nil
end

function ClsUIManager:dtor()
	self:DestroyAllWindow()
end

function ClsUIManager:DestroyAllWindow()
	-- 销毁公告栏
	self:DestroyNoticeWnd()
	
	-- 销毁窗口
	for _, wnd in pairs(self.tAllGui) do
		KE_SafeDelete(wnd)
	end
	self.tAllGui = {}
	self.tViewList = {}
	
	-- 销毁二次确认框
end


------------------------
-- 
------------------------

-- 创建窗口
function ClsUIManager:CreateSharedWindow(cls_name, iLayerId, argInfo)
	assert(ui[cls_name], "未定义类："..cls_name)
	local Parent = ClsLayerManager.GetInstance():GetLayer(iLayerId)
	local panel_cls = ui[cls_name]
	if not Parent or not panel_cls then 
		assert(false, "not valid layer")
		return 
	end
	
	if self.tAllGui[cls_name] then
		if utils.IsValidCCObject(self.tAllGui[cls_name]) then
			KE_SetParent(self.tAllGui[cls_name], Parent)
			return self.tAllGui[cls_name]
		end
	end
	
	logger.normal("创建界面", cls_name)
	self.tAllGui[cls_name] = panel_cls.new(Parent, argInfo)
	self.tAllGui[cls_name]:AddScriptHandler(const.CORE_EVENT.cleanup, function()
		logger.normal("销毁界面", cls_name)
		self.tAllGui[cls_name] = nil
		self:Pop(cls_name)
	end)
	
	return self.tAllGui[cls_name]
end

-- 销毁窗口
function ClsUIManager:DestroyWindow(cls_name)
	if cls_name==nil then return end
	if self.tAllGui[cls_name] then
		KE_SafeDelete(self.tAllGui[cls_name])
		self.tAllGui[cls_name] = nil
	end
end

-- 销毁窗口
function ClsUIManager:DestroyWindowEx(Wnd)
	local cls_name = self:GetKeyOfWindow(Wnd)
	if cls_name then self:DestroyWindow(cls_name) end
end

-- 隐藏窗口
function ClsUIManager:HideWindow(cls_name)
	if not cls_name then return end
	assert(ui[cls_name], "未定义的类："..cls_name)
	if utils.IsValidCCObject(self.tAllGui[cls_name]) then
		self.tAllGui[cls_name]:setVisible(false)
	end
end

-- 获取窗口
function ClsUIManager:GetWindow(cls_name)
	if not cls_name then return nil end
	if self.tAllGui[cls_name] then
		if tolua.isnull(self.tAllGui[cls_name]) then
			self.tAllGui[cls_name] = nil
			return nil
		else
			return self.tAllGui[cls_name]
		end
	end
	return nil
end

function ClsUIManager:GetKeyOfWindow(Wnd)
	if not Wnd then return nil end
	for cls_name, WndObj in pairs(self.tAllGui) do 
		if WndObj == Wnd then
			return cls_name
		end
	end
	return nil 
end

function ClsUIManager:DumpDebugInfo()
	logger.normal("窗口总数量", table.size(self.tAllGui))
	for cls_name, wnd in pairs(self.tAllGui) do
		logger.normal(cls_name, wnd, tolua.isnull(wnd))
	end
end

function ClsUIManager:Push(cls_name)
	local bFinded = false
	for _, name in ipairs(self.tViewList) do 
		if name == cls_name then 
			bFinded = true
		end
		if self:GetWindow(name) then
			self:GetWindow(name):setVisible(false)
		end
	end
	if not bFinded then
		table.insert(self.tViewList, cls_name)
	end
	logger.dump(self.tViewList)
end

function ClsUIManager:Pop(cls_name)
	local cnt = #self.tViewList
	for i=cnt, 1, -1 do
		local name = self.tViewList[i]
		if name == cls_name then
			table.remove(self.tViewList, i)
		end
	end
	logger.dump(self.tViewList)
	local toppest = self:GetWindow(self.tViewList[#self.tViewList])
	if toppest then toppest:setVisible(true) end 
end

------------------------
-- 
------------------------
-- 显示一级视图（场景窗口，同一时刻只显示一个，上层没有界面时，退出app）
function ClsUIManager:ShowView(cls_name, argInfo)
	local Wnd = self:CreateSharedWindow(cls_name, const.LAYER_VIEW, argInfo)
	if not Wnd then return end
	self:Push(cls_name)
	Wnd:setVisible(true)
	table.insert(self._viewStack, Wnd)
	return Wnd
end

-- 显示二级视图（全屏窗口，同一时刻只显示一个）
function ClsUIManager:ShowPanel(cls_name, argInfo, bCloseWhenClickMask, bShowMask)
	if bCloseWhenClickMask == nil then bCloseWhenClickMask = true end
	local Wnd = self:CreateSharedWindow(cls_name, const.LAYER_PANEL, argInfo)
	if not Wnd then return end
	Wnd._playCloseAni = true
	self:Push(cls_name)
	if bShowMask == nil then bShowMask = false end
	print("是否显示mask", bShowMask)
	Wnd:SetModal(true, bShowMask, bCloseWhenClickMask)
	Wnd:setVisible(true)
	Wnd:PlayPopAni()
	table.insert(self._viewStack, Wnd)
	return Wnd
end

-- 显示弹窗（非全屏窗口）
function ClsUIManager:ShowPopWnd(cls_name, argInfo, bCloseWhenClickMask, bShowMask)
	if bCloseWhenClickMask == nil then bCloseWhenClickMask = true end
	local Wnd = self:CreateSharedWindow(cls_name, const.LAYER_POPWND, argInfo)
	if not Wnd then return end
	if bShowMask == nil then bShowMask = true end
	Wnd:SetModal(true, bShowMask, bCloseWhenClickMask)
	Wnd:setVisible(true)
	table.insert(self._viewStack, Wnd)
--	Wnd:PlayPopAni()
	return Wnd
end

-- 显示模态对话框（非全屏窗口）
function ClsUIManager:ShowDialog(cls_name, argInfo)
	local Wnd = self:CreateSharedWindow(cls_name, const.LAYER_DLG, argInfo)
	if not Wnd then return end
	Wnd:SetModal(true, true, false)
	Wnd:setVisible(true)
	table.insert(self._viewStack, Wnd)
--	Wnd:PlayPopAni()
	return Wnd
end

-- 二次确认框（非全屏窗口）
function ClsUIManager:PopConfirmDlg(Key, sTitle, sTips, callback, sOk, sNo, iStyle, bCloseWhenClickMask)
	if Key ~= nil and utils.IsValidCCObject(self._allConfirm[Key]) then
		self._allConfirm[Key]:Reflesh(sTitle, sTips, callback, sOk, sNo, iStyle)
		return self._allConfirm[Key]
	end
	local Parent = ClsLayerManager.GetInstance():GetLayer(const.LAYER_DLG)
	if not Parent then return end
	local cfm = ui.clsConfirmDlg.new(Parent)
	if Key ~= nil then
		self._allConfirm[Key] = cfm
	end
	if bCloseWhenClickMask == nil then bCloseWhenClickMask = false end 
	cfm:SetModal(true,true,bCloseWhenClickMask)
	cfm:Reflesh(sTitle, sTips, callback, sOk, sNo, iStyle)
	return cfm
end

function ClsUIManager:PopConfirmDlg2(Key, sTitle, sTips, callback, sOk, sNo, iStyle)
	if Key ~= nil and utils.IsValidCCObject(self._allConfirm[Key]) then
		self._allConfirm[Key]:Reflesh(sTitle, sTips, callback, sOk, sNo, iStyle)
		return self._allConfirm[Key]
	end
	local Parent = ClsLayerManager.GetInstance():GetLayer(const.LAYER_DLG)
	if not Parent then return end
	local cfm = ui.clsConfirmDlg2.new(Parent)
	if Key ~= nil then
		self._allConfirm[Key] = cfm
	end
	cfm:SetModal(true,true,false)
	cfm:Reflesh(sTitle, sTips, callback, sOk, sNo, iStyle)
	return cfm
end

function ClsUIManager:CloseConfirmDlg(Key)
	if Key ~= nil and utils.IsValidCCObject(self._allConfirm[Key]) then
		KE_SafeDelete(self._allConfirm[Key])
		self._allConfirm[Key] = nil
	end
end


function ClsUIManager:DestoryToppestView()
	local Parent = ClsLayerManager.GetInstance():GetLayer(const.LAYER_DLG)
	local wnds = Parent:getChildren()
	local cnt = #wnds
	if cnt > 0 then
		if wnds[cnt].quitListener then
			wnds[cnt]:quitListener()
			return true
		end
		wnds[cnt]:removeSelf()
		return true
	end
	
	local Parent = ClsLayerManager.GetInstance():GetLayer(const.LAYER_POPWND)
	local wnds = Parent:getChildren()
	local cnt = #wnds
	if cnt > 0 then
		if wnds[cnt].quitListener then
			wnds[cnt]:quitListener()
			return true
		end
		self:DestroyWindowEx(wnds[cnt])
		return true
	end
	
	local Parent = ClsLayerManager.GetInstance():GetLayer(const.LAYER_PANEL)
	local wnds = Parent:getChildren()
	local cnt = #wnds
	if cnt > 0 then
		if wnds[cnt].quitListener then
			wnds[cnt]:quitListener()
			return true
		end
		self:DestroyWindowEx(wnds[cnt])
		return true
	end
	
	local Parent = ClsLayerManager.GetInstance():GetLayer(const.LAYER_VIEW)
	local wnds = Parent:getChildren()
	local cnt = #wnds
	if cnt > 0 then
		if wnds[cnt].quitListener then
			wnds[cnt]:quitListener()
			return true
		end
	end
	
	return false
end

------------------------------------------------------------------

-- 公告条
local NOCOLOR = cc.c3b(66,66,66)
local BKG_WIDTH = 750
local BKG_HEIGHT = 40
local BKG_WIDTH_2 = 360
local BKG_HEIGHT_2 = 20
function ClsUIManager:DestroyNoticeWnd()
	KE_SafeDelete(self.mNoticeWnd)
	self.mNoticeWnd = nil
end
function ClsUIManager:UpdateNotice(noticeWnd)
	noticeWnd:scheduleUpdate(function(dt)
		local LastLabel = noticeWnd.tNoticeLabelList[#noticeWnd.tNoticeLabelList]
		local CanAdd = (not LastLabel) or (100 + LastLabel:getPositionX() + LastLabel:getContentSize().width*LastLabel:getScale() <= BKG_WIDTH)
		if not CanAdd then return end
		local curStr = self.tNoticeStrList[1]
		
		if CanAdd and curStr then
			local LabelNotice = utils.CreateLabel(curStr, 24, NOCOLOR)
			KE_SetParent(LabelNotice, noticeWnd)
			LabelNotice:setAnchorPoint(cc.p(0,0.5))
			table.insert(noticeWnd.tNoticeLabelList, LabelNotice)
			table.remove(self.tNoticeStrList, 1)
			
			LabelNotice:setPosition(BKG_WIDTH,BKG_HEIGHT_2)
			local UseTime = (LabelNotice:getContentSize().width+BKG_WIDTH) / 64 
			LabelNotice:runAction(cc.Sequence:create(
				cc.MoveTo:create(UseTime, cc.p(-LabelNotice:getContentSize().width, BKG_HEIGHT_2)),
				cc.CallFunc:create(function()
					KE_SafeDelete(noticeWnd.tNoticeLabelList[1])
					table.remove(noticeWnd.tNoticeLabelList, 1)
				--	if #noticeWnd.tNoticeLabelList == 0 then
				--		self:DestroyNoticeWnd()
				--	end
				end)
			))
		end
	end)
end
function ClsUIManager:CreateNoticeWnd()
	if utils.IsValidCCObject(self.mNoticeWnd) then return self.mNoticeWnd end
	local tipslayer = ClsLayerManager.GetInstance():GetLayer(const.LAYER_TOAST)
	if not tipslayer then return nil end
	if utils.IsValidCCObject(tipslayer.mNoticeWnd) then 
		self.mNoticeWnd = tipslayer.mNoticeWnd 
		return tipslayer.mNoticeWnd 
	end
	tipslayer.mNoticeWnd = ccui.Layout:create() 
	self.mNoticeWnd = tipslayer.mNoticeWnd
	local noticeWnd = self.mNoticeWnd
	noticeWnd.tNoticeLabelList = {}
	noticeWnd:setAnchorPoint(cc.p(0.5,0.5))
	noticeWnd:setContentSize(cc.size(BKG_WIDTH, BKG_HEIGHT))
	if BKG_WIDTH < GAME_CONFIG.DESIGN_W-2 then
		noticeWnd:setClippingEnabled(true)
	end
	noticeWnd:AddScriptHandler(const.CORE_EVENT.exit, function()
		noticeWnd.tNoticeLabelList = {}
		noticeWnd = nil
	end)
	noticeWnd:setBackGroundImage("uistu/common/mask.png")
	noticeWnd:setBackGroundImageScale9Enabled(true)
	noticeWnd:setPosition(GAME_CONFIG.DESIGN_W/2, GAME_CONFIG.DESIGN_H-80)
	KE_SetParent(noticeWnd, tipslayer)
	self.tNoticeStrList = self.tNoticeStrList or {}
	self:UpdateNotice(noticeWnd)
end
function ClsUIManager:SetNoticeWnd(wnd)
	if self.mNoticeWnd == wnd then
		return wnd
	end
	self.mNoticeWnd = wnd
	local noticeWnd = self.mNoticeWnd
	noticeWnd.tNoticeLabelList = {}
	noticeWnd:AddScriptHandler(const.CORE_EVENT.exit, function()
		noticeWnd.tNoticeLabelList = {}
		noticeWnd = nil
	end)
	BKG_WIDTH = wnd:getContentSize().width
	BKG_HEIGHT = wnd:getContentSize().height
	BKG_WIDTH_2 = BKG_WIDTH/2
	BKG_HEIGHT_2 = BKG_HEIGHT/2
	self.tNoticeStrList = self.tNoticeStrList or {}
	self:UpdateNotice(noticeWnd)
	return wnd
end
function ClsUIManager:TellNotice(sNotice,iOrder)
	iOrder = iOrder or 1 
	if not sNotice or utils.IsWhiteSpace(sNotice) then return end
	self.tNoticeStrList = self.tNoticeStrList or {}
	
	if #self.tNoticeStrList <= 300 then 
        sNotice = string.gsub(sNotice, "\r\n", "")
		table.insert(self.tNoticeStrList, sNotice)
	end
	
	self:CreateNoticeWnd()
end

-- 显示通知消息
function ClsUIManager:TellMe(Txt, DelayTime)
	if not Txt or utils.IsWhiteSpace(Txt) then return end
	local Parent = ClsLayerManager.GetInstance():GetLayer(const.LAYER_TOAST)
	if not Parent then return end
	
	Parent._all_tellme = Parent._all_tellme or {}
	local all_tellme = Parent._all_tellme
	
	for obj, _ in pairs(all_tellme) do
		if obj._tellStr == Txt then return end
	end
	
	-- 弹出位置
	local PosX, BeginY = GAME_CONFIG.DESIGN_W_2, GAME_CONFIG.DESIGN_H_2-42
	
	-- 创建控件
	local TellPanel = cc.Node:create()
	KE_SetParent(TellPanel, Parent)
	local BkgTell = utils.CreateScale9Sprite("uistu/bg/tellme.png")
	KE_SetParent(BkgTell, TellPanel)
	local LabelTell = utils.CreateLabel(Txt, 26)
	KE_SetParent(LabelTell, TellPanel)
	BkgTell:setPreferredSize(cc.size(LabelTell:getContentSize().width*LabelTell:getScale()+50, 48))
	TellPanel:setPosition(PosX,BeginY)
	all_tellme[TellPanel] = true
	TellPanel._tellStr = Txt
	
	-- 调整位置
	for Pnl, _ in pairs(all_tellme) do
		Pnl:setPosition(PosX, Pnl:getPositionY()+50)
	end
	
	-- 定时销毁
	TellPanel:runAction(cc.Sequence:create(
		cc.DelayTime:create(DelayTime or 2),
		cc.CallFunc:create(function ()
			KE_SafeDelete(TellPanel)
			all_tellme[TellPanel] = nil
		end)
	))
end

-- 弹幕
function ClsUIManager:TellBarrage(sCont)
	if not sCont or utils.IsWhiteSpace(sCont) then return end 
	local Parent = ClsLayerManager.GetInstance():GetLayer(const.LAYER_TOAST)
	if not Parent then return end
	
	local LabelBarrage = utils.CreateLabel(sCont, 24)
	KE_SetParent(LabelBarrage, Parent)
	LabelBarrage:setAnchorPoint(cc.p(0,0.5))
	local y = math.random(200,GAME_CONFIG.DESIGN_H-80)
	LabelBarrage:setPosition(GAME_CONFIG.DESIGN_W,y)
	
	local UseTime = (LabelBarrage:getContentSize().width+GAME_CONFIG.DESIGN_W) / 128 
	LabelBarrage:runAction(cc.Sequence:create(
		cc.MoveTo:create(UseTime, cc.p(-LabelBarrage:getContentSize().width, y)),
		cc.RemoveSelf:create()
	))
end
