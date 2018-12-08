-------------------------
--键盘事件
-------------------------
module("keyboard", package.seeall)

local function on_win32(key_code, event)
	if device.platform ~= "windows" then return end
	
	if key_code == cc.KeyCode.KEY_M then
		DumpDebugInfo()
	elseif key_code == cc.KeyCode.KEY_F1 then
		if ClsUIManager:GetInstance():GetWindow("clsGmUI") then
			ClsUIManager.GetInstance():DestroyWindow("clsGmUI")
		else 
			ClsUIManager.GetInstance():ShowPopWnd("clsGmUI")
		end
	end 
end

function InitKeboardEvent(self, cur_scene)
	assert(cur_scene, "注册键盘事件失败")
	
	self._pressTbl = {}
	
	--
	local function onKeyPressed(key_code, event)
		self._pressTbl[key_code] = true
	end
	local function onKeyReleased(key_code, event)
		self._pressTbl[key_code] = false
		
		if key_code == cc.KeyCode.KEY_BACK then
			local bFlag = ClsUIManager.GetInstance():DestoryToppestView()
			if not bFlag then
				ClsStateMachine.GetInstance():AskExitApp()
			end
		end
		
		on_win32(key_code, event)
	end
	local evt_layer = cc.Layer:create()
	cur_scene:addChild(evt_layer, const.LAYER_TOPEST)
	local listener = cc.EventListenerKeyboard:create()
	listener:registerScriptHandler(onKeyPressed, cc.Handler.EVENT_KEYBOARD_PRESSED)
	listener:registerScriptHandler(onKeyReleased, cc.Handler.EVENT_KEYBOARD_RELEASED)
	evt_layer:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, evt_layer)
end

function IsKeyPressed(self, key_code)
	return self._pressTbl[key_code]
end

function IsTheseKeyPressed(self, key_code_list)
	for _, key_code in ipairs(key_code_list) do 
		if not self._pressTbl[key_code] then
			return false 
		end
	end
	return true 
end
