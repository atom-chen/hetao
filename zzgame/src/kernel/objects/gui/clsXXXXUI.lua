-------------------------
-- UI模板
-------------------------
clsXXXXUI = class("clsXXXXUI", clsBaseUI)

function clsXXXXUI:ctor(parent)
	clsBaseUI.ctor(self, parent, "uistu/XXXXUI.csb")
	self:InitUiEvents()
	self:InitGlbEvents()
end

--@"cleanup"时回调
function clsXXXXUI:dtor()
	
end

--@"enter"时回调
function clsXXXXUI:onEnter()
	clsBaseUI.onEnter()
end 

--@"exit"时回调
function clsXXXXUI:onExit()
	clsBaseUI.onExit()
end

-- 注册控件事件
function clsXXXXUI:InitUiEvents()
	
end

-- 注册全局事件
function clsXXXXUI:InitGlbEvents()
	
end
