-------------------------------
-- 可滚动
-------------------------------
require("kernel.objects.gui.HtmlText")

ScrollHtmlText = class("ScrollHtmlText", function()
    return ccui.ScrollView:create() 
end)

function ScrollHtmlText:ctor(params)
    params = params or { }
    self:setTouchEnabled(true) 
    self:setBounceEnabled(true) 
    self:setDirection(ccui.ScrollViewDir.vertical)

    self:setContentSize(cc.size(params.width or display.width,params.height or display.height)) 
    local size = self:getContentSize()
    self:setInnerContainerSize(size)
    self:setScrollBarWidth(5) 
    --self:setScrollBarColor(cc.RED) 
    self:setScrollBarPositionFromCorner(cc.p(2,2)) 
    self.htmlText = HtmlText.new(params)
    self.htmlText:setContentSize(size)
    --self.htmlText:setVerticalSpace(5)
    self.htmlText:setAnchorPoint(0.5,1)
    
    self.htmlText:setPosition(cc.p(size.width/2, size.height))
    self:addChild(self.htmlText)
    self.htmlText:setReRenderCallback(handler(self,self.reSize))
end

function ScrollHtmlText:reSize()
    local size = self.htmlText:getContentSize()
    self:setInnerContainerSize(size)
    if size.height <= self:getContentSize().height then
        self.htmlText:setPositionY(self:getContentSize().height)
    else
        self.htmlText:setPositionY(size.height)
    end
end

function ScrollHtmlText:setVerticalSpace(size)
    self.htmlText:setVerticalSpace(size)
end

function ScrollHtmlText:setString(text)
	text = text or ""
    self.htmlText:setString(text)
    self:reSize()
end
