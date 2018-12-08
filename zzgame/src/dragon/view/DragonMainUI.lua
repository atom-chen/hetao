--------------------------
-- 长龙玩法主界面
--------------------------
module("ui",package.seeall)

require("app.arpg.modules.hall.view.HallScene")
local ClsChatMgr = require("dragon.model.ChatMgr")

clsDragonMainUI = class("clsDragonMainUI",clsBaseUI)

local bFaceBtn = false
local head_icon = {
    "hddt/images/VIP1.png",
    "hddt/images/VIP2.png",
    "hddt/images/VIP3.png",
    "hddt/images/VIP4.png",
    "hddt/images/VIP5.png",
    "hddt/images/VIP6.png",
    "hddt/images/VIP7.png",
    "hddt/images/VIP8.png",
    "hddt/images/vip9.png",
}
function clsDragonMainUI:ctor(parent)
    clsBaseUI.ctor(self,parent,"hddt/HddtView.csb")
    self.ChatList:setScrollBarEnabled(false)
    self.MessageTextFile = utils.ReplaceTextField(self.MessageTextFile,"uistu/common/null.png","FF111111")
    proto.req_interactive_chat_index()
    proto.req_interactive_chat_get_ws_url()
    g_EventMgr:AddListener(self,"on_req_interactive_chat_index",self.on_req_interactive_chat_index,self)
    g_EventMgr:AddListener(self,"on_req_interactive_chat_get_ws_url",self.on_req_interactive_chat_get_ws_url,self)
    g_EventMgr:AddListener(self,"WS_CONNECT_SUCC",self.on_WS_CONNECT_SUCC,self)
    self.ContWnd = self.AreaAuto
    self:adaptor()
    self:RefreshUI()
    self:InitUiEvent()
    self:SwitchTo(0)
    
end

function clsDragonMainUI:dtor()
    KE_SafeDelete(self.Ws)
    self.Ws = nil
end

function clsDragonMainUI:on_WS_CONNECT_SUCC()
    local msg = {
        type = "login",
        token = ClsLoginMgr.GetInstance():Get_token_private_key(),
    }
    self.Ws:SendMsg(msg)
end

function clsDragonMainUI:RefreshUI()
    self.Expand:setVisible(bFaceBtn)
end

function clsDragonMainUI:adaptor()
    local sz = self.ContWnd:getContentSize()
    self.Expand:setPositionY(0)
    self.ListView_10:setContentSize(sz.width,sz.height*0.24)
    self.ChatList:setContentSize(sz.width,sz.height)
    self.ChatList:setPositionY(0)
end

function clsDragonMainUI:InitUiEvent()
    utils.RegClickEvent(self.BtnClose,function()
        ClsSceneManager.GetInstance():Turn2Scene("clsHallScene")
    end)
    utils.RegClickEvent(self.BtnYester,function()
        ClsUIManager.GetInstance():ShowPopWnd("clsDragonRankView")
    end)
    utils.RegClickEvent(self.BtnDragon,function()
        ClsUIManager.GetInstance():ShowPopWnd("clsDragonHelpView")
    end)
--    utils.RegClickEvent(self.BtnPlan,function()
--        ClsUIManager.GetInstance():ShowPopWnd()
--    end)
    utils.RegClickEvent(self.FaceBtn,function()
        bFaceBtn = not bFaceBtn
        self:SwitchTo(0)
        self.Expand:setVisible(bFaceBtn)
    end)
    utils.RegClickEvent(self.FaceBtn_1,function()
        self:SwitchTo(0)
    end)
    utils.RegClickEvent(self.QuickWords,function()
        self:SwitchTo(1)
    end)
    utils.RegClickEvent(self.Button_Service,function()
        PlatformHelper.openURL(ClsHomeMgr.GetInstance():GetHomeConfigData().online_service)
    end)
    utils.RegClickEvent(self.Btn_Send,function()
        --local text = self.MessageTextFile:getString()
        --if text~="" then
            self.Ws:SendMsg("aaaa")
        --end
    end)
    utils.RegClickEvent(self.QW_1,function()
        self.MessageTextFile:setString(self.MessageTextFile:getString().."上期中奖，分享注单你们跟投！！！")
    end)
    utils.RegClickEvent(self.QW_2,function()
        self.MessageTextFile:setString(self.MessageTextFile:getString().."上期不中，这期倍投，跟投跟投跟投！")
    end)
    utils.RegClickEvent(self.QW_3,function()
        self.MessageTextFile:setString(self.MessageTextFile:getString().."中奖喽，发个红包意思意思！！！")
    end)
    utils.RegClickEvent(self.QW_4,function()
        self.MessageTextFile:setString(self.MessageTextFile:getString().."我掐指一算，这期开双，跟投跟投跟投！！！")
    end)
