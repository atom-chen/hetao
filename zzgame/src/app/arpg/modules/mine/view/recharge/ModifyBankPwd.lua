module("ui",package.seeall)
local crypto = require("kernel.framework.crypto")

clsModifyBankPwd = class("clsModifyBankPwd",clsBaseUI)

function clsModifyBankPwd:ctor(parent)
    clsBaseUI.ctor(self,parent,"uistu/MoneyPwd.csb")
    self.LastPasswords = utils.ReplaceTextField(self.LastPasswords, "", const.COLOR.BLACK)
    self.NewPasswords = utils.ReplaceTextField(self.NewPasswords, "", const.COLOR.BLACK)
    self.NewPasswords_1 = utils.ReplaceTextField(self.NewPasswords_1, "", const.COLOR.BLACK)
    self.LastPasswords:setInputMode(cc.EDITBOX_INPUT_MODE_NUMERIC)
    self.NewPasswords:setInputMode(cc.EDITBOX_INPUT_MODE_NUMERIC)
    self.NewPasswords_1:setInputMode(cc.EDITBOX_INPUT_MODE_NUMERIC)
    self.LastPasswords:SetSensitive(true)
    self.NewPasswords:SetSensitive(true)
    self.NewPasswords_1:SetSensitive(true)

    self:InUiEvent()

    g_EventMgr:AddListener(self,"on_req_bank_pwd_chang",function() 
        utils.TellMe("密码修改成功")
        self:removeSelf()
    end,self)
end

function clsModifyBankPwd:InUiEvent()
    utils.RegClickEvent(self.BtnClose,function() self:removeSelf() end)
    utils.RegClickEvent(self.SureBtn,function() 
        local params = {
            bank_pwd = self.LastPasswords:getString() or "",
            new_pwd = self.NewPasswords:getString() or "",
        }
        
		if utils.IsWhiteSpace(params.bank_pwd) or utils.IsWhiteSpace(params.new_pwd) then
			utils.TellMe("请输入有效的密码")
			return
		end
        if string.len(params.new_pwd) ~= 6 then
            utils.TellMe("资金密码必须位6位数字")
            return
        end
        if tonumber(params.new_pwd) ~= tonumber(self.NewPasswords_1:getString()) then
            utils.TellMe("两次密码不相同")
            return 
        end
        
        params.bank_pwd = crypto.md5(params.bank_pwd)
        params.new_pwd = crypto.md5(params.new_pwd)
        proto.req_bank_pwd_chang(params)
    end)
    ----------------------------
    utils.RegClickEvent(self.Button_0,function()
    	self.LastPasswords:ToggleSensitive()
    end)
    
    utils.RegClickEvent(self.Button_1,function()
    	self.NewPasswords:ToggleSensitive()
    end)
    
    utils.RegClickEvent(self.Button_2,function()
    	self.NewPasswords_1:ToggleSensitive()
    end)
end

function clsModifyBankPwd:dtor()

end