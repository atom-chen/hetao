--------------------------
-- 长龙玩法主界面
--------------------------
module("ui",package.seeall)

local json = require("kernel.framework.json")
require("app.arpg.modules.hall.view.HallScene")
local ClsChatMgr = require("dragon.model.ChatMgr")
local DRAGON_CFG = require("dragon.config")

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
    ClsResManager.GetInstance():AddSpriteFrames( "hddt/emoji.plist" )
    clsBaseUI.ctor(self,parent,"hddt/HddtView.csb")
    self.ChatList:setScrollBarEnabled(false)
    self.ChatList:setBounceEnabled(true)
    self.MessageTextFile = utils.ReplaceTextField(self.MessageTextFile,"uistu/common/null.png","FF111111")
    proto.req_interactive_chat_index()
    proto.req_interactive_chat_get_ws_url()
    self.ContWnd = self.AreaAuto
    self:InitGlbEvents()
    self:adaptor()
    self:RefreshUI()
    self:InitUiEvent()
    self:SwitchTo(0)
    self:InitFacePanel()
    self.MessageTextFile:setLocalZOrder(1)
end

function clsDragonMainUI:InitGlbEvents()
    g_EventMgr:AddListener(self,"on_req_interactive_chat_index",self.on_req_interactive_chat_index,self)
    g_EventMgr:AddListener(self,"on_req_interactive_chat_get_ws_url",self.on_req_interactive_chat_get_ws_url,self)
    g_EventMgr:AddListener(self,"WS_CONNECT_SUCC",self.on_WS_CONNECT_SUCC,self)
    g_EventMgr:AddListener(self,"WS_CHAT_DATA",self.on_WS_CHAT_DATA,self)
end

function clsDragonMainUI:dtor()
    WSHelper:Destroy()
    ClsResManager.GetInstance():SubSpriteFrames( "hddt/emoji.plist" )
end

function clsDragonMainUI:on_WS_CONNECT_SUCC()
    WSHelper:SendLogin()
end

