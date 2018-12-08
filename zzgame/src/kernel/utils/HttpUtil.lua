-----------------------------------------
--HTTP辅助类
-----------------------------------------
local json = require("kernel.framework.json")
local crypto = require("kernel.framework.crypto")

local TIMEWAIT = 0.5
local TIMEOUT = 2

HttpUtil = {}
HttpUtil.token = ""

function HttpUtil:converTable2String(params)
	if not params then return "" end
	local s = ""
	for k, v in pairs(params) do
		if s ~= "" then s = s.."&" end
		s = s..k.."="..v
	end
	return s
end

function HttpUtil:GetHttpHeadKey()
	return HTTP_HEAD_KEY
end

function HttpUtil:GetHttpHeadValue()
	local strValue = HTTP_HEAD_VAL_1
	if HttpUtil.token and HttpUtil.token ~= "" then 
		strValue = HTTP_HEAD_VAL_1 .. ";" .. HttpUtil.token
	end
	return strValue
end

function HttpUtil:GetHttpHead()
	local strValue = HTTP_HEAD_VAL_1
	if HttpUtil.token and HttpUtil.token ~= "" then 
		strValue = HTTP_HEAD_VAL_1 .. ";" .. HttpUtil.token
	end
	return HTTP_HEAD_KEY..":"..strValue
end

function HttpUtil:autoHttpHead(xhr)
	local strValue = HTTP_HEAD_VAL_1
	if HttpUtil.token and HttpUtil.token ~= "" then 
		strValue = HTTP_HEAD_VAL_1 .. ";" .. HttpUtil.token
	end
	xhr:setRequestHeader(HTTP_HEAD_KEY, strValue)
	xhr:setRequestHeader("FROMWAY", const.FROMWAY)
end

---------------------------------------------------------

function HttpUtil:SetQuiet()
	self._bQuiet = true
end

function HttpUtil:callOkHttpGet(assist_info, url, addr, params, respType, callback, tArgs)
	local strParam = params
	if type(strParam) == "table" then
		strParam = self:converTable2String(strParam)
	end
	strParam = strParam or ""
	url = url or SERVER_URL
	local real_url = url
	if addr and addr ~= "" then 
		real_url = real_url .. "/" .. addr
	end
	if strParam and strParam ~= "" then 
		real_url = real_url .. "?" .. strParam
	end 
	logger.net("Http[GET]请求:" .. real_url)
	
	PlatformHelper.setHeader(HttpUtil:GetHttpHeadKey(), HttpUtil:GetHttpHeadValue())
	
	if assist_info.bShowLoading then
		assist_info.bShowLoading = false
		assist_info._tmrHttpWait = KE_SetAbsTimeout(TIMEWAIT, function()
			utils.BeginWaiting()
			assist_info.bShowLoading = true
			assist_info._tmrHttpTimeout = KE_SetAbsTimeout(TIMEOUT, function() 
				logger.net(string.format("http[GET]超时: %s", real_url))
	--			xhr:abort() 
				if assist_info.bShowLoading then utils.FinishWaiting() end
				assist_info.bShowLoading = false
	--			callback(true, nil, tArgs, assist_info)
			end)
		end)
	end
	
	local function succCallback(resp_data)
		if assist_info.bShowLoading then utils.FinishWaiting() end
		KE_KillTimer(assist_info._tmrHttpWait)  
		assist_info._tmrHttpWait = nil 
		KE_KillTimer(assist_info._tmrHttpTimeout)  
		assist_info._tmrHttpTimeout = nil 
		if callback then callback(false, resp_data, tArgs, assist_info) end
	end
	local function failCallback(resp_data)
		if assist_info.bShowLoading then utils.FinishWaiting() end
		KE_KillTimer(assist_info._tmrHttpWait)  
		assist_info._tmrHttpWait = nil 
		KE_KillTimer(assist_info._tmrHttpTimeout)  
		assist_info._tmrHttpTimeout = nil 
	--	utils.TellMe("网络不给力，请重试")
		if callback then callback(true, resp_data, tArgs, assist_info) end
	end
	PlatformHelper.httpGet(real_url, succCallback, failCallback, 0)
end

