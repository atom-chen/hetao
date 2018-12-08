--[[

Copyright (c) 2011-2014 chukong-inc.com

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

]]

--[[--

网络服务

]]

extra_network = {}


--[[--

创建异步 HTTP 请求，并返回 cc.HTTPRequest 对象。 

~~~ lua

function onRequestFinished(event)
    local ok = (event.name == "completed")
    local request = event.request
 
    if not ok then
        -- 请求失败，显示错误代码和错误消息
        print(request:getErrorCode(), request:getErrorMessage())
        return
    end
 
    local code = request:getResponseStatusCode()
    if code ~= 200 then
        -- 请求结束，但没有返回 200 响应代码
        print(code)
        return
    end
 
    -- 请求成功，显示服务端返回的内容
    local response = request:getResponseString()
    print(response)
end
 
-- 创建一个请求，并以 POST 方式发送数据到服务端
local url = "http://www.mycompany.com/request.php"
local request = extra_network.createHTTPRequest(onRequestFinished, url, "POST")
request:addPOSTValue("KEY", "VALUE")
 
-- 开始请求。当请求完成时会调用 callback() 函数
request:start()

~~~

@return cc.HTTPRequest 结果

]]
function extra_network.createHTTPRequest(callback, url, method)
    if not method then method = "GET" end
    if string.upper(tostring(method)) == "GET" then
        method = cc.kCCHTTPRequestMethodGET
    else
        method = cc.kCCHTTPRequestMethodPOST
    end
    method = 1
    return cc.HTTPRequest:createWithUrl(callback, url, method)
end

--- Upload a file through a cc.HTTPRequest instance.
-- @author zrong(zengrong.net)
-- Creation: 2014-04-14
-- @param callback As same as the first parameter of extra_network.createHTTPRequest.
-- @param url As same as the second parameter of extra_network.createHTTPRequest.
-- @param datas Includes following values:
-- 		fileFiledName(The input label name that type is file);
-- 		filePath(A absolute path for a file)
-- 		contentType(Optional, the file's contentType, default is application/octet-stream)
-- 		extra(Optional, the key-value table that transmit to form)
-- for example:
--[[
	extra_network.uploadFile(function(evt)
			if evt.name == "completed" then
				local request = evt.request
				printf("REQUEST getResponseStatusCode() = %d", request:getResponseStatusCode())
				printf("REQUEST getResponseHeadersString() =\n%s", request:getResponseHeadersString())
	 			printf("REQUEST getResponseDataLength() = %d", request:getResponseDataLength())
                printf("REQUEST getResponseString() =\n%s", request:getResponseString())
			end
		end,
		"http://127.0.0.1/upload.php",
		{
			fileFieldName="filepath",
			filePath=device.writablePath.."screen.jpg",
			contentType="Image/jpeg",
			extra={
				{"act", "upload"},
				{"submit", "upload"},
			}
		}
	)
	]]
-- 		
function extra_network.uploadFile(callback, url, datas)
	logger.dump(datas)
	assert(datas or datas.fileFieldName or datas.filePath, "Need file datas!")
	local request = extra_network.createHTTPRequest(callback, url, "POST")
	request:addRequestHeader(HttpUtil:GetHttpHead())
	local fileFieldName = datas.fileFieldName
	local filePath = datas.filePath
	local contentType = datas.contentType
	if contentType then
		request:addFormFile(fileFieldName, filePath, contentType)
	else
		request:addFormFile(fileFieldName, filePath)
	end
	if datas.extra then
		for k,v in pairs(datas.extra) do
			request:addFormContents(v[1],v[2])
		end
	end
	request:start()
	return request
end

local function parseTrueFalse(t)
    t = string.lower(tostring(t))
    if t == "yes" or t == "true" then return true end
    return false
end

function extra_network.makeCookieString(cookie)
    local arr = {}
    for name, value in pairs(cookie) do
        if type(value) == "table" then
            value = tostring(value.value)
        else
            value = tostring(value)
        end

        arr[#arr + 1] = tostring(name) .. "=" .. string.urlencode(value)
    end

    return table.concat(arr, "; ")
end

function extra_network.parseCookie(cookieString)
    local cookie = {}
    local arr = string.split(cookieString, "\n")
    for _, item in ipairs(arr) do
        item = string.trim(item)
        if item ~= "" then
            local parts = string.split(item, "\t")
            -- ".amazon.com" represents the domain name of the Web server that created the cookie and will be able to read the cookie in the future
            -- TRUE indicates that all machines within the given domain can access the cookie
            -- "/" denotes the path within the domain for which the variable is valid
            -- "FALSE" indicates that the connection is not secure
            -- "2082787601" represents the expiration date in UNIX time (number of seconds since January 1, 1970 00:00:00 GMT)
            -- "ubid-main" is the name of the cookie
            -- "002-2904428-3375661" is the value of the cookie

            local c = {
                domain = parts[1],
                access = parseTrueFalse(parts[2]),
                path = parts[3],
                secure = parseTrueFalse(parts[4]),
                expire = checkint(parts[5]),
                name = parts[6],
                value = string.urldecode(parts[7]),
            }

            cookie[c.name] = c
        end
    end

    return cookie
end
