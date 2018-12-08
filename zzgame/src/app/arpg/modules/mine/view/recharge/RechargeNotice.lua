module("ui",package.seeall)

clsRechargeNotice = class("clsRechargeNotice",clsBaseUI)

function clsRechargeNotice:ctor(parent)
    clsBaseUI.ctor(self,parent,"uistu/RechargeNotice.csb")

    self:InUiEvent()
    self.BkgFrame:setPositionY(GAME_CONFIG.SCREEN_H /2)
end

function clsRechargeNotice:dtor()

end

function clsRechargeNotice:InUiEvent()
    utils.RegClickEvent(self.BtnLast,function()
        self:removeSelf()
    end)
    utils.RegClickEvent(self.BtnNext,function()
        ClsUIManager.GetInstance():ShowPanel("clsRechargeCommit2"):SetParams(self.money, self.info1, self.info2,self.info3,self.info4)
        self:removeSelf()
    end)
end

function clsRechargeNotice:RefreshUI(money, info1, info2, info3, info4)
    self.money = money
    self.info1 = info1
    self.info2 = info2
    self.info3 = info3
    self.info4 = info4
    self.Text_3:setString("入款金额："..self.money)
end