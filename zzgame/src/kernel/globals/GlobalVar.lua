-------------------------
-- 全局变量
-------------------------
g_AllProtocal = {}
g_AllStruct = {}
g_AllRespFuncName = {}
g_AllFailFuncName = {}
g_AllErrorFuncName = {}
g_ContentScaleFactor = 1
g_CurEditY = 0

if cc.Director:getInstance():getOpenGLView() then
	g_ContentScaleFactor = cc.Director:getInstance():getOpenGLView():getContentScaleFactor()
end
