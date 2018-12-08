---------------
-- 关于我们
---------------
module("ui",package.seeall)

clsRedbagDescView = class("clsRedbagDescView",clsBaseUI)

function clsRedbagDescView:ctor(parent)
	clsBaseUI.ctor(self,parent,"uistu/RedbagDescUI.csb")
	
	if device.platform ~= "windows" then
    	local webView = ccexp.WebView:create()
    	self:addChild(webView)
    	webView:setContentSize(700,self:GetAdaptInfo().hAuto-20)
    	webView:setAnchorPoint(cc.p(0,0))
    	self.webView = webView
    	self.webView:setPosition(10,10)
    	webView:setBounces(false)
    	webView:setScalesPageToFit(true)
    else
		self.htmlText = ScrollHtmlText.new( {
			width = 700,
			height = self:GetAdaptInfo().hAuto-20,
			color = cc.c3b(55,55,55),
			size = 28,
		})
		self.htmlText:setVerticalSpace(8)
		self.htmlText:setPosition(10,10)
		self:addChild(self.htmlText)
	end
	
	g_EventMgr:AddListener(self,"on_req_get_game_article_content",self.Reflesh,self,true)
	proto.req_get_game_article_content({id="38"})
	utils.RegClickEvent(self.BtnClose,function() self:removeSelf() end)
end

function clsRedbagDescView:dtor()

end

local HTMLHEAD = '<!DOCTYPE html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="initial-scale=1,user-scalable=no,maximum-scale=1,width=device-width,minimal-ui"><meta name="format-detection" content="telephone=no"><meta name="screen-orientation" content="portrait"><meta name="x5-orientation" content="portrait"><meta name="full-screen" content="yes"><meta name="x5-fullscreen" content="true"><meta name="browsermode" content="application"><meta name="x5-page-mode" content="app"><!--<meta name="apple-mobile-web-app-capable" content="yes">--><title></title><link rel="apple-touch-icon-precomposed" href="" id="appleico"><link rel="shortcut icon" href="" type="image/x-icon" id="ico"><link href="" rel="apple-touch-icon" id="apple_t"><base href="/"><link href="./94944d.app.css" rel="stylesheet"><style type="text/css"> img{height: auto; width: auto\9; width:100%;} </style></head><body ng-app="myApp"><ui-view style="display: none"></ui-view>'
local HTMLTAIL = '</body></html>'
function clsRedbagDescView:Reflesh(recvdata)
	local info = ClsRedbagMgr.GetInstance():GetRedbagDesc()
	local content = info and info.data and info.data[1].content or ""
	
	if self.webView then
		local contStr = string.format("%s%s%s",HTMLHEAD, content, HTMLTAIL)
		self.webView:loadHTMLString(contStr)
		self.webView:setScalesPageToFit(true)
	end
	if self.htmlText then self.htmlText:setString(content) end
end