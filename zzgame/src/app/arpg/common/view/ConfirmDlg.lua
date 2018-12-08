-------------------------
-- 确认框
-------------------------
module("ui", package.seeall)

clsConfirmDlg = class("clsConfirmDlg", clsBaseUI)

function clsConfirmDlg:ctor(parent)
	clsBaseUI.ctor(self, parent, "uistu/ConfirmDlg.csb")
	
	self.lblTips:setString("")
	self.lblTips:setVisible(false)
--	self._richLbl = clsRichText.new("", 450, 100, nil, 28, cc.c3b(25, 25, 25), 255)
--	self.BkgFrame:addChild(self._richLbl)
--	self._richLbl:setPosition(self.BkgFrame:getContentSize().width*0.5, self.BkgFrame:getContentSize().height*0.65)
	
    utils.RegClickEvent(self.BtnSure, function()
    	local callback = self._callback
		if callback then callback(1) end 
		KE_SafeDelete(self)
	end)
	utils.RegClickEvent(self.BtnCancel, function()
    	local callback = self._callback
    	if callback then callback(0) end 
		KE_SafeDelete(self)
	end)
	
	self.BkgFrame:setPositionY(GAME_CONFIG.DESIGN_H_2)
    --g_EventMgr:FireEvent("showNotice")
end

function clsConfirmDlg:dtor()
	--g_EventMgr:FireEvent("hiddenNotice")
end

function clsConfirmDlg:Reflesh(sTitle, sTips, callback, sOk, sNo, iStyle)
	self._callback = callback
	if sTitle then self.lblTitle:setString(sTitle) end
	if sOk then self.BtnSure:setTitleText(sOk) end
	if sNo then self.BtnCancel:setTitleText(sNo) end
--	if sTips then self.lblTips:setString(sTips) end
	
	if iStyle then
		local sz = self.BkgFrame:getContentSize()
		if iStyle == 1 then
			self.BtnCancel:setVisible(true)
			self.BtnSure:setContentSize(sz.width/2, self.BtnSure:getContentSize().height)
			self.BtnSure:setPositionX(sz.width*0.75)
			self.Line2:setVisible(true)
		elseif iStyle == 2 then
			self.BtnCancel:setVisible(false)
			self.BtnSure:setContentSize(sz.width, self.BtnSure:getContentSize().height)
			self.BtnSure:setPositionX(sz.width*0.5)
			self.Line2:setVisible(false)
		end
	end
	
	if sTips then 
		self._richLbls = self._richLbls or {}
		for _, lbl in pairs(self._richLbls) do KE_SafeDelete(lbl) end
		self._richLbls = {}
		local strTbl = string.split(sTips, "#r")
		logger.dump(strTbl)
		for i, str in ipairs(strTbl) do
			
			local lbl = clsRichText.new(str, 450, 100, nil, 28, cc.c3b(25, 25, 25), 255)
			self.BkgFrame:addChild(lbl)
			lbl:formatText()
			lbl:setContentSize(lbl:getRealWidth(),lbl:getRealHeight())
			lbl:setPosition(self.BkgFrame:getContentSize().width*0.5, self.BkgFrame:getContentSize().height*0.65+((#strTbl+1)/2-i)*32)
			table.insert(self._richLbls, lbl)
			print("-----", lbl:getRealWidth(), lbl:getContentSize().width, str)
		end
	end
end

