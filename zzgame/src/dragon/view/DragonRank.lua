----------------------
--长龙排行榜
----------------------
module("ui",package.seeall)

clsDragonRankView = class("clsDragonRankView",clsBaseUI)
local ClsChatMgr = require("dragon.model.ChatMgr")

function clsDragonRankView:ctor(parent)
    clsBaseUI.ctor(self,parent,"hddt/DragonRank.csb")
    self:adaptor()
    proto.req_home_yesterday_win()
    self:InitUiEvent()
    self:InitGlbEvents()
end

function clsDragonRankView:InitGlbEvents()
    g_EventMgr:AddListener(self,"on_req_home_yesterday_win",self.on_req_home_yesterday_win,self)
end

function clsDragonRankView:InitUiEvent()
    utils.RegClickEvent(self.BtnClose,function()
        self:removeSelf()
    end)
end

function clsDragonRankView:adaptor()
    self.ListView_1:setContentSize(self.AreaAuto:getContentSize().width,self.AreaAuto:getContentSize().height)
    self.ListView_1:setPositionY(0)
end

function clsDragonRankView:on_req_home_yesterday_win(recvdata)
    local data = ClsChatMgr.GetInstance():GetYesterWin()
    self.ListView_1:setItemModel(self.listItem)
    for c,v in pairs(data) do
        self.ListView_1:pushBackDefaultItem()
        local item = self.ListView_1:getItem(c - 1)
        utils.getNamedNodes(item)
        if c == 1 then
            item.Medal:LoadTextureSync("hddt/images/gold.png")
        elseif c == 2 then
            item.Medal:LoadTextureSync("hddt/images/sliver.png")
        elseif c == 3 then
            item.Medal:LoadTextureSync("hddt/images/copper.png")
        else
            item.Medal:setVisible(false)
        end
        item.username:setString("账号昵称："..v.username)
        item.sort:setString(c)
        item.headIcon:SetHeadImg(v.img)
        item.money:setString(v.lucky_price)
    end
end
--endregion
