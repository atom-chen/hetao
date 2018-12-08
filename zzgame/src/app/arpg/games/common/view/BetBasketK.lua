-------------------------
-- 投注蓝
-------------------------
module("ui", package.seeall)

clsBetBasketK = class("clsBetBasketK", clsBaseUI)

function clsBetBasketK:ctor(parent)
	clsBaseUI.ctor(self, parent, "uistu/BetBasketK.csb")
	
	self.lbl1 = clsRichText.new("", 450, 28, nil, 28, cc.c3b(0, 0, 0), 255)
	self.lbl2 = clsRichText.new("", 450, 28, nil, 28, cc.c3b(0, 0, 0), 255)
	self.lbl3 = clsRichText.new("", 450, 28, nil, 28, cc.c3b(0, 0, 0), 255)
--	self.BkgFrame:addChild(self.lbl1)
--	self.BkgFrame:addChild(self.lbl2)
--	self.BkgFrame:addChild(self.lbl3)
	self.ListView_2:setScrollBarEnabled(false)
	utils.RegClickEvent(self.BtnCancel, function() 
		self:removeSelf() 
	end)
	utils.RegClickEvent(self.BtnSure, function() 
		self.gameObj:SendBill()
	end)
	
	g_EventMgr:AddListener(self, "GAME_BILL_SUCC", function(thisObj, billId, oneBill, billPaper, gameObj)
		self:removeSelf()
	end)
    g_EventMgr:AddListener(self,"OVERTIPS",function()
        self:removeSelf()
    end,self)
end

function clsBetBasketK:dtor()
	
end

function clsBetBasketK:SetKithe(kithe)
	if not kithe then return end
	local gameObj = self.gameObj
	self.lbl1:setString(string.format("%s-%s  #B%s#n期", gameObj.gameArg.name,gameObj:GetCurWanfa().name,string.sub(kithe, -7,-1)))
end

function clsBetBasketK:RefleshUI(gameObj)
	self.gameObj = gameObj
	
	local billPaper = gameObj:GetBillPaper()
	local billList = billPaper and billPaper:GetBillList() or {}
	
	local sContent = {}
	for _, oneBill in ipairs(billList) do
		local billInfo = oneBill:GenSenderBill(gameObj)
		if billInfo then
			table.insert(sContent, billInfo.names)
		end
	end
	sContent = table.concat(sContent, ",")
	--
    self.ListView_2:setItemModel(self.Panel_8)
	local betCount, totalCost = billPaper:GetTotalInfo(gameObj)
	local kithe = billPaper:GetKithe() or ""
    self.ListView_2:pushBackDefaultItem()
    local item = self.ListView_2:getItem(0)
	self.lbl1:setString(string.format("%s-%s  %s#n期", gameObj.gameArg.name,gameObj:GetCurWanfa().name, string.sub(kithe, -7,-1)))
    item:addChild(self.lbl1)

    self.ListView_2:pushBackDefaultItem()
    local item1 = self.ListView_2:getItem(1)
	self.lbl2:setString(string.format("投注金额：#R%.3f#n元",totalCost))
    item1:addChild(self.lbl2)

    self.ListView_2:pushBackDefaultItem()
    local item2 = self.ListView_2:getItem(2)
	self.lbl3:setString(string.format("投注内容：#R%s",sContent))
    item2:addChild(self.lbl3)
	
	local hSpace = 10
	local midX = self.BkgFrame:getContentSize().width*0.5
	local lbl = self.lbl1
	lbl:formatText()
	lbl:setContentSize(lbl:getRealWidth(),lbl:getRealHeight())
    item:setContentSize(lbl:getRealWidth(),lbl:getRealHeight())
    lbl:setPosition(lbl:getRealWidth()/2,lbl:getRealHeight()/2)
	--lbl:setPosition(midX, lbl:getRealHeight()/2+90)
	
	local lbl = self.lbl2
	lbl:formatText()
	lbl:setContentSize(lbl:getRealWidth(),lbl:getRealHeight())
    item1:setContentSize(lbl:getRealWidth(),lbl:getRealHeight())
    lbl:setPosition(lbl:getRealWidth()/2,lbl:getRealHeight()/2)
	--lbl:setPosition(midX, self.lbl3:getRealHeight()/2+self.lbl3:getPositionY()+lbl:getRealHeight()/2+hSpace)
	
	local lbl = self.lbl3
	lbl:formatText()
	lbl:setContentSize(lbl:getRealWidth(),lbl:getRealHeight())
    item2:setContentSize(lbl:getRealWidth(),lbl:getRealHeight())
    lbl:setPosition(lbl:getRealWidth()/2,lbl:getRealHeight()/2)
	--lbl:setPosition(midX, self.lbl2:getRealHeight()/2+self.lbl2:getPositionY()+lbl:getRealHeight()/2+hSpace)
	
	--self.BkgFrame:setContentSize(self.BkgFrame:getContentSize().width, self.lbl1:getRealHeight()+self.lbl2:getRealHeight()+self.lbl3:getRealHeight()+hSpace*2+90+65)
	--self.lblTitle:setPositionY(self.BkgFrame:getContentSize().height-22)
end
