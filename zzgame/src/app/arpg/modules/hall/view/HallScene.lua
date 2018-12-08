----------------
-- 大厅场景
----------------
clsHallScene = class("clsHallScene", clsScene)

function clsHallScene:ctor()
	clsScene.ctor(self)
	ClsUIManager.GetInstance():ShowView("clsHallUI")
end

function clsHallScene:dtor()
	
end

const.SCENE_CFG.clsHallScene = { scene_cls = clsHallScene }