function HttpUtil:callOkHttpPost(assist_info, url, addr, params, respType, callback, tArgs)
	local strParam = params
	if type(strParam) == "table" then
		strParam = self:converTable2String(strParam)
	end
	strParam = strParam or ""
	url = url or SERVER_URL
	local real_url = url
	if addr and addr ~= "" then 
		real_url = real_url .. "/" .. addr
	else 
		real_url = real_url
	end
	logger.net("Http[POST]请求: " .. real_url)
	logger.net("请求参数：", strParam)
	
	PlatformHelper.setHeader(HttpUtil:GetHttpHeadKey(), HttpUtil:GetHttpHeadValue())
	
	if assist_info.bShowLoading then
		assist_info.bShowLoading = false
		assist_info._tmrHttpWait = KE_SetAbsTimeout(TIMEWAIT, function()
			utils.BeginWaiting()
			assist_info.bShowLoading = true
			assist_info._tmrHttpTimeout = KE_SetAbsTimeout(TIMEOUT, function() 
				logger.net(string.format("http[POST]超时: %s", real_url))
	--			xhr:abort() 
				if assist_info.bShowLoading then utils.FinishWaiting() end
				assist_info.bShowLoading = false
	--			callback(true, nil, tArgs, assist_info)
			end)
		end)
	end
	
	local function succCallback(resp_data)
		if assist_info.bShowLoading then utils.FinishWaiting() end
		KE_KillTimer(assist_info._tmrHttpWait)  
		assist_info._tmrHttpWait = nil 
		KE_KillTimer(assist_info._tmrHttpTimeout)  
		assist_info._tmrHttpTimeout = nil 
		if callback then callback(false, resp_data, tArgs, assist_info) end
	end
	local function failCallback(resp_data)
		if assist_info.bShowLoading then utils.FinishWaiting() end
		KE_KillTimer(assist_info._tmrHttpWait)  
		assist_info._tmrHttpWait = nil 
		KE_KillTimer(assist_info._tmrHttpTimeout)  
		assist_info._tmrHttpTimeout = nil 
	--	utils.TellMe("网络不给力，请重试")
		if callback then callback(true, resp_data, tArgs, assist_info) end
	end
	PlatformHelper.httpPost(real_url, strParam, succCallback, failCallback, 0)
end

function HttpUtil:callExtraGet(assist_info, url, addr, params, respType, callback, tArgs)
	local strParam = params
	if type(strParam) == "table" then
		strParam = self:converTable2String(strParam)
	end
	strParam = strParam or ""
	url = url or SERVER_URL
	local real_url = url
	if addr and addr ~= "" then 
		real_url = real_url .. "/" .. addr
	end
	if strParam and strParam ~= "" then 
		real_url = real_url .. "?" .. strParam
	end 
	logger.net("Http[GET]请求:" .. real_url)
	
	if assist_info.bShowLoading then
		assist_info.bShowLoading = false
		assist_info._tmrHttpWait = KE_SetAbsTimeout(TIMEWAIT, function()
			utils.BeginWaiting()
			assist_info.bShowLoading = true
			assist_info._tmrHttpTimeout = KE_SetAbsTimeout(TIMEOUT, function() 
				logger.net(string.format("http[POST]超时: %s", real_url))
	--			xhr:abort() 
				if assist_info.bShowLoading then utils.FinishWaiting() end
				assist_info.bShowLoading = false
	--			callback(true, nil, tArgs, assist_info)
			end)
		end)
	end
	
	local extraReq 
	extraReq = cc.HTTPRequest:createWithUrl(function(evt)
		if evt.name == "completed" then
			if assist_info.bShowLoading then utils.FinishWaiting() end
			KE_KillTimer(assist_info._tmrHttpWait)  
			assist_info._tmrHttpWait = nil 
			KE_KillTimer(assist_info._tmrHttpTimeout)  
			assist_info._tmrHttpTimeout = nil 
			callback(false, extraReq:getResponseString(), tArgs, assist_info)
		elseif evt.name == "failed" then
			if assist_info.bShowLoading then utils.FinishWaiting() end
			KE_KillTimer(assist_info._tmrHttpWait)  
			assist_info._tmrHttpWait = nil 
			KE_KillTimer(assist_info._tmrHttpTimeout)  
			assist_info._tmrHttpTimeout = nil 
			callback(true, nil, tArgs, assist_info)
		end
	end, real_url, cc.kCCHTTPRequestMethodGET)
	extraReq:addRequestHeader(HttpUtil:GetHttpHead())
	extraReq:addRequestHeader("FROMWAY:"..const.FROMWAY)
	if assist_info.bShowLoading then utils.BeginWaiting() end
	extraReq:start()
end

