------------------------------------------
--富文本
------------------------------------------

-- 
function testRichText(parent,x,y)
	local rc = clsRichText.new(nil,330,200)
	rc:setString("#c(ffaa33dd)我是颜色为ffaa33dd的字符串#n我是白色字符串#o(1,uistu/common/icons/icon_diamond_1.png)#f(cocosui/text/heiti.TTF,18)我是字号为18的字符串")
	rc:setPosition(x or 0, y or 0)
	parent:addChild(rc)
	return rc
end 

local tonumber = tonumber
local string_gsub = string.gsub
local string_format = string.format
local string_sub = string.sub

--[[
text_part = {
	ctrl_code = "",
	ctrl_text = "",
	text = "",
}
]]--
local cmd_parse_text_part = {
	--颜色
    -- eg: #c(ffaa33dd)我是一条字符串
    -- eg: #G我是一条字符串
	["c"] = function(self, text_part)
		local ctrl_text = text_part.ctrl_text
		local r,g,b,a = math.Hex2ARGB(ctrl_text)
		self._CurFontColor = cc.c3b(r,g,b)
		self._CurFontAlpha = a
	end,
	--换行
    -- eg: #r()我是一条字符串
    -- eg: #r我是一条字符串
	["r"] = function(self, text_part)
		local re = ccui.RichElementNewLine:create(0, cc.c3b(255, 255, 255),255)
		self:PushElement(re)
	end,
	--下划线
	["u"] = function(self, text_part)
		
	end,
	--恢复为默认的字体和颜色
	-- eg: #c(ffaa33dd)我是一条字符串#n啊啊啊
	["n"] = function(self, text_part)
		self._CurFontName = self._FontName
		self._CurFontSize = self._FontSize
		self._CurFontColor = self._FontColor
		self._CurFontAlpha = self._FontAlpha
	end,
	--字体
	-- eg: #f(cocosui/text/heiti.TTF,24)
	["f"] = function(self, text_part)
		local ctrl_text = text_part.ctrl_text
		local info_list = string.split(ctrl_text,",")
		self._CurFontName = info_list[1]
		self._CurFontSize = tonumber(info_list[2])
	end,
	--点击事件
	["e"] = function(self, text_part)
		--尚未实现
		assert(false, "尚未实现")
	end,
	
	--字符串
	-- eg: 我是一条字符串
	[""] = function(self, text_part)
		local text = text_part.text
		if text then
			local re = ccui.RichElementText:create(0, self._CurFontColor, self._CurFontAlpha, text, self._CurFontName, self._CurFontSize)
			self:PushElement(re)
		end
	end,
	--图片
    -- eg: #o(0.6,res/chip/chip_1.png)
	["o"] = function(self, text_part)
		local ctrl_text = text_part.ctrl_text
        local info_list = string.split(ctrl_text,",")
        local scale = tonumber(info_list[1])
        local respath = info_list[2]
		assert(scale and respath, "解析失败: "..ctrl_text)
	--	local re = ccui.RichElementImage:create(0, cc.c3b(255, 255, 255), 255, respath)
        local sprImg = utils.CreateSprite(respath)
        if scale ~= 1 then 
            local sz = sprImg:getContentSize()
            sprImg:setScale(scale) 
            sprImg:setContentSize(sz.width*scale,sz.height*scale)
        end 
        local re = ccui.RichElementCustomNode:create(0, cc.c3b(255, 255, 255), 255, sprImg)
		self:PushElement(re)
	end,
	--Plist图片
	["frame"] = function(self, text_part)
		local ctrl_text = text_part.ctrl_text
        local info_list = string.split(ctrl_text,",")
        local scale = tonumber(info_list[1])
        local respath = info_list[2]
		assert(scale and respath, "解析失败: "..ctrl_text)
	--	local re = ccui.RichElementImage:create(0, cc.c3b(255, 255, 255), 255, respath)
        local sprImg = utils.CreateSpriteWithSpriteFrameName(respath)
        if scale ~= 1 then 
            local sz = sprImg:getContentSize()
            sprImg:setScale(scale) 
            sprImg:setContentSize(sz.width*scale,sz.height*scale)
        end 
        local re = ccui.RichElementCustomNode:create(0, cc.c3b(255, 255, 255), 255, sprImg)
		self:PushElement(re)
	end,
	--序列帧动画
    -- eg: #a(0.5,res/cocosui/AllEmoj.plist,emoj/xiao,0.2)
    ["a"] = function(self, text_part)
        local ctrl_text = text_part.ctrl_text
        local info_list = string.split(ctrl_text,",")
        local scale = tonumber(info_list[1])
        local plistPath = info_list[2]
        local aniName = info_list[3]
        local interval = info_list[4] or const.EMOJ_INTERVAL
		
        local emojId = tonumber(aniName)
		if emojId and const.MSG_ID[emojId] then
			aniName = const.MSG_ID[emojId]
		end
		assert(scale and plistPath and aniName, "解析失败: "..ctrl_text)
        local spr = utils.CreateSprite()
        AnimationHelper.playAnimation2(spr, plistPath, aniName, interval)
        if scale ~= 1 then 
            local sz = spr:getContentSize()
            spr:setScale(scale) 
            spr:setContentSize(sz.width*scale,sz.height*scale)
        end 
        local re = ccui.RichElementCustomNode:create(0, cc.c3b(255, 255, 255), 255, spr)
		self:PushElement(re)
    end,
}


