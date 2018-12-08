-------------------
-- 确认框
-------------------
local MsgBox = {}

function MsgBox:show(parent,zOrder, titleStr, tipStr, callback, sOk, sNo, iStyle)
	if not parent or tolua.isnull(parent) then return end
    local box = cc.Layer:create()
    MsgBox.ctor(box, titleStr, tipStr, callback, sOk, sNo, iStyle)
    parent:addChild(box,zOrder)
    
	local function onToucheBegan(touch, event)
		return true
	end
	local function onToucheMoved(touch, event) 
		
	end
	local function onToucheEnded(touch, event) 
		
	end
	local listener = cc.EventListenerTouchOneByOne:create()
	listener:registerScriptHandler(onToucheBegan, cc.Handler.EVENT_TOUCH_BEGAN)
	listener:registerScriptHandler(onToucheMoved, cc.Handler.EVENT_TOUCH_MOVED)
	listener:registerScriptHandler(onToucheEnded, cc.Handler.EVENT_TOUCH_ENDED)
	box:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, box)
	listener:setSwallowTouches(true)
	
    return box
end

function MsgBox:ctor(titleStr, tipStr, callback, sOk, sNo, iStyle)
	local rootNode = cc.CSLoader:createNode("launcher/MsgBox.csb")
	self:addChild(rootNode)
	local BtnSure = ccui.Helper:seekWidgetByName(rootNode, "BtnSure")
	local BtnCancel = ccui.Helper:seekWidgetByName(rootNode, "BtnCancel")
	
	if titleStr then ccui.Helper:seekWidgetByName(rootNode, "lblTitle"):setString(titleStr) end
	ccui.Helper:seekWidgetByName(rootNode, "lblTips"):setString(tipStr)
	if sOk then BtnSure:setTitleText(sOk) end
	if sNo then BtnCancel:setTitleText(sNo) end
	
	
	if iStyle then
		local sz = ccui.Helper:seekWidgetByName(rootNode, "BkgFrame"):getContentSize()
		if iStyle == 1 then
			BtnCancel:setVisible(true)
			BtnSure:setContentSize(sz.width/2, BtnSure:getContentSize().height)
			BtnSure:setPositionX(sz.width*0.75)
			ccui.Helper:seekWidgetByName(rootNode, "Line2"):setVisible(true)
		elseif iStyle == 2 then
			BtnCancel:setVisible(false)
			BtnSure:setContentSize(sz.width, BtnSure:getContentSize().height)
			BtnSure:setPositionX(sz.width*0.5)
			ccui.Helper:seekWidgetByName(rootNode, "Line2"):setVisible(false)
		end
	end
	
	BtnSure:addTouchEventListener(function(sender,touchType)
		if touchType == ccui.TouchEventType.ended then
			if callback then callback(1) end
			self:removeFromParent()
		end
	end)
	BtnCancel:addTouchEventListener(function(sender,touchType)
		if touchType == ccui.TouchEventType.ended then
			if callback then callback(0) end
			self:removeFromParent()
		end
	end)
end

return MsgBox