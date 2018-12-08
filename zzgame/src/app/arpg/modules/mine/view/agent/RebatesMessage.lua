module("ui",package.seeall)

clsRebatesMessage = class("clsRebatesMessage",clsBaseUI)

function clsRebatesMessage:ctor(parent)
    clsBaseUI.ctor(self,parent,"uistu/RebatesMessage.csb")
    self:InUiEvent()
    self:Refresh()
end

function clsRebatesMessage:InUiEvent()
    utils.RegClickEvent(self.Button_1,function()
        self:removeSelf()
    end)
end

function clsRebatesMessage:Refresh()
    local data = ClsAgentDataMgr.GetInstance():GetMemberdata().rebate
    self.K3:setString(data.k3)
    self.Ssc:setString(data.ssc)
    self.ElevenFive:setString(data["11x5"])
    self.Lhc:setString(data.lhc)
    self.Pks:setString(data.pk10)
    self.Fc3d:setString(data.fc3d)
    self.Pl3:setString(data.pl3)
end