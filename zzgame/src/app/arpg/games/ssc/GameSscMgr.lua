-------------------------
-- ssc游戏管理器
-------------------------
ClsGameSscMgr = class("ClsGameSscMgr", clsGameInterface)
ClsGameSscMgr.__is_singleton = true

function ClsGameSscMgr:ctor()
	clsGameInterface.ctor(self)
end

function ClsGameSscMgr:dtor()
	
end

function ClsGameSscMgr:GetBallCombineInfo(tid)
	return { billType = const.BILL_TYPE.SINGLE, onceCnt = 1, maxCnt = 1 }
end