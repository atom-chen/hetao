-------------------------
-- K3游戏管理器
-------------------------
ClsGameK3Mgr = class("ClsGameK3Mgr", clsGameInterface)
ClsGameK3Mgr.__is_singleton = true

function ClsGameK3Mgr:ctor()
	clsGameInterface.ctor(self)
end

function ClsGameK3Mgr:dtor()
	
end

function ClsGameK3Mgr:GetBallCombineInfo(tid)
	return { billType = const.BILL_TYPE.SINGLE, onceCnt = 1, maxCnt = 1 }
end