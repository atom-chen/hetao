-------------------------
-- 网络引擎
-------------------------
module("netcore", package.seeall)

local TCP_CONST = {
	CONNECT_TIMEOUT = 3,  --秒
	
	STAT_CONNECTING = 1,
	STAT_FAILED = 2,
	STAT_CONNECTED = 3,
	STAT_CLOSED = 4,
	
--	EVENT_CONNECTING = "EVENT_CONNECTING",
--	EVENT_CONNECT_FAIL = "EVENT_CONNECT_FAIL",
--	EVENT_CONNECT_SUCC = "EVENT_CONNECT_SUCC",
--	EVENT_CLOSED = "EVENT_CLOSED",
--	EVENT_SEND_DATA = "EVENT_SEND_DATA",
--	EVENT_RECV_DATA = "EVENT_RECV_DATA"
--	EVENT_TIMEOUT = "EVENT_TIMEOUT",
}

local socket = require("socket")

local function isIpv6(domain)
	local result = socket.dns.getaddrinfo(domain)
	if result then
		for k,v in pairs(result) do
			if v.family == "inet6" then
				return true
			end
		end
	end
	return false
end


ClsTcpClient = class("ClsTcpClient")
ClsTcpClient.__is_singleton = true

function ClsTcpClient:ctor()
	self._ip = nil
	self._port = nil
	self._tcp = nil
	self._cur_state = nil
	self.connectingTime = 0
end 

function ClsTcpClient:dtor()

end 

function ClsTcpClient:onConnecting() end 
function ClsTcpClient:onConnectFail() end 
function ClsTcpClient:onConnectTimeout() end 
function ClsTcpClient:onConnectSucc() end 
function ClsTcpClient:onClosed() end 
function ClsTcpClient:onRecvData(data) end 
function ClsTcpClient:onSendData(bSucc) end 

function ClsTcpClient:setConnectingHandler(onConnecting)
	self.onConnecting = onConnecting
end
function ClsTcpClient:setConnectFailHandler(onConnectFail)
	self.onConnectFail = onConnectFail
end
function ClsTcpClient:setConnectTimeoutHandler(onConnectTimeout)
	self.onConnectTimeout = onConnectTimeout
end
function ClsTcpClient:setConnectSuccHandler(onConnectSucc)
	self.onConnectSucc = onConnectSucc
end
function ClsTcpClient:setClosedHandler(onClosed)
	self.onClosed = onClosed
end
function ClsTcpClient:setRecvDataHandler(onRecvData)
	self.onRecvData = onRecvData
end
function ClsTcpClient:setSendDataHandler(onSendData)
	self.onSendData = onSendData
end

--连接服务器
function ClsTcpClient:Connect(Ip, Port)
	assert(Ip and Port, "参数错误")
	if (self._cur_state == TCP_CONST.STAT_CONNECTING or self._cur_state == TCP_CONST.STAT_CONNECTED) then
		logger.net("当前状态拒绝连接：", self._cur_state)
		return
	end
	
	self._ip = Ip
	self._port = Port

	if not self._tcp then
		if isIpv6(self._ip) then
			self._tcp = socket.tcp6()
		else
			self._tcp = socket.tcp()
		end
	end
	if not self._tcp then
		logger.net("创建Socket失败")
		return
	end
	self._tcp:settimeout(0)

	logger.net("开始连接服务器：", Ip, Port)
	self._cur_state = TCP_CONST.STAT_CONNECTING
	self.connectingTime = 0
	g_EventMgr:FireEvent("NET_CONNECTING")
	self.onConnecting()
	
	-- start global scheduler
	assert(not self.tmr)
	KE_KillTimer(self.tmr)
	self.tmr = KE_SetInterval(1, function(dt)
		self:_update(dt)
	end)
end 

--发送数据
function ClsTcpClient:SendData(data)
	if self._cur_state ~= TCP_CONST.STAT_CONNECTED then
		logger.net("发送数据失败：尚未建立连接")
		return
	end
	if not self._tcp then
		logger.net("发送数据失败：尚未初始化网络")
		return
	end
	local rlt, errStr = self._tcp:send(data)
	if rlt then
		logger.net("[send:]", string.len(data))
	else
		logger.net("[send fail:]", rlt, errStr)
	end
	self.onSendData(rlt)
end

-- 主动关闭
function ClsTcpClient:Close()
	if self._cur_state == TCP_CONST.STAT_CONNECTING then
		logger.net("当前状态拒绝关闭连接：", self._cur_state)
		return
	end
	logger.net("主动关闭网络")
	if self._tcp then
		self._tcp:close()
	end
--	self._tcp = nil    --在_update中置空
end

-- 主动断网
function ClsTcpClient:Disconnect()
	logger.net("主动断开连接")
	KE_KillTimer(self.tmr)
	self.tmr = nil 
	self._tcp:shutdown()
	self._tcp:close()
	self._tcp = nil
	self._cur_state = TCP_CONST.STAT_CLOSED
	self.onClosed()
	g_EventMgr:FireEvent("NET_DISCONNECTED")
end

------------ private ----------------------------------------------------
function ClsTcpClient:_connectAndCheck()
	local rlt, errStr = self._tcp:connect(self._ip, self._port)
	return rtn == 1 or errStr == "already connected"
end

function ClsTcpClient:_update(dt)
	if self._cur_state == TCP_CONST.STAT_CONNECTED then
		local _body, _status, _partial = self._tcp:receive("*a")	-- receive mode: get all data
--		logger.net("-----", _body, _status, _partial)
		
		-- 1. If receive successful
		if _body and string.len(_body) > 0 then
			logger.net("[recv:]",string.len(_body))
			self.onRecvData(_body)
			return
		end

		-- 2. If got an error. Firstly, transfer _partial data.
		if _partial and string.len(_partial) > 0 then
			logger.net("[recv:]",string.len(_partial))
			self.onRecvData(_partial)
			-- Not return here, continue to check the error type
		end

		-- 3. Error type "timeout" will be ignored; but "closed" need handling.
		if _status == "closed" or _status == "Socket is not connected" then
			logger.net("断网了！！！")
			-- if close from server, safty free LuaSocket resource
			self._tcp:close()
			self._tcp = nil
			self._cur_state = TCP_CONST.STAT_CLOSED
			g_EventMgr:FireEvent("NET_DISCONNECTED")
			self.onClosed()
			KE_KillTimer(self.tmr)
			self.tmr = nil 
		end
		
		return
	end

	if self._cur_state == TCP_CONST.STAT_CONNECTING then
		if self:_connectAndCheck() then
			self._cur_state = TCP_CONST.STAT_CONNECTED
			logger.net("连接服务器成功",self._ip,self._port)
			g_EventMgr:FireEvent("NET_CONNECT_SUCC")
			self.onConnectSucc()
			return
		else
			self.connectingTime = self.connectingTime + dt
			if self.connectingTime >= TCP_CONST.CONNECT_TIMEOUT then
				self._cur_state = TCP_CONST.STAT_FAILED
				logger.net("连接服务器失败！",self._ip,self._port)
				g_EventMgr:FireEvent("NET_DISCONNECTED")
				self.onConnectFail()
				-- stop scheduler
				KE_KillTimer(self.tmr)
				self.tmr = nil 
			end
			return
		end
	end
end
