----------------------
--长龙助手
----------------------
module("ui",package.seeall)

clsDragonHelpView = class("clsDragonHelpView",clsBaseUI)
local ClsChatMgr = require("dragon.model.ChatMgr")

function clsDragonHelpView:ctor(parent)
    clsBaseUI.ctor(self,parent,"hddt/DragonHelp.csb")
    --proto.req_dragon_data()
    proto.req_dragon_plays()
    g_EventMgr:AddListener(self,"on_req_dragon_plays",self.on_req_dragon_plays,self)
    self:InitUiEvent()
    self:RefreshUi()
end

function clsDragonHelpView:InitUiEvent()
    utils.RegClickEvent(self.BtnClose,function()
        self:removeSelf()
    end)
    utils.RegClickEvent(self.BtnHelp,function()
        ClsUIManager.GetInstance():ShowPopWnd("clsDragonInfoView")
    end)
    utils.RegClickEvent(self.Bet,function()
        self:SwitchTo(0)
    end)
    utils.RegClickEvent(self.BetHistory,function()
        self:SwitchTo(1)
    end)
end

function clsDragonHelpView:RefreshUi()
    
end

function clsDragonHelpView:SwitchTo(nPage)
    if nPage < 0 then nPage = 0 end
	if nPage > 1 then nPage = 1 end
	self._curPage = nPage
	self:TurnToPages(nPage)
end

function clsDragonHelpView:TurnToPages(nPage)
    local highColor = cc.c3b(255,255,255)
    local normalColor = cc.c3b(251,169,171)
    self.Bet:setTitleColor(nPage==0 and highColor or normalColor)
    self.BetHistory:setTitleColor(nPage==1 and highColor or normalColor)
    local dstX = -self.PanelPages:getContentSize().width * nPage
    self.PanelPages:stopAllActions()
    local useTime = math.abs(self.PanelPages:getPositionX()-dstX) / 2000
    self.PanelPages:runAction(cc.MoveTo:create(useTime, cc.p(dstX,self.PanelPages:getPositionY())))
end

function clsDragonHelpView:on_req_dragon_plays(recvdata)
    local data = ClsChatMgr.GetInstance():GetBetData()

end