function HttpUtil:callExtraPost(assist_info, url, addr, params, respType, callback, tArgs)
	local strParam = params
	if type(strParam) == "table" then
		strParam = self:converTable2String(strParam)
	end
	strParam = strParam or ""
	url = url or SERVER_URL
	local real_url = url
	if addr and addr ~= "" then 
		real_url = real_url .. "/" .. addr
	else 
		real_url = real_url
	end
	logger.net("Http[POST]请求: " .. real_url)
	logger.net("请求参数：", strParam)
	
	if assist_info.bShowLoading then
		assist_info.bShowLoading = false
		assist_info._tmrHttpWait = KE_SetAbsTimeout(TIMEWAIT, function()
			utils.BeginWaiting()
			assist_info.bShowLoading = true
			assist_info._tmrHttpTimeout = KE_SetAbsTimeout(TIMEOUT, function() 
				logger.net(string.format("http[POST]超时: %s", real_url))
	--			xhr:abort() 
				if assist_info.bShowLoading then utils.FinishWaiting() end
				assist_info.bShowLoading = false
	--			callback(true, nil, tArgs, assist_info)
			end)
		end)
	end
	
	local extraReq 
	extraReq = cc.HTTPRequest:createWithUrl(function(evt)
		if evt.name == "completed" then
			if assist_info.bShowLoading then utils.FinishWaiting() end
			KE_KillTimer(assist_info._tmrHttpWait)  
			assist_info._tmrHttpWait = nil 
			KE_KillTimer(assist_info._tmrHttpTimeout)  
			assist_info._tmrHttpTimeout = nil 
			callback(false, extraReq:getResponseString(), tArgs, assist_info)
		elseif evt.name == "failed" then
			if assist_info.bShowLoading then utils.FinishWaiting() end
			KE_KillTimer(assist_info._tmrHttpWait)  
			assist_info._tmrHttpWait = nil 
			KE_KillTimer(assist_info._tmrHttpTimeout)  
			assist_info._tmrHttpTimeout = nil 
			callback(true, nil, tArgs, assist_info)
		end
	end, real_url, cc.kCCHTTPRequestMethodPOST)
	extraReq:addRequestHeader(HttpUtil:GetHttpHead())
	extraReq:addRequestHeader("FROMWAY:"..const.FROMWAY)
	if params then
		for k, v in pairs(params) do
			extraReq:addFormContents(k, v)
		end
	end
	if assist_info.bShowLoading then utils.BeginWaiting() end
	extraReq:start()
end

function HttpUtil:callXhrGet(assist_info, url, addr, params, respType, callback, tArgs)
	local strParam = params
	if type(strParam) == "table" then
		strParam = self:converTable2String(strParam)
	end
	strParam = strParam or ""
	url = url or SERVER_URL
	local real_url = url
	if addr and addr ~= "" then 
		real_url = real_url .. "/" .. addr
	end
	if strParam and strParam ~= "" then 
		real_url = real_url .. "?" .. strParam
	end 
	logger.net("Http[GET]请求:" .. real_url)

	local xhr = cc.XMLHttpRequest:new()
	xhr.responseType = respType
	self:autoHttpHead(xhr)
	xhr:open("GET", real_url)
	
	--	xhr.timeout = TIMEOUT
	if assist_info.bShowLoading then
		assist_info.bShowLoading = false
		assist_info._tmrHttpWait = KE_SetAbsTimeout(TIMEWAIT, function()
			utils.BeginWaiting()
			assist_info.bShowLoading = true
			assist_info._tmrHttpTimeout = KE_SetAbsTimeout(TIMEOUT, function() 
				logger.net(string.format("http[GET]超时: %s", real_url))
	--			xhr:abort() 
				if assist_info.bShowLoading then utils.FinishWaiting() end
				assist_info.bShowLoading = false
	--			callback(true, nil, tArgs, assist_info)
			end)
		end)
	end
	
	local function onReadyStateChanged()
		if assist_info.bShowLoading then utils.FinishWaiting() end
		KE_KillTimer(assist_info._tmrHttpWait)  
		assist_info._tmrHttpWait = nil 
		KE_KillTimer(assist_info._tmrHttpTimeout)  
		assist_info._tmrHttpTimeout = nil 
		logger.net("+++++++++++++++++++++++++++++++++++++++++")
		logger.net(string.format("http[GET]响应: %s",real_url))
		logger.net(string.format("xhr.readyState=%d  xhr.status=%d", xhr.readyState, xhr.status))
--		logger.net(string.format("xhr.response = %s",xhr.response))
		logger.net("-----------------------------------------")
		if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
			callback(false, xhr.response, tArgs, assist_info)
		else
			logger.net("HTTP失败")
		--	utils.TellMe("网络不给力，请重试")
			callback(true, xhr.response, tArgs, assist_info)
		end
		xhr:unregisterScriptHandler()
	end
	xhr:registerScriptHandler(onReadyStateChanged)
	
	if assist_info.bShowLoading then utils.BeginWaiting() end
	xhr:send()
end

