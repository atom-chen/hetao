-------------------------
-- 提现提示
-------------------------
module("ui", package.seeall)

clsWithdrawTip = class("clsWithdrawTip", clsBaseUI)

function clsWithdrawTip:ctor(parent)
	clsBaseUI.ctor(self, parent, "uistu/WithdrawTip.csb")
	
	utils.RegClickEvent(self.BtnSure, function()
		proto.req_pay_withdraw_type({money=tostring(self.withdrawMoney)})
	end)
	utils.RegClickEvent(self.BtnCancel, function()
		self:removeSelf()
	end)
	
	g_EventMgr:AddListener(self,"on_req_pay_withdraw_type", function(thisObj, recvdata)
		ClsUIManager.GetInstance():ShowPopWnd("clsWithdrawSecInput"):RefleshUI(self.withdrawMoney, self._data, recvdata)
	end)
	g_EventMgr:AddListener(self,"fail_req_pay_withdraw_type", function(thisObj, recvdata)
		self:removeSelf()
	end)
end

function clsWithdrawTip:dtor()
	
end

function clsWithdrawTip:RefleshUI(withdrawMoney, data)
	self.withdrawMoney = withdrawMoney
	self._data = data
	self.lbl1:setString( "还需打码量："..(data.auth_dml-data.dml) )
	self.lbl2:setString( "手续费："..data.out_fee )
	self.lbl3:setString( "行政费："..data.total_ratio_price )
	self.lbl4:setString( "总扣除："..(data.out_fee+data.total_ratio_price) )
end
