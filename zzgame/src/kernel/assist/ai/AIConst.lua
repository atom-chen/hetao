-------------------------
-- ai常量
-------------------------
module("ai",package.seeall)

local CmpFunc = {
	["lt"] = function(left,right) return left <  right end,
	["le"] = function(left,right) return left <= right end,
	["eq"] = function(left,right) return left == right end,
	["ge"] = function(left,right) return left >= right end,
	["gt"] = function(left,right) return left >  right end,
}
function AiCmp(sCmpType, leftValue, rightValue)
	return CmpFunc[sCmpType](leftValue, rightValue)
end

---------------------------------------

-- BT节点状态 BT树状态
BTSTATE = {
	RUNNING = -1,
	SUCC = 1,
	FAIL = 0,	
}

---------------------------------------

-- 任务状态
BT_TASK_STATE = {
	WAITING = 1,	--待执行
	RUNNING = 2,	--执行中
	SUCCESS = 3,	--执行成功
	FAIL = 4		--执行失败
}

-- 任务类型
BT_TASK_TYPE = {
	TP_FIGHT = 1,		--战斗任务
	TP_TALK2NPC = 2,	--对话NPC
	TP_ZAZEN = 3,		--打坐
	TP_COLLECT = 4,		--采集
}

---------------------------------------

-- 能否思考
function CanThink(theOwner)
	return not FORBIT_THINK_STATES[theOwner:GetActState()] 
end

function IsValidBtNodeState(v)
	return v==BTSTATE.RUNNING or v==BTSTATE.SUCC or v==BTSTATE.FAIL
end

function IsValidBtNodeResult(v)
	return v==BTSTATE.SUCC or v==BTSTATE.FAIL
end