function HttpUtil:callXhrPost(assist_info, url, addr, params, respType, callback, tArgs)
	local strParam = params
	if type(strParam) == "table" then
		strParam = self:converTable2String(strParam)
	end
	strParam = strParam or ""
	url = url or SERVER_URL
	local real_url = url
	if addr and addr ~= "" then 
		real_url = real_url .. "/" .. addr
	else 
		real_url = real_url
	end
	logger.net("Http[POST]请求: " .. real_url)
	logger.net("请求参数：", strParam)
	
	local xhr = cc.XMLHttpRequest:new()
	xhr.responseType = respType
	self:autoHttpHead(xhr)
	xhr:open("POST", real_url)
	
--	xhr.timeout = TIMEOUT
	if assist_info.bShowLoading then
		assist_info.bShowLoading = false
		assist_info._tmrHttpWait = KE_SetAbsTimeout(TIMEWAIT, function()
			utils.BeginWaiting()
			assist_info.bShowLoading = true 
			assist_info._tmrHttpTimeout = KE_SetAbsTimeout(TIMEOUT, function() 
				logger.net(string.format("http[POST]超时: %s", real_url))
	--			xhr:abort() 
				if assist_info.bShowLoading then utils.FinishWaiting() end
				assist_info.bShowLoading = false
	--			callback(true, nil, tArgs, assist_info)
			end)
		end)
	end
	
	local function onReadyStateChanged()
		if assist_info.bShowLoading then utils.FinishWaiting() end
		KE_KillTimer(assist_info._tmrHttpWait)  
		assist_info._tmrHttpWait = nil 
		KE_KillTimer(assist_info._tmrHttpTimeout)  
		assist_info._tmrHttpTimeout = nil 
		logger.net("+++++++++++++++++++++++++++++++++++++++++")
		logger.net(string.format("http[POST]响应: %s", real_url))
		logger.net(string.format("xhr.readyState=%d  xhr.status=%d", xhr.readyState, xhr.status))
--		logger.net(string.format("xhr.response = %s",xhr.response))
		logger.net("-----------------------------------------")
		if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
			callback(false, xhr.response, tArgs, assist_info)
		else
			logger.net("HTTP失败")
--			utils.TellMe("网络不给力，请重试")
			callback(true, xhr.response, tArgs, assist_info)
		end
		xhr:unregisterScriptHandler()
	end
	xhr:registerScriptHandler(onReadyStateChanged)
	
	if assist_info.bShowLoading then utils.BeginWaiting() end
	xhr:send(strParam)
end

------------------------------------------------------------------------

local type_tbl = {
	["string"] = "string",
	["number"] = "number",
	["int"] = "number",
	["int8"] = "number",
	["int16"] = "number",
	["int32"] = "number",
	["int64"] = "number",
	["float"] = "number",
	["double"] = "number",
}
function HttpUtil:CheckParams(argrule, tParams)
	local strParam = ""
	if argrule then
		tParams = tParams or {}
		for _, arginfo in ipairs(argrule) do
			local argName = arginfo[1]
			local argType = arginfo[2]
			local bCanIgnore = arginfo[3]
			if bCanIgnore and tParams[argName]==nil then
				
			else
				assert(tParams[argName] ~= nil, string.format("参数[%s]不可为空",argName))
				assert(type(tParams[argName])==type_tbl[argType], string.format("%s类型应该为%s，当前为%s",argName,type_tbl[argType],type(tParams[argName])) )
				if strParam ~= "" then strParam = strParam .. "&" end
				strParam = strParam .. argName .. "=" .. tParams[argName]
			end
		end
	end
	return strParam
end
function HttpUtil:CheckTblParams(argrule, tParams)
	local tblParams = {}
	if argrule then
		tParams = tParams or {}
		for _, arginfo in ipairs(argrule) do
			local argName = arginfo[1]
			local argType = arginfo[2]
			local bCanIgnore = arginfo[3]
			if bCanIgnore and tParams[argName]==nil then
				
			else
				assert(tParams[argName] ~= nil, string.format("参数[%s]不可为空",argName))
				assert(type(tParams[argName])==type_tbl[argType], string.format("%s类型应该为%s，当前为%s",argName,type_tbl[argType],type(tParams[argName])) )
				tblParams[argName] = tParams[argName]
			end
		end
	end
	return tblParams
end
function HttpUtil:CheckUrlparam(argrule, tUrlParams)
	local strUrlparam = ""
	if argrule then
		tUrlParams = tUrlParams or {}
		for _, arginfo in ipairs(argrule) do
			local argName = arginfo[1]
			local argType = arginfo[2]
			local bCanIgnore = arginfo[3]
			if bCanIgnore and tUrlParams[argName]==nil then
				
			else
				assert(tUrlParams[argName] ~= nil, string.format("参数[%s]不可为空",argName))
				assert(type(tUrlParams[argName])==type_tbl[argType], string.format("%s类型应该为%s，当前为%s",argName,type_tbl[argType],type(tUrlParams[argName])) )
				strUrlparam = strUrlparam .. "/" .. tUrlParams[argName]
			end
		end
	end
	return strUrlparam
