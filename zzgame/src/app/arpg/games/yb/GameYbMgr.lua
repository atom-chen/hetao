-------------------------
-- yb游戏管理器
-------------------------
ClsGameYbMgr = class("ClsGameYbMgr", clsGameInterface)
ClsGameYbMgr.__is_singleton = true

function ClsGameYbMgr:ctor()
	clsGameInterface.ctor(self)
end

function ClsGameYbMgr:dtor()
	
end

function ClsGameYbMgr:GetBallCombineInfo(tid)
	return { billType = const.BILL_TYPE.SINGLE, onceCnt = 1, maxCnt = 1 }
end