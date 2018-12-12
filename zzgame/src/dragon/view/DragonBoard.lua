--------------------
--公示版
--------------------
module("ui",package.seeall)

clsDragonBoard = class("clsDragonBoard",clsBaseUI)

function clsDragonBoard:ctor(parent)
    clsBaseUI.ctor(self,parent,"hddt/DragonBoard.csb")
    self:InitGlbEvents()
    self:InitUiEvent()
end

function clsDragonBoard:InitGlbEvents()
    g_EventMgr:AddListener(self,"on_req_interactive_chat_get_last_plan",self.on_req_interactive_chat_get_last_plan,self)
end

function clsDragonBoard:Select(index)
    if index == 1 then
        proto.req_interactive_chat_get_last_plan()
    elseif index == 2 then

    end
end

function clsDragonBoard:InitUiEvent()
    utils.RegClickEvent(self.BtnReturn,function()
        self:removeSelf()
    end)
    utils.RegClickEvent(self.BtnSure,function()
        self:removeSelf()
    end)
end

function clsDragonBoard:on_req_interactive_chat_get_last_plan(recvdata)
    self.Title:setString("最新计划")
    local data = recvdata and recvdata.data
    if not data then return end
    self.Text_6:setString(data.text)
    self.Text_7:setVisible(false)
    self.Text_8:setVisible(false)
    self.Text_9:setVisible(false)
    self.Text_8_0:setVisible(false)
    self.Text_9_0:setVisible(false)
    self.Image_12:setVisible(false)
end