end

HttpUtil.CACHE_TYPE_FOREVER = 1  	--永久存储，只要缓存到，一直有效，往后不再网络获取
HttpUtil.CACHE_TYPE_TEMP = 2		--先从缓存读取，但是依然请求网络（此种情况会两次收到数据，第一次是缓存数据，第二次是网络数据）

local quiet_proto_tbl = {}
local user_cache_proto_tbl = {}
local public_cache_proto_tbl = {}
local user_tmp_proto_tbl = {}

function HttpUtil:AddUserCacheProto(ptoname, iType)
	user_cache_proto_tbl[ptoname] = iType
end

function HttpUtil:AddUserTmpProto(ptoname, iType)
	user_tmp_proto_tbl[ptoname] = iType
end

function HttpUtil:AddPublicCacheProto(ptoname, iType)
	public_cache_proto_tbl[ptoname] = iType
end

function HttpUtil:AddQuietProto(ptoname)
	quiet_proto_tbl[ptoname] = true
end

HttpUtil._noprints = {
	req_goucai_game_qiuhao_peilv_list = true,
	req_goucai_game_wanfa_list = true,
}

if device.platform == "android" then
	function HttpUtil:Request(ptoname, tParams, tUrlParams, unsafeCallback)
		KE_CheckNetConnect()
		
		local ptoInfo = g_AllProtocal[ptoname]
		assert(ptoInfo, "未定义该协议："..ptoname)
		assert(tParams==nil or type(tParams)=="table")
		assert(tUrlParams==nil or type(tUrlParams)=="table")
		assert(unsafeCallback==nil or type(unsafeCallback)=="function")
		logger.net("发送协议：", ptoname)
		
		local assist_info = { bShowLoading = not self._bQuiet }
		if quiet_proto_tbl[ptoname] then assist_info.bShowLoading = false end
		self._bQuiet = false
		
		--检查参数
		local strParam = self:CheckParams(ptoInfo.params, tParams)
		local strUrlparam = self:CheckUrlparam(ptoInfo.urlparams, tUrlParams)
		
		--
		local addrStr = ptoInfo.addr 
		if strUrlparam and strUrlparam ~= "" then
			addrStr = addrStr .. strUrlparam
		end
		local unsafe_callback = unsafeCallback
		if tParams and tUrlParams then tParams._tUrlParams = tUrlParams end
		
		if user_cache_proto_tbl[ptoname] then
			local sKey = self:GetPtoUrlKey(true, ptoname, tParams, tUrlParams)
			local filepath = UserDbCache.GetInstance():GetUserFilepath(sKey)
			if filepath then
				assist_info.userCacheKey = sKey
--				local begin = os.clock()
				local cacheCata = UserDbCache.GetInstance():GetUserData(sKey)
				if cacheCata then
					assist_info.jump_save = true
					self:OnRespData(ptoname, false, cacheCata, unsafe_callback, tParams, assist_info)
					assist_info.jump_save = false
--					print("====从缓存文件读取", os.clock()-begin, ptoname)
					if user_cache_proto_tbl[ptoname] == HttpUtil.CACHE_TYPE_FOREVER then return end
			--	elseif ptoname == "req_goucai_game_qiuhao_peilv_list" then
			--		if setting.GetPeilvCfg(sKey) then
			--			print("====从配置表读取", sKey)
			--			assist_info._isallready_decoded = true
			--			assist_info.jump_save = true
			--			self:OnRespData(ptoname, false, setting.GetPeilvCfg(sKey), unsafe_callback, tParams, assist_info)
			--			assist_info._isallready_decoded = false
			--			assist_info.jump_save = false
			--		end
				end
			end
		elseif user_tmp_proto_tbl[ptoname] then
			local sKey = self:GetPtoUrlKey(true, ptoname, tParams, tUrlParams)
			local filepath = UserDbCache.GetInstance():GetUserFilepath(sKey)
			if filepath then
				assist_info.userTmpKey = sKey
--				local begin = os.clock()
				local cacheCata = UserDbCache.GetInstance():GetUserTmpData(sKey)
				if cacheCata then
					assist_info.jump_save = true
					self:OnRespData(ptoname, false, cacheCata, unsafe_callback, tParams, assist_info)
					assist_info.jump_save = true
--					print("====从缓存文件读取", os.clock()-begin, ptoname)
					if user_tmp_proto_tbl[ptoname] == HttpUtil.CACHE_TYPE_FOREVER then return end
				end
			end
		elseif public_cache_proto_tbl[ptoname] then
			local sKey = self:GetPtoUrlKey(true, ptoname, tParams, tUrlParams)
			local filepath = UserDbCache.GetInstance():GetPublicFilepath(sKey)
			if filepath then
				assist_info.publicCacheKey = sKey
