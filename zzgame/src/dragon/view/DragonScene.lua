----------------
-- 长龙场景
----------------

local clsDragonScene = class("clsDragonScene", clsScene)

function clsDragonScene:ctor()
	clsScene.ctor(self)
    ClsUIManager.GetInstance():ShowView("clsDragonMainUI")
end

function clsDragonScene:dtor()
	
end

const.SCENE_CFG.clsDragonScene = { scene_cls = clsDragonScene, freemem = true }

return clsDragonScene