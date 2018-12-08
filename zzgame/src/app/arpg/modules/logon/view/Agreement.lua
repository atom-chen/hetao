---------------
-- 开户协议
---------------
module("ui",package.seeall)

local cacheData = false

clsAgreement = class("clsAgreement",clsBaseUI)

function clsAgreement:ctor(parent)
	clsBaseUI.ctor(self,parent,"uistu/Agreement.csb")
	
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
	
	g_EventMgr:AddListener(self,"on_req_helpdoc_site_info",self.Reflesh,self,true)
	utils.RegClickEvent(self.BtnClose,function() self:removeSelf() end)
	
	if not cacheData then
		proto.req_helpdoc_site_info({ id = "7" }, nil, function(recvdata)
			cacheData = recvdata
		end)
	end
end

function clsAgreement:dtor()

end

local HTMLHEAD = '<!DOCTYPE html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="initial-scale=1,user-scalable=no,maximum-scale=1,width=device-width,minimal-ui"><meta name="format-detection" content="telephone=no"><meta name="screen-orientation" content="portrait"><meta name="x5-orientation" content="portrait"><meta name="full-screen" content="yes"><meta name="x5-fullscreen" content="true"><meta name="browsermode" content="application"><meta name="x5-page-mode" content="app"><!--<meta name="apple-mobile-web-app-capable" content="yes">--><title></title><link rel="apple-touch-icon-precomposed" href="" id="appleico"><link rel="shortcut icon" href="" type="image/x-icon" id="ico"><link href="" rel="apple-touch-icon" id="apple_t"><base href="/"><link href="./94944d.app.css" rel="stylesheet"><style type="text/css"> img{height: auto; width: auto\9; width:100%;} </style></head><body ng-app="myApp"><ui-view style="display: none"></ui-view>'
local HTMLTAIL = '</body></html>'
function clsAgreement:Reflesh(recvdata)
	local info = cacheData and cacheData.data and cacheData.data[1] or {}
	self.lblTitle:setString(info.title or "开户协议")
	if self.htmlText then self.htmlText:setString(info.content or "") end
	if self.webView then
		local contStr = string.format("%s%s%s",HTMLHEAD, info.content, HTMLTAIL)
		self.webView:loadHTMLString(contStr)
		self.webView:setScalesPageToFit(true)
	end
end