--				local begin = os.clock()
				local cacheCata = UserDbCache.GetInstance():GetPublicData(sKey)
				if cacheCata then
					assist_info.jump_save = true
					self:OnRespData(ptoname, false, cacheCata, unsafe_callback, tParams, assist_info)
					assist_info.jump_save = false
--					print("====从缓存文件读取", os.clock()-begin, ptoname)
					if public_cache_proto_tbl[ptoname] == HttpUtil.CACHE_TYPE_FOREVER then return end
				end
			end
		end
		
		local thePayUrl = HttpUtil.g_pay_url 
		if thePayUrl and thePayUrl == "" then thePayUrl = nil end
		if ptoname ~= "req_pay_commit" then thePayUrl = nil end
		
		if ptoInfo.reqType == "POST" then
			if HttpUtil._useOkHttp then
				HttpUtil:callOkHttpPost(assist_info, thePayUrl or ptoInfo.domain, addrStr, strParam, cc[ptoInfo.respType], function(bError, resp_data, tArgs, assist_info)
					self:OnRespData(ptoname, bError, resp_data, unsafe_callback, tArgs, assist_info)
				end, tParams)
			else
				HttpUtil:callXhrPost(assist_info, thePayUrl or ptoInfo.domain, addrStr, strParam, cc[ptoInfo.respType], function(bError, resp_data, tArgs, assist_info)
					self:OnRespData(ptoname, bError, resp_data, unsafe_callback, tArgs, assist_info)
				end, tParams)
			end
		elseif ptoInfo.reqType == "GET" then 
			if HttpUtil._useOkHttp then
				HttpUtil:callOkHttpGet(assist_info, thePayUrl or ptoInfo.domain, addrStr, strParam, cc[ptoInfo.respType], function(bError, resp_data, tArgs, assist_info)
					self:OnRespData(ptoname, bError, resp_data, unsafe_callback, tArgs, assist_info)
				end, tParams)
			else
				HttpUtil:callXhrGet(assist_info, thePayUrl or ptoInfo.domain, addrStr, strParam, cc[ptoInfo.respType], function(bError, resp_data, tArgs, assist_info)
					self:OnRespData(ptoname, bError, resp_data, unsafe_callback, tArgs, assist_info)
				end, tParams)
			end
		elseif ptoInfo.reqType == "XHRGET" then
			HttpUtil:callXhrGet(assist_info, thePayUrl or ptoInfo.domain, addrStr, strParam, cc[ptoInfo.respType], function(bError, resp_data, tArgs, assist_info)
				self:OnRespData(ptoname, bError, resp_data, unsafe_callback, tArgs, assist_info)
			end, tParams)
		else
			assert(false, "错误的reqType")
		end
	end
else
	function HttpUtil:Request(ptoname, tParams, tUrlParams, unsafeCallback)
		KE_CheckNetConnect()
		
		local ptoInfo = g_AllProtocal[ptoname]
		assert(ptoInfo, "未定义该协议："..ptoname)
		assert(tParams==nil or type(tParams)=="table")
		assert(tUrlParams==nil or type(tUrlParams)=="table")
		assert(unsafeCallback==nil or type(unsafeCallback)=="function")
		logger.net("发送协议：", ptoname)
		
		local assist_info = { bShowLoading = not self._bQuiet }
		if quiet_proto_tbl[ptoname] then assist_info.bShowLoading = false end
		self._bQuiet = false
		
		--检查参数
		local strParam = self:CheckParams(ptoInfo.params, tParams)
		local tblParams = self:CheckTblParams(ptoInfo.params, tParams)
		local strUrlparam = self:CheckUrlparam(ptoInfo.urlparams, tUrlParams)
		
		--
		local addrStr = ptoInfo.addr 
		if strUrlparam and strUrlparam ~= "" then
			addrStr = addrStr .. strUrlparam
		end
		local unsafe_callback = unsafeCallback
		if tParams and tUrlParams then tParams._tUrlParams = tUrlParams end
		
		if user_cache_proto_tbl[ptoname] then
			local sKey = self:GetPtoUrlKey(true, ptoname, tParams, tUrlParams)
			local filepath = UserDbCache.GetInstance():GetUserFilepath(sKey)
			if filepath then
				assist_info.userCacheKey = sKey
--				local begin = os.clock()
				local cacheCata = UserDbCache.GetInstance():GetUserData(sKey)
				if cacheCata then
					assist_info.jump_save = true
					self:OnRespData(ptoname, false, cacheCata, unsafe_callback, tParams, assist_info)
					assist_info.jump_save = false