clsRichText = class("clsRichText", function() return ccui.RichText:create() end)

function clsRichText:ctor(strCont, MaxWidth, MaxHeight, FontName, FontSize, FontColor, FontAlpha)
	assert(MaxWidth and MaxHeight)
	self:ignoreContentAdaptWithSize(false)
	self:setContentSize(cc.size(MaxWidth, MaxHeight))
	self:setWrapMode(1)
	
	self._FontName = FontName or const.DEF_FONT_CFG_REF().fontFilePath or ""
	self._FontSize = FontSize or 24
	self._FontColor = FontColor or cc.c3b(255, 255, 255)
	self._FontAlpha = FontAlpha or 255
	
	self._CurFontName = self._FontName
	self._CurFontSize = self._FontSize
	self._CurFontColor = self._FontColor
	self._CurFontAlpha = self._FontAlpha
	
	self._sText = ""
	self._AllElements = {}
	
	if strCont and strCont ~= "" then 
		self:setString(strCont)
	end 
end

function clsRichText:dtor()
	self:ClearElements()
end

function clsRichText:PushElement(element)
	table.insert(self._AllElements, element)
	self:pushBackElement(element)
end

function clsRichText:InsertElement(element, idx)
	table.insert(self._AllElements, idx, element)
	self:insertElement(element, idx)
end

function clsRichText:RemoveElement(idx)
	table.remove(self._AllElements, idx)
	self:removeElement(idx)
end

function clsRichText:ClearElements()
	local cnt = #self._AllElements
	for i=cnt,1,-1 do
		self:removeElement(self._AllElements[i])
	end
	self._AllElements = {}
end

function clsRichText:SetFontInfo(fontName, fontSize, fontColor, fontAlpha)
	self._FontName = fontName or self._FontName
	self._FontSize = fontSize or self._FontSize
	self._FontColor = fontColor or self._FontColor
	self._FontAlpha = fontAlpha or self._FontAlpha
end

-- #n #cFFAA88EE, #fHelvetica, #d32, #pres/icons/money.png, #xCustomNode
function clsRichText:setString(sTxt)
	sTxt = sTxt or ""
	if self._sText == sTxt then return end
	self._sText = sTxt
	self:ClearText()
	self:AddText(sTxt)
end

function clsRichText:ClearText()
	self._sText = ""
	self:ClearElements()
end

function clsRichText:AddText(txt)
	if txt == nil or txt == "" then return end
	self._sText = string.format("%s%s", self._sText,txt)

	local text_parts = self:_create_text_parts(txt) 
