module("ui",package.seeall)

local crypto = require("kernel.framework.crypto")
clsModifyPasswords = class("clsModifyPasswords",clsBaseUI)

function clsModifyPasswords:ctor(parent)
    clsBaseUI.ctor(self,parent,"uistu/ModifyWord.csb")
    self.LastPasswords = utils.ReplaceTextField(self.LastPasswords, "", const.COLOR.BLACK)
    self.NewPasswords = utils.ReplaceTextField(self.NewPasswords, "", const.COLOR.BLACK)
    self.NewPasswords_1 = utils.ReplaceTextField(self.NewPasswords_1, "", const.COLOR.BLACK)
	self.LastPasswords:SetSensitive(true)
	self.NewPasswords:SetSensitive(true)
	self.NewPasswords_1:SetSensitive(true)
    self:InUiEvent()

    g_EventMgr:AddListener(self,"on_req_chang_login_pwd",function() 
        utils.TellMe("修改密码成功")
        ClsGameMgr.GetInstance():SetTaskPaused(true)
        self:removeSelf() 
    end,self)
end

function clsModifyPasswords:InUiEvent()
    utils.RegClickEvent(self.BtnClose,function() self:removeSelf() end)
    utils.RegClickEvent(self.SureBtn,function() 
        local params = {
            pwd = self.LastPasswords:getString() or "",
            new_pwd = self.NewPasswords:getString() or "",
        }
        if string.len(params.new_pwd)<6 or string.len(params.new_pwd)>12 then
            utils.TellMe("请输入长度有效的新密码")
			return
        end

		if utils.IsWhiteSpace(params.pwd) or utils.IsWhiteSpace(params.new_pwd) then
			utils.TellMe("请输入有效的密码")
			return
		end
        if params.new_pwd ~= self.NewPasswords_1:getString() then
            utils.TellMe("两次密码不相同")
            return 
        end
        
        params.pwd = crypto.md5(params.pwd)
        params.new_pwd = crypto.md5(params.new_pwd)
        proto.req_chang_login_pwd(params)
    end)
    ------------------------------------------
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

function clsModifyPasswords:dtor()

end