--					print("====从缓存文件读取", os.clock()-begin, ptoname)
					if user_cache_proto_tbl[ptoname] == HttpUtil.CACHE_TYPE_FOREVER then return end
			--	elseif ptoname == "req_goucai_game_qiuhao_peilv_list" then
			--		if setting.GetPeilvCfg(sKey) then
			--			print("====从配置表读取", sKey)
			--			assist_info._isallready_decoded = true
			--			assist_info.jump_save = true
			--			self:OnRespData(ptoname, false, setting.GetPeilvCfg(sKey), unsafe_callback, tParams, assist_info)
			--			assist_info._isallready_decoded = false
			--			assist_info.jump_save = false
			--		end
				end
			end
		elseif user_tmp_proto_tbl[ptoname] then
			local sKey = self:GetPtoUrlKey(true, ptoname, tParams, tUrlParams)
			local filepath = UserDbCache.GetInstance():GetUserFilepath(sKey)
			if filepath then
				assist_info.userTmpKey = sKey
--				local begin = os.clock()
				local cacheCata = UserDbCache.GetInstance():GetUserTmpData(sKey)
				if cacheCata then
					assist_info.jump_save = true
					self:OnRespData(ptoname, false, cacheCata, unsafe_callback, tParams, assist_info)
					assist_info.jump_save = true
--					print("====从缓存文件读取", os.clock()-begin, ptoname)
					if user_tmp_proto_tbl[ptoname] == HttpUtil.CACHE_TYPE_FOREVER then return end
				end
			end
		elseif public_cache_proto_tbl[ptoname] then
			local sKey = self:GetPtoUrlKey(true, ptoname, tParams, tUrlParams)
			local filepath = UserDbCache.GetInstance():GetPublicFilepath(sKey)
			if filepath then
				assist_info.publicCacheKey = sKey
--				local begin = os.clock()
				local cacheCata = UserDbCache.GetInstance():GetPublicData(sKey)
				if cacheCata then
					assist_info.jump_save = true
					self:OnRespData(ptoname, false, cacheCata, unsafe_callback, tParams, assist_info)
					assist_info.jump_save = false
--					print("====从缓存文件读取", os.clock()-begin, ptoname)
					if public_cache_proto_tbl[ptoname] == HttpUtil.CACHE_TYPE_FOREVER then return end
				end
			end
		end
		
		local thePayUrl = HttpUtil.g_pay_url 
		if thePayUrl and thePayUrl == "" then thePayUrl = nil end
		if ptoname ~= "req_pay_commit" then thePayUrl = nil end
		
		if ptoInfo.reqType == "POST" then
			HttpUtil:callXhrPost(assist_info, thePayUrl or ptoInfo.domain, addrStr, tblParams, cc[ptoInfo.respType], function(bError, resp_data, tArgs, assist_info)
				self:OnRespData(ptoname, bError, resp_data, unsafe_callback, tArgs, assist_info)
			end, tParams)
		elseif ptoInfo.reqType == "GET" then 
			HttpUtil:callXhrGet(assist_info, thePayUrl or ptoInfo.domain, addrStr, strParam, cc[ptoInfo.respType], function(bError, resp_data, tArgs, assist_info)
				self:OnRespData(ptoname, bError, resp_data, unsafe_callback, tArgs, assist_info)
			end, tParams)
		elseif ptoInfo.reqType == "XHRGET" then
			HttpUtil:callXhrGet(assist_info, thePayUrl or ptoInfo.domain, addrStr, strParam, cc[ptoInfo.respType], function(bError, resp_data, tArgs, assist_info)
				self:OnRespData(ptoname, bError, resp_data, unsafe_callback, tArgs, assist_info)
			end, tParams)
		else
			assert(false, "错误的reqType")
		end
	end
end

