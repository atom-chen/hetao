---------------
-- 关于我们
---------------
module("ui",package.seeall)

local cacheData = false

clsAboutView = class("clsAboutView",clsBaseUI)

function clsAboutView:ctor(parent)
	clsBaseUI.ctor(self,parent,"uistu/AboutView.csb")
	
	self.htmlText = ScrollHtmlText.new( {
		width = 700,
		height = self:GetAdaptInfo().hAuto-20,
		color = cc.c3b(0,0,0),
		size = 28,
	})
	self.htmlText:setVerticalSpace(8)
	self.htmlText:setPosition(10,10)
	self:addChild(self.htmlText)
	
	g_EventMgr:AddListener(self,"on_req_helpdoc_site_info",self.Reflesh,self,true)
	utils.RegClickEvent(self.BtnClose,function() self:removeSelf() end)
	
	if not cacheData then
		proto.req_helpdoc_site_info({ id = "1" }, nil, function(recvdata)
			cacheData = recvdata
		end)
	end
end

function clsAboutView:dtor()

end

function clsAboutView:Reflesh(recvdata)
	local info = cacheData and cacheData.data and cacheData.data[1] or {}
	self.lblTitle:setString(info.title or "关于我们")
	self.htmlText:setString(info.content or "")
end