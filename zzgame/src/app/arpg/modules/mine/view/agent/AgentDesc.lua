-------------------------
-- 代理说明
-------------------------
module("ui", package.seeall)

clsAgentDesc = class("clsAgentDesc", clsBaseUI)

function clsAgentDesc:ctor(parent)
	clsBaseUI.ctor(self, parent, "uistu/AgentDesc.csb")
	self:InitUiEvents()
	self:InitGlbEvents()
	self:RefreshUI()
end

function clsAgentDesc:dtor()
	
end

function clsAgentDesc:FixFont(target)
	local sz3 = target:getContentSize()
    target:setTextAreaSize(cc.size(sz3.width*g_ContentScaleFactor, sz3.height*g_ContentScaleFactor))
    utils.AdaptFont(target, target:getFontSize())
    target:ignoreContentAdaptWithSize(true)
    target:getVirtualRenderer():setScale(1)
    target:setContentSize(sz3)
end

function clsAgentDesc:RefreshUI()
    self.Text_3:getVirtualRenderer():setLineSpacing(10*g_ContentScaleFactor)
    self.Text_5:getVirtualRenderer():setLineSpacing(10*g_ContentScaleFactor)
    self.Text_7:getVirtualRenderer():setLineSpacing(10*g_ContentScaleFactor)
    self.Text_9:getVirtualRenderer():setLineSpacing(10*g_ContentScaleFactor)
    self:FixFont(self.Text_3)
    self:FixFont(self.Text_5)
    self:FixFont(self.Text_7)
    self:FixFont(self.Text_9)
    self.AreaAuto:forceDoLayout()
end

--注册控件事件
function clsAgentDesc:InitUiEvents()
	utils.RegClickEvent(self.BtnClose, function() self:removeSelf() end)
end

-- 注册全局事件
function clsAgentDesc:InitGlbEvents()
	
end