end

function clsDragonMainUI:SwitchTo(nPage)
    if nPage < 0 then nPage = 0 end
	if nPage > 1 then nPage = 1 end
	self._curPage = nPage
	self:TurnToPages(nPage)
end

function clsDragonMainUI:TurnToPages(nPage)
    local highColor = cc.c3b(199,0,0)
    local normalColor = cc.c3b(153,153,153)
    self.FaceBtn_1:setTitleColor(nPage==0 and highColor or normalColor)
    self.QuickWords:setTitleColor(nPage==1 and highColor or normalColor)
    local dstX = -self.Panel_2:getContentSize().width * nPage
    self.Panel_2:stopAllActions()
    local useTime = math.abs(self.Panel_2:getPositionX()-dstX) / 2000
    self.Panel_2:runAction(cc.MoveTo:create(useTime, cc.p(dstX,self.Panel_2:getPositionY())))
end

function clsDragonMainUI:on_req_interactive_chat_index(recvdata)
    --dump(recvdata)
    local data = ClsChatMgr.GetInstance():GetChatRecord()
    if not data then return end

    for c,v in pairs(data) do
        local item
        if v["type"] == "txt" then
            local lin = 0
            local function ChangeLine(str)
                str = tostring(str)
                local headchar 
                local endchar
                if string.len(str) > 7 then
                    lin = lin + 1
                    headchar = string.sub(str,1,7)
                    endchar = string.sub(str,8)
                    str = headchar.."\n"..ChangeLine(endchar)
                    return str
                else    
                    return str
                end
            end
            item = self.TextItem:clone()
            utils.getNamedNodes(item)
            local name
            if v.to == "all" then
                name = v.from_name..":"
            else
                name = v.from_name..":@".."v.to"
            end
            item.Text_name:setString(name)
            item.Text_Vip:LoadTextureSync(head_icon[tonumber(v.vip)])
            item.Text_Vip_lvl:setString(string.format("VIP%d",v.vip))
            local sMsg = ChangeLine(v.msg)
            print(sMsg)
            item.Text_text:setString(v.msg)
            local content = item.Text_text:getContentSize()
            item.Text_Bg:setContentSize(content.width+40,item.Text_Bg:getContentSize().height + content.height - 33)
            item:setContentSize(item:getContentSize().width,item:getContentSize().height + content.height - 33)
            item.Text_text:setPositionY(item.Text_Bg:getContentSize().height - 20)
            item.Panel_1:setPositionY(self.Panel_1:getPositionY() + content.height - 33)
        elseif v["type"] == "lottery" then
            item = self.ShareItem:clone()
            utils.getNamedNodes(item)
            local name
            if v.to == "all" then
                name = v.from_name..":"
            else
                name = v.from_name..":@".."v.to"
            end
            item.Share_name:setString(name)
            item.Share_Vip:LoadTextureSync(head_icon[tonumber(v.vip)])
            item.Share_Vip_lvl:setString(string.format("VIP%d",v.vip))
        end
        if item then
            self.ChatList:pushBackCustomItem(item)
        end
    end
    self.ChatList:jumpToBottom()
end

function clsDragonMainUI:on_req_interactive_chat_get_ws_url(recvdata)
    local data = recvdata and recvdata.data
    self.url = data.url
    print("$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$"..self.url)
    local clsWebSock = require("dragon.model.web_socket")
    self.Ws = clsWebSock.new(self.url)
end