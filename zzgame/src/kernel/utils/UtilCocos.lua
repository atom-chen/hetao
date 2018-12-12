-------------------------
-- 辅助库
-------------------------
module("utils", package.seeall)

local reason = {
	[-1] = "不支持的参数类型或返回值类型",
	[-2] = "无效的签名",
	[-3] = "没有找到指定的方法",
	[-4] = "Java方法执行时抛出了异常",
	[-5] = "Java虚拟机出错",
	[-6] = "Java虚拟机出错",
}
function callJavaFunc(className, methodName, args, sig)
	local ok, ret = luaj.callStaticMethod(className, methodName, args, sig)
	if not ok then
		local msg = string.format("[jlua] %s.%s  %s", className, methodName, reason[ret])
		utils.TellMe(msg, 10)
	end
	return ok, ret
end

function IsValidCCObject(obj)
	if not obj then return false end 
	if tolua.isnull(obj) then return false end
	return true
end

-- 迭代root上所有命名节点到tbl
function getNamedNodes(root, tbl)
	tbl = tbl or root
	local function getNode(parent)
		if (not parent) or(not parent.getChildren) then return end
		local children = parent:getChildren()
		for _, v in pairs(children) do
			if tbl[v:getName()] then logger.error( "检测到重复命名：", v:getName() ) end
			tbl[v:getName()] = v
			getNode(v)
		end
	end
	getNode(root)
end

function LoadCsb(filepath)
	return cc.CSLoader:createNode(filepath)
end

function Second2Frame(iSecond)
	return math.ceil(GAME_CONFIG.FPS * iSecond)
end

function Frame2Second(iTotalFrame)
	return iTotalFrame/GAME_CONFIG.FPS
end

-- 判断点击点是否落在指定对象上
function IsClickInTarget(target, touch)
	local location = touch
	if type(touch) == "userdata" then
		location = touch:getLocation()
	end
	local locationInNode = target:convertToNodeSpace(location)
	local s = target:getContentSize()
	local rect = cc.rect(0, 0, s.width, s.height)
	return cc.rectContainsPoint(rect, locationInNode)
end

function RegClickEvent(Btn, OnClick)
	assert(is_function(OnClick), "事件响应函数无效")
	local function touchEvent(sender, eventType)
		if eventType ~= ccui.TouchEventType.ended then return end 
		OnClick(sender)
	end
	Btn:addTouchEventListener(touchEvent)
end

function RegTouchEvent(Btn, Callback)
	assert(is_function(Callback), "事件响应函数无效")
	Btn:addTouchEventListener(Callback)
end

function IsNodeRealyVisible(Node)
	if not Node then return false end
	while Node do
		if not Node:isVisible() then 
			return false 
		end
		Node = Node:getParent()
	end
	return true
end

-- 将srcObj转换到dstObj的局部空间
function ConvertSpace(dstObj, srcObj, x, y)
	x = x or 0 
	y = y or 0
	local Point = srcObj:convertToWorldSpace(cc.p(x, y))
	local Pt = dstObj:convertToNodeSpace(Point)
	return Pt
end

-- 将srcObj转换到dstObj的局部空间
function ConvertSpaceAR(dstObj, srcObj, x, y)
	x = x or 0 
	y = y or 0
	local Point = srcObj:convertToWorldSpaceAR(cc.p(x, y))
	local Pt = dstObj:convertToNodeSpace(Point)
	return Pt
end

function SetGray(obj, bGray)
	if not obj then return end
	
	if obj.setGLProgramState and obj.getGrayGLProgramState and obj.getNormalGLProgramState then 
		if bGray then
			obj:setGLProgramState(obj:getGrayGLProgramState())
		else
			obj:setGLProgramState(obj:getNormalGLProgramState())
		end
	end
	
	local child_list = obj:getChildren() or {}
	for _, ChildObj in pairs(child_list) do
		SetGray(ChildObj, bGray)
	end
end

function Clip2Circle(img, diameter)
	img:setScaleX(diameter/img:getContentSize().width)
    img:setScaleY(diameter/img:getContentSize().height)
    local  circlePro = cc.GLProgram:create("shader/common.vert", "shader/circlStencile.frag")
    circlePro:bindAttribLocation(cc.ATTRIBUTE_NAME_POSITION, cc.VERTEX_ATTRIB_POSITION) 
    circlePro:bindAttribLocation(cc.ATTRIBUTE_NAME_TEX_COORD, cc.VERTEX_ATTRIB_TEX_COORD)
    circlePro:link()
    circlePro:updateUniforms()
    img:setGLProgram(circlePro) 
    local curGlProgState = img:getGLProgramState()
    curGlProgState:setUniformVec3("radiusInfo",{x=diameter/2, y=diameter/2, z=diameter/2})
end

