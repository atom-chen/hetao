-------------------------
-- 节点
-------------------------
local Node = cc.Node 

function Node:setTouchEnabled(bFlag)
		local function onToucheBegan(touch, event)
			return utils.IsNodeRealyVisible(self)
		end
		local function onToucheMoved(touch, event) 
			
		end
		local function onToucheEnded(touch, event) 
			if self.OnClickBlock then 
				self.OnClickBlock() 
			else
				if self.bCloseWhenClickMask then
					self:removeSelf()
				end
			end
		end
		local listener = cc.EventListenerTouchOneByOne:create()
		listener:registerScriptHandler(onToucheBegan, cc.Handler.EVENT_TOUCH_BEGAN)
		listener:registerScriptHandler(onToucheMoved, cc.Handler.EVENT_TOUCH_MOVED)
		listener:registerScriptHandler(onToucheEnded, cc.Handler.EVENT_TOUCH_ENDED)
		self:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self)
		listener:setSwallowTouches(true)
		return self 
end



clsNode = class("clsNode", function() return cc.Node:create() end)

function clsNode:ctor(parent)
	self:EnableNodeEvents()
	if parent then KE_SetParent(self, parent) end
end

function clsNode:dtor()
	
end
