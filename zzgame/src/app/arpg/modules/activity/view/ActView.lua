---------------
-- 活动页
---------------
module("ui",package.seeall)

clsActView = class("clsActView",clsBaseUI)

function clsActView:ctor(parent, actInfo)
	clsBaseUI.ctor(self,parent,"uistu/AASkinNormal.csb")
	self.lblTitle:setString("优惠活动")
	
	if device.platform ~= "windows" then
    	local webView = ccexp.WebView:create()
    	self:addChild(webView)
    	webView:setContentSize(cc.size(720,self:GetAdaptInfo().hAuto))
    	webView:setAnchorPoint(cc.p(0,0))
    	self.webView = webView
    	webView:setBounces(false)
    	webView:setScalesPageToFit(true)
    else
    	self.htmlText = ScrollHtmlText.new( {
			width = 700,
			height = self:GetAdaptInfo().hAuto-20,
			color = cc.c3b(0,0,0),
			size = 28,
			fixWidth = 700,
		})
		self.htmlText:setVerticalSpace(8)
		self.htmlText:setPosition(10,10)
		self:addChild(self.htmlText)
    end
	
	self:RefleshUI(actInfo)
	utils.RegClickEvent(self.BtnClose,function() self:removeSelf() end)
end

function clsActView:dtor()

end

--local HTMLHEAD = '<!DOCTYPE html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="initial-scale=1,user-scalable=no,maximum-scale=1,width=device-width,minimal-ui"><meta name="format-detection" content="telephone=no"><meta name="screen-orientation" content="portrait"><meta name="x5-orientation" content="portrait"><meta name="full-screen" content="yes"><meta name="x5-fullscreen" content="true"><meta name="browsermode" content="application"><meta name="x5-page-mode" content="app"><!--<meta name="apple-mobile-web-app-capable" content="yes">--><title></title><link rel="apple-touch-icon-precomposed" href="" id="appleico"><link rel="shortcut icon" href="" type="image/x-icon" id="ico"><link href="" rel="apple-touch-icon" id="apple_t"><base href="/"><link href="./94944d.app.css" rel="stylesheet"><script type="text/javascript">var phoneScale = parseInt(window.screen.width)/640;document.write(\'<meta name="viewport" content="width=640, minimum-scale = \'+ phoneScale +\', maximum-scale = \'+ phoneScale +\', 　　target-densitydpi=device-dpi">\');</script></head><body ng-app="myApp"><ui-view style="display: none"></ui-view>'
local HTMLHEAD = '<!DOCTYPE html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="initial-scale=1,user-scalable=no,maximum-scale=1,width=device-width,minimal-ui"><meta name="format-detection" content="telephone=no"><meta name="screen-orientation" content="portrait"><meta name="x5-orientation" content="portrait"><meta name="full-screen" content="yes"><meta name="x5-fullscreen" content="true"><meta name="browsermode" content="application"><meta name="x5-page-mode" content="app"><!--<meta name="apple-mobile-web-app-capable" content="yes">--><title></title><link rel="apple-touch-icon-precomposed" href="" id="appleico"><link rel="shortcut icon" href="" type="image/x-icon" id="ico"><link href="" rel="apple-touch-icon" id="apple_t"><base href="/"><link href="./94944d.app.css" rel="stylesheet"><style type="text/css"> body,div,dl,dt,dd,ul,ol,li,h1,h2,h3,h4,h5,h6,pre,form,fieldset,input,textarea,p,blockquote,th,td,img {margin:0;padding:0;} table{cellSpacing:0;cellPadding:0;border-collapse:collapse;} table th,table td{ border:1px solid #ccc;align:center;text-align:center;} img{width: auto\9; width:100%;} </style></head><body ng-app="myApp"><ui-view style="display: none"></ui-view>'
local HTMLTAIL = '</body></html>'
function clsActView:RefleshUI(actInfo)
	if self.htmlText then self.htmlText:setString(actInfo.content or "") end
	if self.webView then 
		local contStr = string.format("%s%s%s",HTMLHEAD, actInfo.content, HTMLTAIL)
		self.webView:loadHTMLString(contStr) 
	end
end