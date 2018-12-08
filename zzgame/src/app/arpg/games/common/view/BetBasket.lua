-------------------------
-- 投注蓝
-------------------------
module("ui", package.seeall)

clsBetBasket = class("clsBetBasket", clsBaseUI)

function clsBetBasket:ctor(parent,gameArg)
	clsBaseUI.ctor(self, parent, "uistu/BetBasket.csb")
	self.ListViewOrders = self.AreaAuto
	self.ListViewOrders:setItemModel(self.ListItem)
	KE_SafeDelete(self.ListItem)
	self.ListItem = nil
	
	utils.RegClickEvent(self.BtnClose, function() self:removeSelf() end)
	utils.RegClickEvent(self.BtnClear, function() 
		self.ListViewOrders:removeAllItems()
		self.gameObj:DelBillPaper()
		self:RefleshLblTotal()
	end)
	utils.RegClickEvent(self.BtnBet, function() 
		self.gameObj:SendBill()
	end)
	
	g_EventMgr:AddListener(self, "GAME_BILL_SUCC", function(thisObj, billId, oneBill, billPaper, gameObj)
		self:removeSelf()
	end)
	g_EventMgr:AddListener(self, "on_req_user_balance", function(thisObj, recvdata)
		self:RefleshLblTotal()
	end)
end

function clsBetBasket:dtor()
	
end

function clsBetBasket:RefleshUI(gameObj)
	self.gameObj = gameObj
	
	local billPaper = gameObj:GetBillPaper()
	local billList = billPaper and billPaper:GetBillList() or {}
	
	self.lblTitle:setString(gameObj.gameArg.name.."注单")
	
	self.ListViewOrders:removeAllItems()
	local idx = 0
	for _, oneBill in ipairs(billList) do
		local billInfo = oneBill:GenSenderBill(gameObj)
		if billInfo then
			self.ListViewOrders:pushBackDefaultItem()
			idx = idx + 1
			local item = self.ListViewOrders:getItem(idx-1)
			item._billId = oneBill:GetBillId()
			item:getChildByName("lblWanFa"):setString(gameObj:GetCurWanfa().name)
			item:getChildByName("lblBallName"):setString(billInfo.names)
			item:getChildByName("lblBetInfo"):setString( "共"..billInfo.counts.."注"..billInfo.price_sum.."元" )
			item:getChildByName("lblBetInfo"):setPositionX(item:getChildByName("lblBallName"):getPositionX()+item:getChildByName("lblBallName"):getContentSize().width+35)
			utils.RegClickEvent(item:getChildByName("BtnDel"), function() 
				self.gameObj:DelBillObj(oneBill:GetBillId())
				self.ListViewOrders:removeItem(self.ListViewOrders:getIndex(item))
				self:RefleshLblTotal()
			end)
		end
	end
	
	self:RefleshLblTotal()
end

function clsBetBasket:RefleshLblTotal()
	local betCount, totalCost = 0, 0
	if self.gameObj:GetBillPaper() then
		betCount, totalCost = self.gameObj:GetBillPaper():GetTotalInfo(self.gameObj)
	end
	self.lblTotal:setString( string.format("共计%.3f元  可用余额%.3f元", totalCost, UserEntity.GetInstance():Get_balance() or 0) )
	self.lblPaperNum:setString( string.format("共%d注", betCount) )
end
