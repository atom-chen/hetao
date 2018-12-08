-------------------------
-- 充值
-------------------------
module("ui", package.seeall)

clsRechargeOver = class("clsRechargeOver", clsBaseUI)

function clsRechargeOver:ctor(parent, info)
	clsBaseUI.ctor(self, parent, "uistu/RechargeOver.csb")
	
	
	utils.RegClickEvent(self.BtnClose, function() 
        g_EventMgr:FireEvent("RechargeOver")
        self:removeSelf() 
    end)
	utils.RegClickEvent(self.BtnOver, function() 
        g_EventMgr:FireEvent("RechargeOver")
        self:removeSelf()
    end)
	
	self.lblMoney:setString("充值金额："..info.money.."元")
end

function clsRechargeOver:dtor()
	
end



clsWithdrawOver = class("clsWithdrawOver", clsBaseUI)

function clsWithdrawOver:ctor(parent, info)
	clsBaseUI.ctor(self, parent, "uistu/WithdrawOver.csb")
	
	
	utils.RegClickEvent(self.BtnClose, function() 
        self:removeSelf() 
    end)
	utils.RegClickEvent(self.BtnOver, function()
        self:removeSelf()
    end)
	
	self.lblMoney:setString("提现金额："..info.money.."元")
end

function clsWithdrawOver:dtor()
	
end