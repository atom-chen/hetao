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

local MAX_RECONNECT_TIMES = 3

local clsWebSock = class("clsWebSock")

clsWebSock.STATE_UN_CONNECTED = 0
clsWebSock.STATE_CONNECTING = 1
clsWebSock.STATE_CONNECT_SUCC = 3
clsWebSock.STATE_CONNECT_FAIL = 4

function clsWebSock:ctor(url)
    self._url = url
    self._cur_state = clsWebSock.STATE_UN_CONNECTED
    self._bClosed = false
    self._reconnectTime = MAX_RECONNECT_TIMES

    if url and url ~= "" then
        self:Open(url)
    end
end

function clsWebSock:dtor()
    self._bClosed = true
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
            utils.TellMe("连接聊天室成功")
            print(string.format("连接成功:%s  protocal:%s", self._ws.url, self._ws.protocol))
            g_EventMgr:FireEvent("WS_CONNECT_SUCC")
        end
        
        local WS_ERROR_TBL = require("dragon.config").WS_ERROR_TBL
        local function onMessage(strData)
            print("[S--->C]: ", strData)
            local data = strData and json.decode(strData)
            if data then
                if data.msg == "err" then
                    if WS_ERROR_TBL[data.code] then
                        utils.TellMe(WS_ERROR_TBL[data.code])
                    end
                end
            else
                data = strData
            end
            g_EventMgr:FireEvent("WS_RECV_DATA", data)
        end
        
        local function onClose(strData)
            self._cur_state = clsWebSock.STATE_UN_CONNECTED
            self._ws = nil
            print("连接已经关闭.", self._url)
        end
        
        local function onError(strData)
            print("连接失败", self._url)
            self._cur_state = clsWebSock.STATE_CONNECT_FAIL
            utils.TellMe("连接聊天室失败")
            --断线重连
            if not self._bClosed and not self._tmr_reconnect then
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
        self._ws:registerScriptHandler(onOpen, cc.WEBSOCKET_OPEN)
        self._ws:registerScriptHandler(onMessage, cc.WEBSOCKET_MESSAGE)
        self._ws:registerScriptHandler(onClose, cc.WEBSOCKET_CLOSE)
        self._ws:registerScriptHandler(onError, cc.WEBSOCKET_ERROR)
    end
end

function clsWebSock:SendMsg(strMsg)
    if not strMsg then print("发送内容不可为空") return end
    if self._ws then
        if type(strMsg) == "table" then
            strMsg = json.encode(strMsg)
        end
        print("[C--->S]", strMsg)
        self._ws:sendString(strMsg)
        return
    else
        print("发送失败，尚未创建WebSocket对象")
    end
    if self._cur_state ~= clsWebSock.STATE_CONNECT_SUCC then
        print("发送失败，尚未正常连接服务器：当前网络状态：", self._cur_state)
    end
end

return clsWebSock
