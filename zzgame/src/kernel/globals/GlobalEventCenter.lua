-------------------------
-- 全局事件中心
-------------------------
g_EventMgr = clsEventSource.new()

--APP事件
g_EventMgr:RegisterEventType("APP_ENTER_BACKGROUND")	--切入后台
g_EventMgr:RegisterEventType("APP_ENTER_FOREGROUND")	--切回前台
g_EventMgr:RegisterEventType("syswnd_size_changed")
--网络核心事件
g_EventMgr:RegisterEventType("NET_STATE_CHANGE")
g_EventMgr:RegisterEventType("NET_CONNECTING")			--连接中
g_EventMgr:RegisterEventType("NET_CONNECT_SUCC")		--连接成功
g_EventMgr:RegisterEventType("NET_DISCONNECTED")		--断网
g_EventMgr:RegisterEventType("NET_NETKIND_CHANGE")		--网络类型切换（无 2G 3G 4G 5G WIFI）
g_EventMgr:RegisterEventType("NET_RECIEVE_PTO")			--收到协议
g_EventMgr:RegisterEventType("NET_SEND_PTO")			--发送协议
--场景切换
g_EventMgr:RegisterEventType("LEAVE_SCENE")				--离开场景
g_EventMgr:RegisterEventType("ENTER_SCENE")				--进入场景
--地图切换
g_EventMgr:RegisterEventType("LEAVE_MAP")				--离开地图
g_EventMgr:RegisterEventType("ENTER_MAP")				--进入地图
--剧情事件
g_EventMgr:RegisterEventType("STORY_BEGIN")				--剧情播放开始
g_EventMgr:RegisterEventType("STORY_END")				--剧情播放结束
