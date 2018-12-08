-------------------------
-- 充值
-------------------------
module("ui", package.seeall)

clsRechargeCommit = class("clsRechargeCommit", clsBaseUI)

function clsRechargeCommit:ctor(parent)
	clsBaseUI.ctor(self, parent, "uistu/RechargeCommit.csb")
	
	self.editBindName = utils.ReplaceTextField(self.editBindName, "", "FFFF0000")
	
	self:BindTypeBtn(self.Btn1, "网银转账", 1, "wy", 1)
	self:BindTypeBtn(self.Btn2, "ATM现金入款", 2, "", 3)
	self:BindTypeBtn(self.Btn3, "银行柜台", 3, "", 4)
	self:BindTypeBtn(self.Btn4, "手机转账", 4, "", 5)
	self:BindTypeBtn(self.Btn5, "支付宝转账", 5, "zfb", 6)
	self:BindTypeBtn(self.Btn6, "微信支付", 6, "wx", 7)
	
	self._bandStyleBtns = {}
	for i=1, 6 do 
		self._bandStyleBtns[i] = self["Btn"..i]
		utils.RegClickEvent(self._bandStyleBtns[i], function()
			self:CheckBankStyle(self._bandStyleBtns[i])
		end)
	end
	self:CheckBankStyle(nil)
	
	self:InitUiEvents()
	self:InitGlbEvents()
end

function clsRechargeCommit:dtor()
	
end

function clsRechargeCommit:BindTypeBtn(btn, name, bank_style, Type, id)
	btn.bank_style = bank_style
	btn.type = Type 
	btn.id = id
	btn:getChildByName("lblCommitName"):setString(name)
end

function clsRechargeCommit:CheckBankStyle(btn)
	self._selectedBtn = btn
	for i=1, 6 do 
		local bSelect = btn == self._bandStyleBtns[i]
		self._bandStyleBtns[i]:getChildByName("Image_1"):setVisible(bSelect)
		self._bandStyleBtns[i]:getChildByName("Image_2"):setVisible(not bSelect)
	end
end

--注册控件事件
function clsRechargeCommit:InitUiEvents()
	utils.RegClickEvent(self.BtnClose, function() self:removeSelf() end)
	
	utils.RegClickEvent(self.BtnCpy1, function() SalmonUtils:copy(self.lblBankName:getString()) end)
	utils.RegClickEvent(self.BtnCpy2, function() SalmonUtils:copy(self.lblShouKuanRen:getString()) end)
	utils.RegClickEvent(self.BtnCpy3, function() SalmonUtils:copy(self.lblBankCard:getString()) end)
	utils.RegClickEvent(self.BtnCpy4, function() SalmonUtils:copy(self.lblKaiHuDian:getString()) end)
	
	utils.RegClickEvent(self.BtnCommit, function()
		if not self._selectedBtn then
			utils.TellMe("请选择转账方式")
			return 
		end
		self:AskPay(self._selectedBtn.id, self.money, self.info1, self.info2)
	end)
    utils.RegClickEvent(self.Button_Service,function()
		PlatformHelper.openURL(ClsHomeMgr.GetInstance():GetHomeConfigData().online_service)
	end)
end

function clsRechargeCommit:AskPay(bank_style, money, info1, info2)
	bank_style = tostring(bank_style)
	local money = self.money
	if not money or money < 0 then
		utils.TellMe("请输入有效的充值额度")
		return
	end
	local bindName = self.editBindName:getString()
	if not bindName or bindName == "" then
		utils.TellMe("请输入存款人姓名")
		return
	end
	if not bank_style then
		utils.TellMe("请选择转账方式")
		return
	end
	
	local param = {}
	param.bank_style = bank_style
	param.code = info2.code
	param.money = money
--	param.data = ""
	param.name = bindName
	param.id = info2.id
	param.from_way = const.FROMWAY
	
	param._client_jump = false
	param._client_data = {}
	param._client_data.info1 = info1
	param._client_data.info2 = info2
	param._client_data.money = money
	
	proto.req_pay_commit(param)
end

-- 注册全局事件
function clsRechargeCommit:InitGlbEvents()
	
end

function clsRechargeCommit:SetParams(money, info1, info2)
	self.info1 = info1
	self.info2 = info2
	self.money = tonumber(money)
	dump(info1)
	dump(info2)
	self.lblBankName:setString(info2.bank_name)
	self.lblShouKuanRen:setString(info2.name)
	self.lblBankCard:setString(info2.num)
	self.lblKaiHuDian:setString(info2.card_address)
	self.lblCunruTime:setString( os.date("%Y-%m-%d %H:%M:%S", os.time()) )
	self.lblMoney:setString(money)
end
