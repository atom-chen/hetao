---------------------------------
-- websocket类
---------------------------------
-- 使用示例：
--[[
local testWS = clsWebSock.new("ws://echo.websocket.org")
testWS:SendMsg("zhong guo ren 中国人")
]]
---------------------------------
local json = require("kernel.framework.json")
local crypto = require("kernel.framework.crypto")
local WS_ERROR_TBL = require("dragon.config").WS_ERROR_TBL

local MAX_RECONNECT_TIMES = 3

local clsWebSock = class("clsWebSock")

clsWebSock.STATE_UN_CONNECTED = 0
clsWebSock.STATE_CONNECTING = 1
clsWebSock.STATE_CONNECT_SUCC = 3
clsWebSock.STATE_CONNECT_FAIL = 4

function clsWebSock:ctor(url)
    self._url = url
    self._cur_state = clsWebSock.STATE_UN_CONNECTED
    self._bDestroyed = false
    self._reconnectTime = MAX_RECONNECT_TIMES

    if url and url ~= "" then
        self:Open(url)
    end
end

function clsWebSock:dtor()
    self._bDestroyed = true
    self:Close()
end

function clsWebSock:Close()
    print("关闭连接：", self._url)
    self._reconnectTime = MAX_RECONNECT_TIMES

    KE_KillTimer(self._tmr_reconnect)
    self._tmr_reconnect = nil

    if self._ws then
        self._ws:close()
        self._ws = nil
    end
end

function clsWebSock:Open(url)
    if not url or url == "" then 
        print("参数错误")
        return 
    end

    if self._ws and self._url == url then
        if self._cur_state == clsWebSock.STATE_CONNECTING then
            print("正在连接", url, "请等待")
            return
        end
        if self._cur_state == clsWebSock.STATE_CONNECT_SUCC then
            print("已经连接", url)
            return
        end
    end

    if self._ws then
        self._ws:close()
        self._ws = nil
    end

    self._url = url
    self._cur_state = clsWebSock.STATE_CONNECTING
    print("开始连接：", url)

    if not self._ws then 
        self._ws = WebSocket:create(url)
    end

    if nil ~= self._ws then
        local function onOpen(strData)
            self._cur_state = clsWebSock.STATE_CONNECT_SUCC
            self._reconnectTime = MAX_RECONNECT_TIMES
            utils.TellMe("连接聊天室成功")
            print(string.format("连接成功:%s  protocal:%s", self._ws.url, self._ws.protocol))
            g_EventMgr:FireEvent("WS_CONNECT_SUCC")
        end
        
        local function onMessage(strData)
            self:DealMsg(strData)
        end
        
        local function onClose(strData)
            self._cur_state = clsWebSock.STATE_UN_CONNECTED
            self._ws = nil
            print("连接已经关闭.", self._url)
            utils.TellMe("网络连接中断，正在尝试重连，请等待")
            --断线重连
            self:Reconnect()
        end
        
        local function onError(strData)
            print("连接失败", self._url)
            self._cur_state = clsWebSock.STATE_CONNECT_FAIL
            utils.TellMe("连接聊天室失败")
            --断线重连
            self:Reconnect()
        end
        self._ws:registerScriptHandler(onOpen, cc.WEBSOCKET_OPEN)
        self._ws:registerScriptHandler(onMessage, cc.WEBSOCKET_MESSAGE)
        self._ws:registerScriptHandler(onClose, cc.WEBSOCKET_CLOSE)
        self._ws:registerScriptHandler(onError, cc.WEBSOCKET_ERROR)
    end
end

function clsWebSock:Reconnect()
    --断线重连
    if not self._bDestroyed and not self._tmr_reconnect then
        if self._reconnectTime > 0 then
            self._reconnectTime = self._reconnectTime - 1
            self._tmr_reconnect = KE_SetTimeout(60, function()
                self._tmr_reconnect = nil
                --重连
                print("重连：", self._reconnectTime, self._url)
                self:Open(self._url)
            end)
        end
    end
end

function clsWebSock:DealMsg(strData)
    print("[S--->C]: ", strData)
    local data = strData and json.decode(strData)
    if data then
        if data.type == "ping" then
            self:SendMsg({type = "pong"})

        elseif data.type == "cmd" then
            if data.msg == "err" then
                if WS_ERROR_TBL[data.code] then
                    utils.TellMe(WS_ERROR_TBL[data.code])
                end
                if data.code == 2 or data.code == 1 then
                    self:Close()
                    self:Reconnect()
                end
            elseif data.msg == "group_close" then
                utils.TellMe("聊天室关闭")
            elseif data.msg == "user_online" then
            --  utils.TellMe("聊天室人数发生变化")
            elseif data.msg == "user_logout" then
                utils.TellMe("被剔除聊天室")
            elseif data.msg == "user_disabled" then
                utils.TellMe("用户被停用")
            elseif data.msg == "user_offline" then
                utils.TellMe("客服离线")
            end
            
        elseif data.type == "notice" then
            utils.TellMe(data.msg)
            
        elseif data.type == "txt" then
            g_EventMgr:FireEvent("WS_CHAT_DATA", data)
        elseif data.type == "img" then
            g_EventMgr:FireEvent("WS_CHAT_DATA", data)
        elseif data.type == "lottery" then
            g_EventMgr:FireEvent("WS_CHAT_DATA", data)
        elseif data.type == "standings" then
            g_EventMgr:FireEvent("WS_CHAT_DATA", data)
        end
    end
end

function clsWebSock:SendMsg(strMsg)
    if type(strMsg) == "table" then
        strMsg = json.encode(strMsg)
    end
    if not strMsg or strMsg == "" then 
        print("发送内容不可为空") 
        utils.TellMe("请输入有效的信息")
        return false 
    end

    if self._ws then
        print("[C--->S]", strMsg)
        self._ws:sendString(strMsg)
        return true
    else
        print("发送失败，尚未创建WebSocket对象")
        self:Open(self._url)
        utils.TellMe("消息发送失败，请重试")
    end
    if self._cur_state ~= clsWebSock.STATE_CONNECT_SUCC then
        print("发送失败，尚未正常连接服务器：当前网络状态：", self._cur_state)
        self:Open(self._url)
        utils.TellMe("消息发送失败，请重试")
    end
    return false
end

return clsWebSock
