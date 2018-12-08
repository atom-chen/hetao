-------------------------
-- 层
-------------------------
clsLayer = class("clsLayer", function() return cc.Layer:create() end)

function clsLayer:ctor(parent)
	self:EnableNodeEvents()
	if parent then KE_SetParent(self, parent) end
end

function clsLayer:dtor()
	
end

--[[
function clsLayer:SwallowEvent(bSwallow)
	if bSwallow then
		if self.mListener then
			self:getEventDispatcher():removeEventListener(self.mListener)
			self.mListener = nil
		end
		
		local function onToucheBegan(touch, event)
			return true
		end
		local function onToucheMoved(touchs, event) 
			
		end
		local function onToucheEnded(touchs, event) 
			
		end
		self.mListener = cc.EventListenerTouchOneByOne:create()
		local listener = self.mListener
		listener:registerScriptHandler(onToucheBegan, cc.Handler.EVENT_TOUCH_BEGAN)
		listener:registerScriptHandler(onToucheMoved, cc.Handler.EVENT_TOUCH_MOVED)
		listener:registerScriptHandler(onToucheEnded, cc.Handler.EVENT_TOUCH_ENDED)
		self:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self)
		listener:setSwallowTouches(true)
	else 
		if self.mListener then
			self:getEventDispatcher():removeEventListener(self.mListener)
			self.mListener = nil
		end
	end
end
]]--
