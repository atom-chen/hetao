----------------------
--长龙说明
----------------------
module("ui",package.seeall)

clsDragonInfoView = class("clsDragonInfoView",clsBaseUI)

function clsDragonInfoView:ctor(parent)
    clsBaseUI.ctor(self,parent,"hddt/DragonInfo.csb")
    self.AreaAuto:forceDoLayout()
    self:InitUiEvent()
end 

function clsDragonInfoView:InitUiEvent()
    utils.RegClickEvent(self.BtnClose,function()
        self:removeSelf()
    end)
end 

--endregion
