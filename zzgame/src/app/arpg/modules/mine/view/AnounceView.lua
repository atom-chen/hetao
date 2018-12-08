-------------------------
-- 公告信息
-------------------------
module("ui", package.seeall)

clsAnounceView = class("clsAnounceView", clsBaseUI)
local announce
local message
function clsAnounceView:ctor(parent)
	clsBaseUI.ctor(self, parent, "uistu/AnounceView.csb")
	self:InitUiEvents()
	self:InitGlbEvents()
    self.pageindex = 0
    self:Refresh()
    proto.req_home_getnotice({type = 0,show_location = 3})
    self.ListView_3:setScrollBarEnabled(false)
    self.ListView_4:setScrollBarEnabled(false)
    self.ListView_3:setSwallowTouches(false)
    self.ListView_4:setSwallowTouches(false)
    --self:RefleshVipContent()
end

function clsAnounceView:dtor()
	
end

function clsAnounceView:ForceAdapt()
	clsBaseUI.ForceAdapt(self)
	local sz = self.PageView:getContentSize()
	self.PageView:setContentSize(sz.width, sz.height+GAME_CONFIG.HEIGHT_DIFF)
	self.Panel_1:setContentSize(sz.width, sz.height+GAME_CONFIG.HEIGHT_DIFF)
	self.Panel_2:setContentSize(sz.width, sz.height+GAME_CONFIG.HEIGHT_DIFF)
	self.ListView_3:setContentSize(sz.width, sz.height+GAME_CONFIG.HEIGHT_DIFF)
	self.ListView_4:setContentSize(sz.width, sz.height+GAME_CONFIG.HEIGHT_DIFF)
	self.nodata:setPositionY(self.Panel_2:getContentSize().height/2)
	self.nodata_0:setPositionY(self.Panel_1:getContentSize().height/2)
end

function clsAnounceView:RefleshVipContent()
	local data = ClsHomeMgr.GetInstance():GetNoticeData() or {}
	local info = data[1] or {}
	
	self.lblTime:setString(info.time)
	
	if not self.HtmlText then
		self.htmlText = ScrollHtmlText.new( {
			width = 700,
			height = self:GetAdaptInfo().hAuto-10-130,
			color = cc.c3b(110,110,110),
			size = 24,
		})
		self.htmlText:setVerticalSpace(8)
		self.htmlText:setPosition(10,10)
		self.Panel_1:addChild(self.htmlText)
	end
	self.htmlText:setString(info.content or "")
end

--注册控件事件
function clsAnounceView:InitUiEvents()
	utils.RegClickEvent(self.BtnClose, function() self:removeSelf() end)
    utils.RegClickEvent(self.BtnVipAnounce,function() 
        if self.pageindex ~= 0 then
            self.pageindex = 0
            self.PageView:scrollToPage(0)
            if not announce then
                proto.req_home_getnotice({type = 0,show_location = 3})
            else
                self:Refresh(announce)
            end
        end
        --self:Refresh()
    end)
    utils.RegClickEvent(self.BtnVipMessage,function() 
        if self.pageindex ~= 1 then
            self.pageindex = 1
            self.PageView:scrollToPage(1)
            if not message then
                proto.req_home_getnotice({type =2,show_location = 3})
            else
                self:Refresh(message)
            end
        end
        --self:Refresh()
    end)
    local function PageViewCallBack(sender,event)
        if event == ccui.PageViewEventType.turning then
            self.pageindex = self.PageView:getCurrentPageIndex()
            if self.pageindex == 0 then
                if not announce then
                    proto.req_home_getnotice({type = 0,show_location = 3})
                else
                    self:Refresh(announce)
                end
            elseif self.pageindex == 1 then
                if not message then
                    proto.req_home_getnotice({type = 2,show_location = 3})
                else
                    self:Refresh(message)
                end
            end
            --self:Refresh()
        end
    end
    self.PageView:addEventListener(PageViewCallBack)
