-------------------------
-- 投注蓝
-------------------------
module("ui", package.seeall)

clsBetBasketV = class("clsBetBasketV", clsBaseUI)

function clsBetBasketV:ctor(parent,gameArg)
	clsBaseUI.ctor(self, parent, "uistu/BetBasketV.csb")
	self.ListViewOrders:setItemModel(self.ListItem)
    self.ListViewOrders:setScrollBarEnabled(false)
	KE_SafeDelete(self.ListItem)
	self.ListItem = nil
	
	self.BkgFrame:setPositionY(GAME_CONFIG.DESIGN_H_2)
	
	utils.RegClickEvent(self.BtnClose, function() self:removeSelf() end)

	utils.RegClickEvent(self.BtnBet, function() 
		self.gameObj:SendBill()
	end)
	
	g_EventMgr:AddListener(self, "GAME_BILL_SUCC", function(thisObj, billId, oneBill, billPaper, gameObj)
		self:removeSelf()
	end)
    g_EventMgr:AddListener(self,"OVERTIPS",function()
        self:removeSelf()
    end,self)
--	g_EventMgr:AddListener(self, "on_req_user_balance", function(thisObj, recvdata)
--		self:RefleshLblTotal()
--	end)
end

function clsBetBasketV:dtor()
	
end

function clsBetBasketV:RefleshUI(gameObj)
	self.gameObj = gameObj
	
	local billPaper = gameObj:GetBillPaper()
	local billList = billPaper and billPaper:GetBillList() or {}
	
	self.ListViewOrders:removeAllItems()
	
	local titleStr = gameObj.gameArg.name
	if billPaper:GetKithe() then titleStr = titleStr .. "： " .. billPaper:GetKithe() .. "期" end
	local lblTitle = clsRichText.new(titleStr, self.ListViewOrders:getContentSize().width, 26, nil, 26, cc.c3b(32,32,32), 255)
	lblTitle:formatText()
	lblTitle:setContentSize(lblTitle:getRealWidth(),lblTitle:getRealHeight())
	self.ListViewOrders:pushBackCustomItem(lblTitle)
	
	local betCount, totalCost = 0, 0
	if self.gameObj:GetBillPaper() then
		betCount, totalCost = self.gameObj:GetBillPaper():GetTotalInfo(self.gameObj)
	end
	local lblMoney = clsRichText.new("投注金额：#R"..totalCost, self.ListViewOrders:getContentSize().width, 26, nil, 26, cc.c3b(32,32,32), 255)
	lblMoney:formatText()
	lblMoney:setContentSize(lblMoney:getRealWidth(),lblMoney:getRealHeight())
	self.ListViewOrders:pushBackCustomItem(lblMoney)
	self.lblMoney = lblMoney
	
	local lblTip = clsRichText.new("投注明细：", self.ListViewOrders:getContentSize().width, 26, nil, 26, cc.c3b(32,32,32), 255)
	lblTip:formatText()
	lblTip:setContentSize(lblTip:getRealWidth(),lblTip:getRealHeight())
	self.ListViewOrders:pushBackCustomItem(lblTip)
	
	local idx = 3
	for _, oneBill in ipairs(billList) do
		local billInfo = oneBill:GenSenderBill(gameObj)
		if billInfo then
			local sCont = oneBill:GetMenuName(gameObj) .. "：  #R" .. billInfo.names
			local lblBill = clsRichText.new(sCont, self.ListViewOrders:getContentSize().width, 26, nil, 26, cc.c3b(32,32,32), 255)
			lblBill:formatText()
			lblBill:setContentSize(lblBill:getRealWidth(),lblBill:getRealHeight())
			self.ListViewOrders:pushBackCustomItem(lblBill)
			idx = idx + 1
		end
	end
end

function clsBetBasketV:RefleshLblTotal()
	local betCount, totalCost = 0, 0
	if self.gameObj:GetBillPaper() then
		betCount, totalCost = self.gameObj:GetBillPaper():GetTotalInfo(self.gameObj)
	end
	if utils.IsValidCCObject(self.lblMoney) then
		self.lblMoney:setString("投注金额：#R"..totalCost)
	end
end
