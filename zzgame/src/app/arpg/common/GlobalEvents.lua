-------------------------
-- 游戏逻辑层的全局事件
-------------------------
--状态机
g_EventMgr:RegisterEventType("LOGIN_STATE")				--登录状态变更
--游戏逻辑
g_EventMgr:RegisterEventType("GAME_CUR_WANFA")
g_EventMgr:RegisterEventType("GAME_ADD_BILLPAPER")
g_EventMgr:RegisterEventType("GAME_DEL_BILLPAPER")
g_EventMgr:RegisterEventType("GAME_BILL_SUCC")
g_EventMgr:RegisterEventType("INPUT_YZM")
g_EventMgr:RegisterEventType("screeting")
g_EventMgr:RegisterEventType("thetime")
g_EventMgr:RegisterEventType("LEDNUM")
g_EventMgr:RegisterEventType("cancelbet")
g_EventMgr:RegisterEventType("RechargeOver")
g_EventMgr:RegisterEventType("redbag_cd")
g_EventMgr:RegisterEventType("OVERTIPS")
