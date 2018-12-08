-------------------------
-- kl10游戏管理器
-------------------------
ClsGameKL10Mgr = class("ClsGameKL10Mgr", clsGameInterface)
ClsGameKL10Mgr.__is_singleton = true

function ClsGameKL10Mgr:ctor()
	clsGameInterface.ctor(self)
end

function ClsGameKL10Mgr:dtor()
	
end

function ClsGameKL10Mgr:GetBallCombineInfo(tid)
	local groupInfo = self:GetMenuOfGroup(nil, tid)
	if not groupInfo then return nil end
	
	if groupInfo.sname == "rx2" then
		return { billType = const.BILL_TYPE.MxN, onceCnt = 2, maxCnt = -1 }
	elseif groupInfo.sname == "rx3" then
		return { billType = const.BILL_TYPE.MxN, onceCnt = 3, maxCnt = -1 }
	elseif groupInfo.sname == "rx4" then
		return { billType = const.BILL_TYPE.MxN, onceCnt = 4, maxCnt = -1 }
	elseif groupInfo.sname == "rx5" then
		return { billType = const.BILL_TYPE.MxN, onceCnt = 5, maxCnt = -1 }
	elseif groupInfo.sname == "rx2z" then
		return { billType = const.BILL_TYPE.MxN, onceCnt = 2, maxCnt = -1 }
	end
	return { billType = const.BILL_TYPE.SINGLE, onceCnt = 1, maxCnt = 1 }
end
