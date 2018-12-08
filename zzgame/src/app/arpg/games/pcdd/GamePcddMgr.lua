-------------------------
-- pcdd游戏管理器
-------------------------
ClsGamePcddMgr = class("ClsGamePcddMgr", clsGameInterface)
ClsGamePcddMgr.__is_singleton = true

function ClsGamePcddMgr:ctor()
	clsGameInterface.ctor(self)
end

function ClsGamePcddMgr:dtor()
	
end

function ClsGamePcddMgr:GetBallCombineInfo(tid)
	local groupInfo = self:GetMenuOfGroup(nil, tid)
	if not groupInfo then return nil end
	if groupInfo.sname == "tmb3" then
		return { billType = const.BILL_TYPE.JustN, onceCnt = 3, maxCnt = 3 }
	end
	return { billType = const.BILL_TYPE.SINGLE, onceCnt = 1, maxCnt = 1 }
end