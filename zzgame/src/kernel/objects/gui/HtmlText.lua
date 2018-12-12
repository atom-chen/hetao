--------------------------
-- html文本
--------------------------
require("kernel.objects.gui.html")

local crypto = require("kernel.framework.crypto")
local json = require("kernel.framework.json")

HtmlText = class("HtmlText", function() return ccui.RichText:create() end )

function HtmlText:ctor(params)
    self.callback = nil
    params = params or {}
    self._params = params
    self.defaultColor = params.color or cc.c3b(255, 255, 255)
    self.defaultSize = params.size or 24
    self.defaultFont = params.font or const.DEF_FONT_CFG_REF().fontFilePath or ""
    self:ignoreContentAdaptWithSize(params.ignoreContentAdaptWithSize or false)
    if params.width then
    	self:setContentSize(cc.size(params.width, params.height or 24))
    end
	self:setWrapMode(1)
end

function HtmlText:setReRenderCallback(callback)
    self.callback = callback
end

function HtmlText:setString(_content)
	_content = _content or ""
    _content = string.gsub(_content, "\n", "")
    self:removeAllElement()
	local tbHtml = html.parsestr(_content)
    self:parseTag(tbHtml)
    self:formatText()
end

function HtmlText:parseTag(tag, _attr)
	local isTable = type(tag) == "table"
	if isTable then
		local curTag = tag["_tag"]
		if curTag == "#document" then
			for i = 1, #tag do
				self:parseTag(tag[i], tag["_attr"])
			end
		elseif curTag == "html" then
			for i = 1, #tag do
				self:parseTag(tag[i], tag["_attr"])
			end
		elseif curTag == "body" then
			for i = 1, #tag do
				self:parseTag(tag[i], tag["_attr"])
			end
		elseif curTag == "p" then
			local element = ccui.RichElementNewLine:create(1, self.defaultColor, 255)
			self:pushBackElement(element)
			for i = 1, #tag do
				self:parseTag(tag[i], tag["_attr"])
			end
		elseif curTag == "span" then
			local _attr = { }
			local style = tag["_attr"]["style"]
			local color = string.match(style, "color%s-:%s-rgb%(([%d]+,[%d]+,[%d]+)%)%s-")
			if color then
				color = string.split(color, ",")
				_attr.color = { }
				_attr.color.r = tonumber(color[1])
				_attr.color.g = tonumber(color[2])
				_attr.color.b = tonumber(color[3])
			end
			local size = string.match(style, "font%-size%s-:%s-(%d+)%s-px")
			if size then
				_attr.size = tonumber(size)
				if _attr.size then _attr.size = _attr.size * 2 end
			end
			for i = 1, #tag do
				self:parseTag(tag[i], _attr)
			end
		elseif curTag == "br" then
			local element = ccui.RichElementNewLine:create(1, self.defaultColor, 255)
			self:pushBackElement(element)
		elseif curTag == "img" then
			local _attr = tag["_attr"]
			local src = tag["_attr"]["src"]
			if src and src ~= "" then
				_attr.src = src
				self:addImageItem(_attr)
			end
		end
	elseif tag ~= "" then
		self:addTextItem(tag, _attr)
	end
end

function HtmlText:addTextItem(_text, _attr)
	print("=========", _text)
	if self._params._tmpnotext then return end
	local size = _attr.size or self.defaultSize
	local color = _attr.color or self.defaultColor
	local font = _attr.font or self.defaultFont
	local element = ccui.RichElementText:create(1, color, 255, _text or "", font, size)
	self:pushBackElement(element)
end

function HtmlText:addImageItem(_attr)
	print("=========", _attr.src)
	local src = _attr.src
	if not src or src == "" then return end
	local width = tonumber( _attr.width) or 0
	local height = tonumber(_attr.height) or 0

	if src then
		if string.sub(src, 1, 4) == "http" then
            local url = src
            local sprImg = cc.Sprite:create()
            local urlMd5 = crypto.md5(url)
            local cacheDir = GAME_CONFIG.LOCAL_DIR .. "/imgCache/"
            if not cc.FileUtils:getInstance():isDirectoryExist(cacheDir) then
                cc.FileUtils:getInstance():createDirectory(cacheDir)
            end
            if cc.FileUtils:getInstance():isFileExist(cacheDir .. urlMd5) then
                sprImg:setTexture(cacheDir .. urlMd5)
                if width > 0 and height > 0 then
                    sprImg:setContentSize(width, height)
                end
                if self._params.fixWidth then
                	local sz = sprImg:getContentSize()
                	sprImg:setContentSize(self._params.fixWidth, sz.height*self._params.fixWidth/sz.width)
                end
            else
                local xhr = cc.XMLHttpRequest:new()
                xhr.timeout = 10
                xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
                xhr:open("GET", url)
                local function onReadyStateChange()
                    if xhr.readyState == 4 then
                        if xhr.status ~= 200 then
                            print("HtmlText:addImageItem: load %s fail", url)
                        else
                            local s = xhr.response
                            
                            FileHelper.CheckDir(cacheDir, true)
                            local fullFileName = cacheDir .. urlMd5
                            local fHandle = io.open(fullFileName, "wb")
                            if fHandle then
                            	fHandle:write(s)
                            	fHandle:close()
                            end
                            
                            if cc.FileUtils:getInstance():isFileExist(fullFileName) and not tolua.isnull(self) and not tolua.isnull(sprImg) then
                                sprImg:setTexture(cacheDir .. urlMd5)
                                if width > 0 and height > 0 then
                                    sprImg:setContentSize(width, height)
                                end
                                if self._params.fixWidth then
				                	local sz = sprImg:getContentSize()
                					sprImg:setContentSize(self._params.fixWidth, sz.height*self._params.fixWidth/sz.width)
								end
								if self.formatRenderers then
									self:formatRenderers()
								else
									self:formatText()
								end
                                if self.callback then
                                    self.callback()
                                end
                            else
                                print("HtmlText:addImageItem: create file %s fail", cacheDir .. urlMd5)
                            end
                        end
                    else
                        print("HtmlText:addImageItem: load %s fail", url)
                    end
                end
                xhr:registerScriptHandler(onReadyStateChange)
                xhr:send()
            end
            if sprImg then
                if width > 0 and height > 0 then
                    sprImg:setContentSize(width, height)
                end
                if self._params.fixWidth then
                	local sz = sprImg:getContentSize()
                	sprImg:setContentSize(self._params.fixWidth, sz.height*self._params.fixWidth/sz.width)
                end
                local element = ccui.RichElementCustomNode:create(0, cc.c3b(255, 255, 255), 255, sprImg)
                self:pushBackElement(element)
            end
        else
          	local sprImg = utils.CreateSprite(src)
        	if sprImg then 
            	if width > 0 and height > 0 then
	                sprImg:setContentSize(width, height)
	            end
	            if self._params.fixWidth then
                	local sz = sprImg:getContentSize()
                	sprImg:setContentSize(self._params.fixWidth, sz.height*self._params.fixWidth/sz.width)
                end
            end 
            if sprImg then
                local element = ccui.RichElementCustomNode:create(0, cc.c3b(255, 255, 255), 255, sprImg)
                self:pushBackElement(element)
            end
        end
    end
end
