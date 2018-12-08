-------------------------
-- 基础UI 1
-------------------------
module("ui", package.seeall)

clsPanelUI = class("clsPanelUI", clsBaseUI)

function clsPanelUI:ctor(parent, argInfo)
	clsBaseUI.ctor(self, parent, "uistu/HallUI.csb")
end

function clsPanelUI:dtor()
	
end

-- 注册全局事件
function clsPanelUI:InitGlbEvents()
	
end

-- 注册UI事件
function clsPanelUI:InitUiEvents()

end
