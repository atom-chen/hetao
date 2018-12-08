--------------------
--公示版
--------------------
module("ui",package.seeall)

clsDragonBoard = class("clsDragonBoard",clsBaseUI)

function clsDragonBoard:ctor(parent)
    clsBaseUI.ctoe(self,parent,"hddt/DragonBoard.csb")
    g_EventMgr:AddListener(self,"on_req_interactive_chat_get_last_plan",self.req_interactive_chat_get_last_plan,self)
end

function clsDragonBoard:Select(index)
    if index == 1 then
        proto.req_interactive_chat_get_last_plan()
    elseif index == 2 then

    end
end

function clsDragonBoard:on_req_interactive_chat_get_last_plan(recvdata)

end