--local ttttt = {}
function HttpUtil:OnRespData(ptoname, bError, resp_data, unsafe_callback, tArgs, assist_info)
	if bError then
		local errname = g_AllErrorFuncName[ptoname]
		local errFunc = proto[errname]
		logger.net("响应协议：", errname)
		logger.dump(resp_data)
		if errFunc then errFunc(resp_data, tArgs) end 
		if unsafe_callback then unsafe_callback(resp_data, tArgs) end
		g_EventMgr:FireEvent(errname, resp_data, tArgs)
		KE_CheckNetConnect()
		return
	end
	
	local resp_pto = g_AllRespFuncName[ptoname]
	local resp_func = proto[resp_pto]
	
	local recvdata
	if assist_info._isallready_decoded then
		recvdata = resp_data
		assist_info.jump_save = true
	else
		recvdata = resp_data and json.decode(resp_data)
	end
	
	if recvdata then
		if proto.is_success(recvdata) then 
			logger.net("响应协议：", resp_pto, assist_info.jump_save)
			if not assist_info.jump_save and not self._noprints[ptoname] then
				logger.dump(recvdata)
			end
			
			if assist_info.userCacheKey then
				if not assist_info.jump_save then
					UserDbCache.GetInstance():SaveUserData(assist_info.userCacheKey, resp_data)
				else
					print("跳过保存", ptoname)
				end
				
			--	if ptoname == "req_goucai_game_qiuhao_peilv_list" and device.platform == "windows" then
			--		table.save(recvdata, "src/app/configs/peilv/"..assist_info.userCacheKey..".lua")
			--		ttttt[assist_info.userCacheKey] = "app.configs.peilv."..assist_info.userCacheKey
			--		table.save(ttttt, "src/app/configs/xls/T_peilv_files.lua")
			--	end
				
			elseif assist_info.userTmpKey then
				UserDbCache.GetInstance():SaveUserTmpData(assist_info.userTmpKey, resp_data)
				
			elseif assist_info.publicCacheKey then
				if not assist_info.jump_save then
					UserDbCache.GetInstance():SavePublicData(assist_info.publicCacheKey, resp_data)
				else
					print("跳过保存", ptoname)
				end
				
			end
			
			if resp_func then resp_func(recvdata, tArgs) end 
			if unsafe_callback then unsafe_callback(recvdata, tArgs) end
			g_EventMgr:FireEvent(resp_pto, recvdata, tArgs)
		else
			logger.net("响应协议：", g_AllFailFuncName[ptoname])
			logger.dump(recvdata)  --数据太乱了 自己显示
			proto.on_fail(recvdata)
			proto.deal_spec_fail_code(recvdata)
			local fail_func = proto[ g_AllFailFuncName[ptoname] ]
			if fail_func then fail_func(recvdata, tArgs) end
			if unsafe_callback then unsafe_callback(recvdata, tArgs) end
			g_EventMgr:FireEvent(g_AllFailFuncName[ptoname], recvdata, tArgs)
		end
	else 
		logger.net("响应协议：", resp_pto)
		logger.dump(resp_data)
		if resp_func then resp_func(resp_data, tArgs) end 
		if unsafe_callback then unsafe_callback(resp_data, tArgs) end
		g_EventMgr:FireEvent(resp_pto, resp_data, tArgs)
	end
end

function HttpUtil:GetPtoUrl(ptoname, tParams, tUrlParams)
	local ptoInfo = g_AllProtocal[ptoname]
	assert(ptoInfo, "未定义该协议："..ptoname)
	assert(tParams==nil or type(tParams)=="table")
	assert(tUrlParams==nil or type(tUrlParams)=="table")
	
	--检查参数
	local strParam = self:CheckParams(ptoInfo.params, tParams)
	local strUrlparam = self:CheckUrlparam(ptoInfo.urlparams, tUrlParams)
	
	--
	local addrStr = ptoInfo.addr 
	if strUrlparam and strUrlparam ~= "" then
		addrStr = addrStr .. strUrlparam
	end
	
	local url = ptoInfo.domain or SERVER_URL
	local real_url = url
	if addrStr and addrStr ~= "" then 
		real_url = real_url .. "/" .. addrStr
	end
	if strParam and strParam ~= "" then 
		real_url = real_url .. "?" .. strParam
	end 
	print("======", real_url)
	return real_url
end

function HttpUtil:GetPtoUrlKey(bMd5, ptoname, tParams, tUrlParams)
	local ptoInfo = g_AllProtocal[ptoname]
	assert(ptoInfo, "未定义该协议："..ptoname)
	assert(tParams==nil or type(tParams)=="table")
	assert(tUrlParams==nil or type(tUrlParams)=="table")
	
	--检查参数
	local strParam = self:CheckParams(ptoInfo.params, tParams)
	local strUrlparam = self:CheckUrlparam(ptoInfo.urlparams, tUrlParams)
	
	--
	local addrStr = ptoInfo.addr 
	if strUrlparam and strUrlparam ~= "" then
		addrStr = addrStr .. strUrlparam
	end
	
	local url = ptoInfo.domain or SERVER_URL
	local real_url = url
	if addrStr and addrStr ~= "" then 
		real_url = real_url .. "/" .. addrStr
	end
	if strParam and strParam ~= "" then 
		real_url = real_url .. "?" .. strParam
	end 
	real_url = real_url .. "_" .. HTTP_HEAD_VAL_1
	print("======", real_url)
	if bMd5 then real_url = crypto.md5(real_url) end
	
	return real_url
end