-- TextField替换为editbox  
function ReplaceTextField(widget, bkgimg, sFontColor, sHolderColor)
	if widget == nil then
		return
	end
	if widget.getDescription == nil then
		return
	end
	if widget:getDescription() ~= "TextField" then
		return
	end
	if bkgimg == "" then
		bkgimg = RES_CONFIG.common_null
	end
	
	-- TextField的属性
	local pos = cc.p(widget:getPosition())
	local pAnchorPoint = widget:getAnchorPoint()
	local size = widget:getContentSize()
	local iZOrder = widget:getLocalZOrder()
	local parent = widget:getParent()
	local pName = widget:getName()
	local iTag = widget:getTag()
	local scaleX = widget:getScaleX()
	local scaleY = widget:getScaleY()
	local opacity = widget:getOpacity()
	local isVisible = widget:isVisible()
	local isTouchEnabled = widget:isTouchEnabled()
	local rotation = widget:getRotation()

	local sPlaceHolder = widget:getPlaceHolder()
	local sPlaceHolderFontName = widget:getFontName()
	local sPlaceholderFontSize = widget:getFontSize()
	local tPlaceholderFontColor = widget:getPlaceHolderColor()

	local sFontName = widget:getFontName()
	local iFontSize = widget:getFontSize()
	local tFontColor = widget:getTextColor()
	if sFontColor then
		if type(sFontColor) == "string" then
			tFontColor = cc.c4b(math.Hex2ARGB(sFontColor))
		end
	end

	local bIsPassWord = widget:isPasswordEnabled()
	
	local isMaxLengthEnabled = widget:isMaxLengthEnabled()
	local iMaxLength = widget:getMaxLength()
	
--	logger.normal("替换编辑框", sPlaceHolder, sPlaceHolderFontName, sPlaceholderFontSize, tPlaceholderFontColor, sFontName, iFontSize)
--	print(table.to_string(tPlaceholderFontColor))


	-- 创建并设置属性
	local editBox = ccui.EditBox:create(size, bkgimg or "uistu/common/editor_bg.png")
	editBox:setAnchorPoint(pAnchorPoint)
	editBox:setPosition(pos)
	editBox:setLocalZOrder(iZOrder)
	editBox:setName(pName)
	editBox:setTag(iTag)
	editBox:setScaleX(scaleX)
	editBox:setScaleY(scaleY)
	editBox:setOpacity(opacity)
	editBox:setVisible(isVisible)
	editBox:setTouchEnabled(isTouchEnabled)
	editBox:setRotation(rotation)
	
	editBox:setFontName(sFontName)
	editBox:setFontSize(iFontSize)
	if sFontColor and tFontColor then editBox:setFontColor(tFontColor) end

	editBox:setPlaceholderFontName(sPlaceHolderFontName)
	editBox:setPlaceholderFontSize(sPlaceholderFontSize)
	editBox:setPlaceholderFontColor(cc.c3b(245,245,245))
	editBox:setPlaceHolder(sPlaceHolder)

	editBox:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
	if bIsPassWord then
		editBox:setInputFlag(cc.EDITBOX_INPUT_FLAG_PASSWORD)
	else
		editBox:setInputFlag(cc.EDITBOX_INPUT_FLAG_INITIAL_CAPS_WORD)
	end

	if iMaxLength > 0 then
		editBox:setMaxLength(iMaxLength)
	end
	editBox:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
--	editBox:setHACenter()

	local parent = widget:getParent()
	widget:removeFromParent()
	if parent ~= nil then
		parent:addChild(editBox)
	end
	
	if device.platform ~= "ios" then
		local Point = editBox:convertToWorldSpace(cc.p(0,0))
		editBox._worldY = Point.y
		editBox:registerScriptEditBoxHandler()
	end

	return editBox
end 

-- 摇一摇事件
function AddShakeEvent(LayerShake, OnShakeBegin, OnShakeEnd, OnShaking)
	--[[
	LayerShake = LayerShake or cc.Layer:create()
	if not LayerShake.registerScriptAccelerateHandler or not LayerShake.setAccelerometerEnabled then
		return nil
	end
	LayerShake._bShaking = false
	local math_abs = math.abs 
	local vvv = 0.1
	local function didAccelerate(x,y,z,timestamp)
		local oldFlag = LayerShake._bShaking
		if math_abs(x) > vvv or math_abs(y) > vvv or math_abs(z) > vvv then
			LayerShake._bShaking = true 
		else 
			LayerShake._bShaking = false 
    	end 
    	
    	if LayerShake._bShaking ~= oldFlag then
    		if LayerShake._bShaking then
    			if OnShakeBegin then OnShakeBegin() end
    		else 
    			if OnShakeEnd then OnShakeEnd() end
    		end 
    	elseif LayerShake._bShaking then
    		if OnShaking then OnShaking() end
    	end 
    end
    LayerShake:registerScriptAccelerateHandler(didAccelerate)
    LayerShake:setAccelerometerEnabled(true)
    
    return LayerShake
    ]]
end
 
function GetBoundSize(lbl)
	local sz = lbl:getContentSize()
	local scale = lbl:getScale()
	return cc.size(sz.width*scale, sz.height*scale)
end