end

function clsAnounceView:Refresh(recvdata)
    if self.pageindex == 0 then
        announce = recvdata
        self.BtnVipAnounce:setColor(cc.c3b(255,0,0))
        self.Text_1:setTextColor(cc.c3b(255,255,255))
        self.BtnVipMessage:setColor(cc.c3b(255,255,255))
        self.Text_2:setTextColor(cc.c3b(0,0,0))
        if recvdata and recvdata.data and #recvdata.data>0 then
            self.nodata_0:setVisible(false)
            self.ListView_3:removeAllItems()
            
            local space = ccui.Layout:create()
            space:setContentSize(670, 2)
            space:setBackGroundColorType(1)
			space:setBackGroundColor({ r = 188, g = 188, b = 188 })
            self.ListView_3:pushBackCustomItem(space)
            	
            for i,v in ipairs(recvdata.data) do
                local htmlText = HtmlText.new( {
			        width = 670,
			        height = 26,
			        color = cc.c3b(32,32,32),
			        size = 25,
			        fixWidth = 670,
		        })
		        htmlText:setVerticalSpace(8)
                htmlText:setString(v.content or "")
                self.ListView_3:pushBackCustomItem(htmlText)
                
                local htmlText = HtmlText.new( {
			        width = 670,
			        height = 26,
			        color = cc.c3b(122,122,122),
			        size = 25,
		        })
		        htmlText:setVerticalSpace(8)
                htmlText:setString(v.time or "")
                self.ListView_3:pushBackCustomItem(htmlText)
                
                local space = ccui.Layout:create()
            	space:setContentSize(670, 2)
            	space:setBackGroundColorType(1)
				space:setBackGroundColor({ r = 188, g = 188, b = 188 })
            	self.ListView_3:pushBackCustomItem(space)
            end
        else
            self.nodata_0:setVisible(true)
        end
    elseif self.pageindex == 1 then
        message = recvdata
        self.BtnVipAnounce:setColor(cc.c3b(255,255,255))
        self.Text_1:setTextColor(cc.c3b(0,0,0))
        self.BtnVipMessage:setColor(cc.c3b(255,0,0))
        self.Text_2:setTextColor(cc.c3b(255,255,255))
        if recvdata and recvdata.data and #recvdata.data>0 then
            self.nodata:setVisible(false)
            self.ListView_4:removeAllItems()
            
            local space = ccui.Layout:create()
            space:setContentSize(670, 2)
            space:setBackGroundColorType(1)
			space:setBackGroundColor({ r = 188, g = 188, b = 188 })
            self.ListView_4:pushBackCustomItem(space)
            
            for i,v in ipairs(recvdata.data) do              
		        local htmlText = HtmlText.new( {
			        width = 670,
			        height = 26,
			        color = cc.c3b(32,32,32),
			        size = 25,
			        fixWidth = 670,
		        })
		        htmlText:setVerticalSpace(8)
	            htmlText:setString(v.content or "")
                self.ListView_4:pushBackCustomItem(htmlText)
                
                local htmlText = HtmlText.new( {
			        width = 670,
			        height = 26,
			        color = cc.c3b(122,122,122),
			        size = 25,
		        })
		        htmlText:setVerticalSpace(8)
                htmlText:setString(v.time or "")
                self.ListView_4:pushBackCustomItem(htmlText)
                
                local space = ccui.Layout:create()
            	space:setContentSize(670, 2)
            	space:setBackGroundColorType(1)
				space:setBackGroundColor({ r = 188, g = 188, b = 188 })
            	self.ListView_4:pushBackCustomItem(space)
            end
        else
            self.nodata:setVisible(true)
        end
    end
end
-- 注册全局事件
function clsAnounceView:InitGlbEvents()
	g_EventMgr:AddListener(self,"on_req_home_getnotice",self.Refresh,self,true)
end