-------------------------
-- 拖动
-------------------------
ClsDragManager = class("ClsDragManager")
ClsDragManager.__is_singleton = true

function ClsDragManager:ctor()
	self._drag_target = nil
end

function ClsDragManager:dtor()
    
end

function ClsDragManager:SetDragTarget(obj, funcOnDragBegin, funcOnDragMoving, funcOnDragEnd)
	self._drag_target = obj
	self._OnDragBegin = funcOnDragEnd
	self._OnDragMoving = funcOnDragMoving
	self._OnDragEnd = funcOnDragEnd
	
	self:init_events()
end

function ClsDragManager:init_events()
	local event_layer = ClsLayerManager.GetInstance():GetLayer(const.LAYER_DRAG)
	if event_layer.mListener then return end
	
	local function onToucheBegan(touch, event)
		if not self._drag_target then return false end
		if self._OnDragBegin then self._OnDragBegin() end
		return true
	end
	
	local function onToucheMoved(touchs, event) 
		if self._OnDragMoving then self._OnDragMoving() end
	end
	
	local function onToucheEnded(touchs, event) 
		if self._OnDragEnd then self._OnDragEnd() end
	end
	
	event_layer.mListener = cc.EventListenerTouchOneByOne:create()
	local listener = event_layer.mListener
	listener:registerScriptHandler(onToucheBegan, cc.Handler.EVENT_TOUCH_BEGAN)
	listener:registerScriptHandler(onToucheMoved, cc.Handler.EVENT_TOUCH_MOVED)
	listener:registerScriptHandler(onToucheEnded, cc.Handler.EVENT_TOUCH_ENDED)
	event_layer:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, event_layer)
	listener:setSwallowTouches(true)
end

