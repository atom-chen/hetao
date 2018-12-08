-------------------------
-- pk10游戏管理器
-------------------------
ClsGamePk10Mgr = class("ClsGamePk10Mgr", clsGameInterface)
ClsGamePk10Mgr.__is_singleton = true

function ClsGamePk10Mgr:ctor()
	clsGameInterface.ctor(self)
end

function ClsGamePk10Mgr:dtor()
	
end

function ClsGamePk10Mgr:GetBallCombineInfo(tid)
	return { billType = const.BILL_TYPE.SINGLE, onceCnt = 1, maxCnt = 1 }
end