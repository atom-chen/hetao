-------------------------
-- 银行卡绑定界面
-------------------------
module("ui", package.seeall)

clsBankBindView = class("clsBankBindView", clsBaseUI)

function clsBankBindView:ctor(parent)
	clsBaseUI.ctor(self, parent, "uistu/BankBindView.csb")
	
	self.EditName = utils.ReplaceTextField(self.EditName, "", "FF111111")
	self.EditCardNum = utils.ReplaceTextField(self.EditCardNum, "", "FF111111")
	self.EditCardAddr = utils.ReplaceTextField(self.EditCardAddr, "", "FF111111")
	self.EditSecret = utils.ReplaceTextField(self.EditSecret, "", "FF111111")
	self.EditPhone = utils.ReplaceTextField(self.EditPhone, "", "FF111111")
	self.EditSecret:setInputMode(cc.EDITBOX_INPUT_MODE_NUMERIC)
	self.EditCardNum:setInputMode(cc.EDITBOX_INPUT_MODE_NUMERIC)
    self.EditSecret:SetSensitive(true)
	self.EditSecret:setMaxLength(6)
	self:InitUiEvents()
	self:InitGlbEvents()
	
	proto.req_user_bind_needinfo(nil, {bank_name="user/bank_name"})
end

function clsBankBindView:dtor()
	
end

function clsBankBindView:SetFromInfo(info)
	self._fromInfo = info
end

--注册控件事件
function clsBankBindView:InitUiEvents()
	utils.RegClickEvent(self.BtnClose, function() self:removeSelf() end)
	utils.RegClickEvent(self.BtnSure, function() 
		if not self._curBankInfo then
			utils.TellMe("请选择要绑定的银行")	
			return
		end
		if utils.IsWhiteSpace(self.EditSecret:getString()) then
            utils.TellMe("请输入资金密码")
            return
        end
        if string.len(self.EditSecret:getString()) ~= 6 then
            utils.TellMe("请输入六位资金密码")
            return
        end
        if utils.IsWhiteSpace(self.EditCardAddr:getString()) then
            utils.TellMe("请输入正确的开户行地址")
            return
        end
		local crypto = require("kernel.framework.crypto")
		local param = {
			bank_id = self._curBankInfo.id,
			--bank_name = self._curBankInfo.bank_name,
            bank_name = self.EditName:getString(),
			bank_pwd = crypto.md5( self.EditSecret:getString() ),
			num = self.EditCardNum:getString(),	--银行卡号
			phone = self.EditPhone:getString(),
			address = self.EditCardAddr:getString(),
		}
		proto.req_user_bind_bankcard(param)
	end)
	
	utils.RegClickEvent(self.PanelBank, function() 
		ClsUIManager.GetInstance():ShowPopWnd("clsBankListView"):SetCallback(function(info)
			self._curBankInfo = info
			self.lblBankName:setString(info.bank_name or "")
		end)
	end)
end

function clsBankBindView:AdjustUI()
	local needInfo = self._needinfo or {}
	local needPhone = true
	if needInfo.is_phone == "0" or needInfo.is_phone == 0 then
		needPhone = false
	end
	
	if needPhone then
		self.PanelPhone:setVisible(true)
		self.PanelSec:setPositionY(self.PanelPhone:getPositionY()-(811-705))
		self.BtnSure:setPositionY(self.PanelSec:getPositionY()-(705-563))
		self.TextTip:setPositionY(self.BtnSure:getPositionY()-(563-492))
	else
		self.PanelPhone:setVisible(false)
		self.PanelSec:setPositionY(self.PanelAddr:getPositionY()-(811-705))
		self.BtnSure:setPositionY(self.PanelSec:getPositionY()-(705-563))
		self.TextTip:setPositionY(self.BtnSure:getPositionY()-(563-492))
	end
	
	local needPwd = true
	if needInfo.is_pwd == "0" or needInfo.is_pwd == 0 or needInfo.is_pwd == false then
		needPwd = true
    else
        needPwd = false
	end
	self.PanelSec:setVisible(needPwd)
	if not needPwd then
		self.BtnSure:setPositionY(self.BtnSure:getPositionY()+100)
		self.TextTip:setPositionY(self.TextTip:getPositionY()+100)
	end
	
	self.EditName:setString(needInfo.name or "")
	if needInfo.name and needInfo.name ~= "" then
		self.EditName:setTouchEnabled(false)
	else
		self.EditName:setTouchEnabled(true)
	end
end

-- 注册全局事件
function clsBankBindView:InitGlbEvents()
	g_EventMgr:AddListener(self, "on_req_user_bind_needinfo", function(this, recvdata)
		self._needinfo = recvdata and recvdata.data 
		self:AdjustUI()
	end)
	g_EventMgr:AddListener(self, "on_req_user_bind_bankcard", function(thisObj, recvdata) 
		self:removeSelf()
	end, self)
end