function clsDragonMainUI:on_WS_CHAT_DATA(data)
    local id = ClsChatMgr.GetInstance():AddChatRecord(data)
    self:PushBackChatItem(id, data, true)
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
    utils.RegClickEvent(self.BtnPlan,function()
        ClsUIManager.GetInstance():ShowPopWnd("clsDragonBoard"):Select(1)
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
        local strMsg = self.MessageTextFile:getString()
        if not strMsg or strMsg == "" then
            strMsg = self.MessageImg.strMsg
            if WSHelper:SendImgMsg( strMsg ) then
                self.MessageTextFile:setString("")
                self.MessageImg:removeAllChildren()
                self.MessageImg.strMsg = ""
            end
        else
            if WSHelper:SendTxtMsg( strMsg ) then
                self.MessageTextFile:setString("")
                self.MessageImg:removeAllChildren()
                self.MessageImg.strMsg = ""
            end
        end
        
    end)
    utils.RegClickEvent(self.QW_1,function()
        self.MessageTextFile:setString("上期中奖，分享注单你们跟投！！！")
    end)
    utils.RegClickEvent(self.QW_2,function()
        self.MessageTextFile:setString("上期不中，这期倍投，跟投跟投跟投！")
    end)
    utils.RegClickEvent(self.QW_3,function()
        self.MessageTextFile:setString("中奖喽，发个红包意思意思！！！")
    end)
    utils.RegClickEvent(self.QW_4,function()
        self.MessageTextFile:setString("我掐指一算，这期开双，跟投跟投跟投！！！")
    end)

    self.MessageTextFile:registerScriptEditBoxHandler(function(evenName, sender)
        self.MessageImg:removeAllChildren()
        self.MessageImg.strMsg = ""
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

    local count = #data
    local begin = math.max(1, count-20)
    for i=begin, count do
        self:PushBackChatItem(i, data[i])
    end
    self.ChatList:jumpToBottom()
end

function clsDragonMainUI:on_req_interactive_chat_get_ws_url(recvdata)
    local data = recvdata and recvdata.data
    if data then
        WSHelper:Init(data.url)
    end
end

----------------------------

function clsDragonMainUI:InitFacePanel()
    self.MessageImg = ccui.ListView:create()
    self.MessageImg:setDirection(ccui.ScrollViewDir.horizontal)
    self.MessageImg:setContentSize(self.MessageTextFile:getContentSize())
    self.MessageImg:setPosition(self.MessageTextFile:getPosition())
    self.MessageImg:setAnchorPoint(self.MessageTextFile:getAnchorPoint())
    self.MessageImg:setScrollBarEnabled(false)
    self.MessageTextFile:getParent():addChild(self.MessageImg)
    self.MessageImg.strMsg = ""

    local EmojiCfg = require("dragon.config").EMOJI
    local count = #EmojiCfg
    
    local sz = self.PageView_emoji:getContentSize()
    local iconSize = 72
    local col = math.floor(sz.width/iconSize)
    local row = math.floor(sz.height/iconSize)
    local totalPage = math.ceil( count/(row*col) )

    local bFlag = false 
    for page=1, totalPage do
        local pageItem = ccui.Layout:create()
        pageItem:setContentSize(sz)
        local idx = (page-1) * row*col
        if bFlag then break end
        for r=1, row do
            if bFlag then break end
            for c=1, col do
                idx = idx + 1
                if not EmojiCfg[idx] then 
                    bFlag = true 
                    break 
                end
                local btnEmoji = ccui.Button:create()
                btnEmoji:setScale9Enabled(true)
                btnEmoji:setContentSize(cc.size(iconSize,iconSize))
                local spr = cc.Sprite:create( string.format("hddt/emoji/%s",EmojiCfg[idx].File) )
                btnEmoji:addChild(spr)
                spr:setPosition(iconSize/2,iconSize/2)
                pageItem:addChild(btnEmoji)
                btnEmoji:setPosition( (c-0.5)*iconSize, (r-0.5)*iconSize )
                btnEmoji._txtMsg = EmojiCfg[idx]

                utils.RegClickEvent(btnEmoji, function()
                    self.MessageTextFile:setString( "" )
                    if not self.MessageImg.strMsg then self.MessageImg.strMsg = "" end
                    self.MessageImg.strMsg = self.MessageImg.strMsg .. btnEmoji._txtMsg.Tag
                    local sprEmoji = ccui.ImageView:create( string.format("hddt/emoji/%s",btnEmoji._txtMsg.File) )
                    self.MessageImg:pushBackCustomItem(sprEmoji)
                    self.MessageImg:jumpToRight()
                end)
            end
        end
        self.PageView_emoji:addPage(pageItem)
    end

    self._pre_topIndex = -1
    self._pre_bottomIndex = -1
    self:CreateTimerLoop("tmr_chk_see", 6, function()
        local ChatList = self.ChatList
        local topItem = ChatList:getTopmostItemInCurrentView()
        local bottomItem = ChatList:getBottommostItemInCurrentView()
        if topItem and bottomItem then
            local topIndex = ChatList:getIndex(topItem)-2
            local bottomIndex = ChatList:getIndex(bottomItem)+2
            local items = ChatList:getItems() or {}
            local count = #items
            if topIndex < 1 then topIndex = 1 end
            if bottomIndex > count then bottomIndex = count end
            if self._pre_topIndex ~= topIndex or self._pre_bottomIndex ~= bottomIndex then
                self._pre_topIndex = topIndex
                self._pre_bottomIndex = bottomIndex
                local from = math.max(1, topIndex-12)
                local to = math.min(count, bottomIndex+12)
                for i=from, topIndex do
                    items[i]:setVisible(false)
                end
                for i=bottomIndex, to do
                    items[i]:setVisible(false)
                end
                for i=topIndex, bottomIndex do
                    items[i]:setVisible(true)
                end
            end
        end
    end)

    self.ChatList:addScrollViewEventListener(function(sender, evenType)
        if evenType == ccui.ScrollviewEventType.autoscrollEnded then
            if self.ChatList:getInnerContainerPosition().y-1 <= self.ChatList:getContentSize().height - self.ChatList:getInnerContainerSize().height then
                print("到达顶部，插入前面到数据")
                for i=1, 10 do
                    self:PushFrontChatItem() 
                end
            end
    	end
	end)
end

function clsDragonMainUI:PushFrontChatItem()
    local items = self.ChatList:getItems()
    local topId = items[1] and items[1]._id
    if not topId then return end
    topId = topId - 1
    if topId < 1 then return end
    print("添加顶部元素", topId)
    local item = self:CreateChatItem(ClsChatMgr.GetInstance():GetChatData(topId))
    if item then
        item._id = topId
        local ChatList = self.ChatList
        local innerPos = ChatList:getInnerContainerPosition()
        ChatList:insertCustomItem(item, 0)
        ChatList:forceDoLayout()
        ChatList:setInnerContainerPosition( innerPos )
    end
end

function clsDragonMainUI:PushBackChatItem(id, v, bJmptoBottom)
    local item = self:CreateChatItem(v)
    if item then
        item._id = id
        local ChatList = self.ChatList
        local innerPos = ChatList:getInnerContainerPosition()
        ChatList:pushBackCustomItem(item)
        ChatList:forceDoLayout()
        if bJmptoBottom and innerPos.y >= -5 then
            ChatList:jumpToBottom()
        else
            innerPos.y = innerPos.y - item:getContentSize().height - ChatList:getItemsMargin()
            ChatList:setInnerContainerPosition( innerPos )
        end
    end
end

function clsDragonMainUI:CreateChatItem(v)
    local item
    if v.type == "txt" then
        item = self:CreateTxtItem(v)
    elseif v.type == "lottery" then
        item = self:CreateLotteryItem(v)
    elseif v.type == "img" then
        item = self:CreateImgItem(v)
    elseif v.type == "standings" then
        item = self:CreateStandingsItem(v)
    end
    item:setVisible(false)
    return item
end

local function ChangeLine(str)
    str = tostring(str)
    local lin = 0
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

local BLACK_COLOR = cc.c3b(0,0,0)

function clsDragonMainUI:CreateTxtItem(v)
    local item = self.TextItem:clone()
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
    item.Text_text:removeFromParent()

    local htmlTxt = HtmlText.new( {
		color = BLACK_COLOR,
        size = 28,
        width = item.Text_Bg:getContentSize().width-40,
        height = 48
    })
    htmlTxt:setString(v.msg)
    htmlTxt:setAnchorPoint(0,0)
    htmlTxt:setPosition(20, 10)
--	htmlTxt:setVerticalSpace(5)
    htmlTxt:setContentSize(htmlTxt:getRealWidth(),htmlTxt:getRealHeight())
    item.Text_Bg:addChild(htmlTxt)
    --[[
    local htmlTxt = clsRichText.new(v.msg, item.Text_Bg:getContentSize().width-40, 48, nil, 28, BLACK_COLOR)
    htmlTxt:formatText()
	htmlTxt:setContentSize(htmlTxt:getRealWidth(),htmlTxt:getRealHeight())
    item.Text_Bg:addChild(htmlTxt)
    htmlTxt:setAnchorPoint(cc.p(0,0))
    htmlTxt:setPosition(20, 10)
    ]]

    local content = htmlTxt:getContentSize()
    item.Text_Bg:setContentSize(content.width+40,content.height+20)
    item:setContentSize(item:getContentSize().width, content.height+20+50)
    item.Text_Vip:setPositionY(content.height+20+50-22)
    item.Text_name:setPositionY(content.height+20+50-22)

    return item
end

function clsDragonMainUI:CreateImgItem(v)
    local item = self.TextItem:clone()
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
    item.Text_text:removeFromParent()

    local tblMsg = string.gsub(v.msg, "%[", "")
    tblMsg = string.split(tblMsg, "]")
    local strCont = ""
    for _, emojiName in ipairs(tblMsg) do
        local cfg = DRAGON_CFG.EMOJI_BY_TAG[ "["..emojiName.."]" ]
        if cfg then
            strCont = strCont .. string.format( "#o(1,hddt/emoji/%s)",cfg.File )
        end
    end
    local htmlTxt = clsRichText.new(strCont, item.Text_Bg:getContentSize().width-40, 48)
    htmlTxt:formatText()
	htmlTxt:setContentSize(htmlTxt:getRealWidth(),htmlTxt:getRealHeight())
    item.Text_Bg:addChild(htmlTxt)
    htmlTxt:setAnchorPoint(cc.p(0,0))
    htmlTxt:setPosition(20, 10)

    local content = htmlTxt:getContentSize()
    item.Text_Bg:setContentSize(content.width+40,content.height+20)
    item:setContentSize(item:getContentSize().width, content.height+20+50)
    item.Text_Vip:setPositionY(content.height+20+50-22)
    item.Text_name:setPositionY(content.height+20+50-22)

    return item
end

function clsDragonMainUI:CreateStandingsItem(v)
    local item = self.StandingItem:clone()
    utils.getNamedNodes(item)

    local name
    if v.to == "all" then
        name = v.from_name..":"
    else
        name = v.from_name..":@".."v.to"
    end
    item.Standing_name:setString(name)
    item.Standing_Vip:LoadTextureSync(head_icon[tonumber(v.vip)])
    item.Standing_Vip_lvl:setString(string.format("VIP%d",v.vip))
    item.Bet_money:setString(v.valid_price)
    item.Win_money:setString(v.lucky_price)
    item.Reward_money:setString(v.profit)

    return item
end

function clsDragonMainUI:CreateLotteryItem(v)
    local info = json.decode(v.msg) or {}
    local item = self.LotteryItem:clone()
    utils.getNamedNodes(item)

    local name
    if v.to == "all" then
        name = v.from_name..":"
    else
        name = v.from_name..":@".."v.to"
    end
    item.Lottery_name:setString(name)
    item.Lottery_Vip:LoadTextureSync(head_icon[tonumber(v.vip)])
    item.Lottery_Vip_lvl:setString(string.format("VIP%d",v.vip))
    item.Lottery_czn:setString(info.game_name)
    item.Lottery_czn_0:setString(string.format("%s期",info.issue))
    item.Lottery_money:setString(info.bet and info.bet.price_sum or "")
    item.Lottery_way:setString("")
    item.Lottery_bors:setString("")
    item.Lottery_sord:setString("")

    return item
end
