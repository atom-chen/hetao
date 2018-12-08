-------------------------
-- 提现提示
-------------------------
module("ui", package.seeall)

local crypto = require("kernel.framework.crypto")

clsWithdrawSecInput = class("clsWithdrawSecInput", clsBaseUI)

function clsWithdrawSecInput:ctor(parent)
	clsBaseUI.ctor(self, parent, "uistu/WithdrawSecInput.csb")
	
	self.EditSecret = utils.ReplaceTextField(self.EditSecret)
	
	self.KEY2BTN = {
		alipay = self.Btn3,
		bank = self.Btn2,
		wechat = self.Btn1,
	}
	g_EventMgr:AddListener(self,"on_req_pay_withdraw_type", self.on_req_pay_withdraw_type, self)
	
	utils.RegClickEvent(self.BtnSure,function() 
		if not self.out_type then
			utils.TellMe("请选择支付方式")
			return
		end
			
		local strSec = self.EditSecret:getString()
		if string.len(strSec) < 6 then
			utils.TellMe("请输入正确的密码")
			return
		end
		
		local drawMoney = self.withdrawMoney
		local outtype = self.out_type
		proto.req_pay_withdraw({ money=tostring(drawMoney), bank_pwd=crypto.md5(strSec), out_type=outtype })
		KE_SafeDelete(self)
	end)
	utils.RegClickEvent(self.Btn3,function() 
		self:SelectPayType(3)
	end)
	utils.RegClickEvent(self.Btn2,function() 
		self:SelectPayType(2)
	end)
	utils.RegClickEvent(self.Btn1,function() 
		self:SelectPayType(1)
	end)
end

function clsWithdrawSecInput:on_req_pay_withdraw_type(recvdata, tArgs)
	if recvdata and recvdata.data then 
		local showing = {}
		for k, v in pairs(recvdata.data) do
			self.KEY2BTN[k].out_type = v
			self.KEY2BTN[k]:setVisible(v ~= "0")
			if v ~= "0" then
				table.insert(showing, self.KEY2BTN[k])
			end
		end
		local parWid = self.Image_1:getContentSize().width
		for i, btn in ipairs(showing) do
			btn:setPositionX(parWid/2+(i-(#showing/2+0.5))*160)
		end
		local selectBtn = showing[1]
		for i=1, 3 do
			if self["Btn"..i] == selectBtn then
				self:SelectPayType(i)
				break
			end
		end
	end
end

function clsWithdrawSecInput:SelectPayType(idx)
	self.out_type = self["Btn"..idx].out_type
	for i=1, 3 do
		self["chkbox"..i]:setSelected(idx==i)
	end
	logger.normal("out_type == ", self.out_type)
end

function clsWithdrawSecInput:dtor()
	
end

function clsWithdrawSecInput:RefleshUI(withdrawMoney, data, recvdata)
	self.withdrawMoney = withdrawMoney
	self._data = data
	if recvdata then 
		self:on_req_pay_withdraw_type(recvdata)
	else
		proto.req_pay_withdraw_type({money=tostring(self.withdrawMoney)})
	end
	
	self.lblTitle:setString("提现金额："..withdrawMoney)
end