--	Log.dump(text_parts)
	
	for _, text_part in ipairs(text_parts) do
		local ctrl_code = text_part.ctrl_code
		local parse_func = cmd_parse_text_part[ctrl_code]
		parse_func(self, text_part)
	end
end


-----------------------------------------------------------------------------
-- 解析传入的text，根据控制字符，把文本按功能段类型拆分开来
-- 通用格式为：#x(xxxx)
-- 控制字符的基础功能现有一下这些：
-- 1、#c(ffffffff)							（表示设置文字颜色为0xffffffff）
-- 2、#r()									（换行）
-- 3、#o(obj_id)							（用来在文本中显示图片，obj_id表示图片信息，利用此信息来创建图片）
-- 4、#e(click_id)点击这里#e()				（可点击字符串，click_id为程序使用）
-- 5、#u()									（下划线）
-- 6、#n()									（恢复为默认的字体和颜色）
-- 7、#f(name,size,bold)					（设置字体）

-- 高级控制字符：（做法是先转换为上述的基础功能格式，再进行功能实现）
-- 1、#R/#G/#B/#Y/#W
-- 2、#r/#u/#n
-----------------------------------------------------------------------------

local color_map = {
	["R"] = "ffff0000",
	["G"] = "ff00ff00",
	["B"] = "ff0000ff",
	["Y"] = "ffffff00",
	["P"] = "ffff00ff",
	["W"] = "ffffffff",
	["O"] = "ffdb7549",
}
local color_mode = "#[RGBYPWO]"		-- #R #G #B #Y #P #W #O
local base_codes = "nru"			-- #n #r #u
-- 转换一些高级的控制字符串为基础控制字符串格式
function clsRichText:_transfer_ctrl_code(text)
	-- #R #G #B #Y #P #W #O
	text = string_gsub(text, color_mode, function(color_code)
		return string_format("#c(%s)", color_map[string_sub(color_code, 2, -1)])
	end)
	
	-- #n #r #u #t
	local base_mode1 = "#(["..base_codes.."])"
	local base_mode2 = "#(["..base_codes.."])%(%)"
	text = string_gsub(text, base_mode2, function(base_code)
		return string_format("#%s", base_code)
	end)
	text = string_gsub(text, base_mode1, function(base_code)
		return string_format("#%s()", base_code)
	end)
	
	return text
end

--
function clsRichText:_create_text_parts(text)
    text = self:_transfer_ctrl_code(text)

    local text_parts = {}

    local info = string.split(text, "#")
    for i, str in ipairs(info) do 
        -- (%a+)%((.-)%)([^#]*)的解释：
	    -- (%a+)：ctrl_code为所有字母(1~多个)
	    -- %((.-)%)：ctrl_text为被()包起来的任意字符集合(0~多个)
	    -- ([^#]*)：text为最长的不包含#号的任意字符集合(0~多个)
        local ctrl_code, ctrl_text, text = string.match(str, "(%a+)%((.-)%)([^#]*)")
        
        if ctrl_code and ctrl_text and cmd_parse_text_part[ctrl_code] then 
            -- 先将控制字符当做单独的text_part加入
            text_parts[#text_parts+1] = {
				ctrl_code = ctrl_code,
				ctrl_text = ctrl_text,
				text = "",
			}
            -- 再将需要显示的字符串当做text_part加入
            if text ~= "" then
			    text_parts[#text_parts+1] = {
				    ctrl_code = "",
				    ctrl_text = "",
				    text = text,
			    }
		    end
        else 
            -- 直接将需要显示的字符串当做text_part加入
            if i == 1 then 
                text_parts[#text_parts+1] = {
				    ctrl_code = "",
				    ctrl_text = "",
				    text = str,
			    }
            else
			    text_parts[#text_parts+1] = {
				    ctrl_code = "",
				    ctrl_text = "",
				    text = "#"..str,
			    }
		    end
        end 
    end 

	return text_parts
end 

