-------------------------
-- 网格
-- 用法说明
--[[

	local scrollView = ccui.ScrollView:create()
	scrollView:setDirection(ccui.ScrollViewDir.both)
	scrollView:setBounceEnabled(true)
	scrollView:setContentSize({ width = 720, height = 400 })
	scrollView:setPosition(0,0)
	self:addChild(scrollView, 2)
	scrollView:setBackGroundColorType(1)
	scrollView:setBackGroundColor({ r = 222, g = 222, b = 222 })
	
	local innerInterface = clsContainerInterface.new(scrollView)
	
	local createFunc = function(data) 
		local cell = utils.CreateButton(RES_CONFIG.common_mask_red,RES_CONFIG.common_mask_red,"")
		cell:setScale9Enabled(true)
		-- todo: 根据data创建cell的属性，比如子控件，按钮标题等
		cell:setTitleText(data)
		
		return cell
	end
	
	local innerWid = 100 * 30
	local innerHei = 64 * 520
	scrollView:setInnerContainerSize(cc.size(innerWid,innerHei))
	
	local idx = 0
	for r=1, 520 do
		for c=1, 30 do
			idx = idx + 1
			local data = idx  -- data可是任意类型
			local bound = { x=(c-0.5)*100, y=innerHei-(r-0.5)*64, w=96, h=62 }  --如果锚点不是(0.5,0.5)需要设置 bound.anchorX和bound.anchorY  如果scale不是1，需要设置bound.scale 
			innerInterface:AddObjectDelay(nil, bound, createFunc, nil, data)
		end
	end
	
	innerInterface:CheckSeeable()

]]--
-------------------------
clsContainerInterface = class("clsContainerInterface")

function clsContainerInterface:ctor(scrollView, posListener)
	self._allObjsPos = {} --每个子项的行列值，二元数组
	self._allObjs = {}
	self._objsById = {}
	self.itemSize = {}--子项的尺寸
	if scrollView then
		self:BindToScrollView(scrollView, posListener)
	end
end

function clsContainerInterface:dtor()
	self._destoryed = true
	self:Clear()
end
function clsContainerInterface:setItemSize(width,height)
	self.itemH = height
	self.itemW = width
end
function clsContainerInterface:BindToScrollView(scrollView, posListener)
	assert(not self._innerContainer, "不可重复绑定")
	self._innerContainer = scrollView:getInnerContainer()
	local sz = scrollView:getContentSize()
	self.parentW = sz.width
	self.parentH = sz.height
	
	self:SetPosition(self._innerContainer:getPosition())
	
	if posListener then
		self._posListener = posListener
		scrollView:addEventListener(function(sender, evenType)
			if evenType == 9 and not self._destoryed then  -- InerContainer位置发生了变化
				local x, y = self._innerContainer:getPosition()				
				self:SetPosition(x, y)
				self._posListener(x, y)
			end
		end)
	else
		scrollView:addEventListener(function(sender, evenType)
			if evenType == 9 then  -- InerContainer位置发生了变化
				self:SetPosition(self._innerContainer:getPosition())
			end
		end)
	end
end

function clsContainerInterface:SetDefaultCreateFunc(createFunc)
	self._defaultCreateFunc = createFunc
end

--[[
local bound = {
	x = ,	--必须
	y = ,	--必须
	w = ,	--必须
	h = ,	--必须
	anchorX = nil,		--可选，默认0.5
	anchorY = nil,		--可选，默认0.5
	scale = nil,		--可选，默认1
}
]]
-- 该接口不会立即创建元素，而是延迟到该元素可见时才创建，所以bound的属性必须设置完整,,clTable行列值
function clsContainerInterface:AddObjectDelay(Id, bound, createFunc, refreshFunc, data,clTable)
	assert(bound)
	createFunc = createFunc or self._defaultCreateFunc
	assert(type(createFunc)=="function")
	
	local anchorX = bound.anchorX or 0.5
	local anchorY = bound.anchorY or 0.5
	local scale = bound.scale or 1
	local w_anchorX_scale = bound.w * anchorX * scale
	local h_anchorY_scale = bound.h * anchorY * scale
	bound.left = bound.x - w_anchorX_scale
	bound.bottom = bound.y - h_anchorY_scale
	bound.right = bound.x + w_anchorX_scale
	bound.top = bound.y + h_anchorY_scale
	
	local info = { Id = Id, bound = bound, createFunc = createFunc, refreshFunc = refreshFunc, data = data }
		
	self._allObjs[info] = Id==nil and 1 or Id
	
	if Id then self._objsById[Id] = info end
	if clTable and clTable.row and clTable.col then		
		self._allObjsPos[clTable.row] = self._allObjsPos[clTable.row] or {}
		self._allObjsPos[clTable.row][clTable.col] = info
	end
	
end

function clsContainerInterface:IsCellSeeable(info)
	local bound = info.bound
	if bound.left >= self._right then return false end
	if bound.bottom >= self._top then return false end
	if bound.right <= self._left then return false end
	if bound.top <= self._bottom then return false end
	return true
end

function clsContainerInterface:CheckSeeable()
	local innerContainer = self._innerContainer	
	local contentSize = self._innerContainer:getContentSize()
	local allObjs = self._allObjs
	local x,y = innerContainer:getPosition()
	
	if self.itemW and self.itemH then --当执行setItemSize设置尺寸，执行此过程，否则全量遍历
		local minX = math.floor(math.abs(self._left/self.itemW))
		local maxX = math.ceil(math.abs(self._right/self.itemW))
		local maxY = math.ceil(math.abs((contentSize.height-self._bottom)/self.itemH))
		local minY = math.floor(math.abs((contentSize.height-self._top)/self.itemH))
		minX = minX==0 and 1 or minX 
		for i=minY,maxY do--,,行的范围
			for j=minX,maxX do --列的范围	
				local info = self._allObjsPos[i] and self._allObjsPos[i][j]
				if info then
					if not info.obj then
						info.obj = info.createFunc(info.data)
						self._innerContainer:addChild(info.obj)
						
						local bound = info.bound
						info.obj:setPosition(bound.x, bound.y)
						info.obj:setContentSize(bound.w, bound.h)
						if bound.anchorX and bound.anchorY then
							info.obj:setAnchorPoint(cc.p(bound.anchorX,bound.anchorY))
						end
						if bound.scale then
							info.obj:setScale(bound.scale)
						end
						
						if info.refreshFunc then
							info.refreshFunc(innerContainer, info.obj, info.data, bound, info)
						end				
					end	
				end		
			end
		end
		return
	end
	
	
	for info, Id in pairs(allObjs) do
		if not info.obj then
			if self:IsCellSeeable(info) then
				info.obj = info.createFunc(info.data)
				self._innerContainer:addChild(info.obj)
				
				local bound = info.bound
				info.obj:setPosition(bound.x, bound.y)
				info.obj:setContentSize(bound.w, bound.h)
				if bound.anchorX and bound.anchorY then
					info.obj:setAnchorPoint(cc.p(bound.anchorX,bound.anchorY))
				end
				if bound.scale then
					info.obj:setScale(bound.scale)
				end
				
				if info.refreshFunc then
					info.refreshFunc(innerContainer, info.obj, info.data, bound, info)
				end
			end
		else
			if not self:IsCellSeeable(info) then
				KE_SafeDelete(info.obj)
				info.obj = nil
			end
		end
	end
end

function clsContainerInterface:SetPosition(x, y)
	self._x = x
	self._y = y
	
	--计算裁剪区域
	local fix = 50  --放宽fix像素
	self._left = -self._x - fix
	self._right = self._left + self.parentW + fix
	self._bottom = -self._y - fix
	self._top = self._bottom + self.parentH + fix
	
	self:CheckSeeable()
end

function clsContainerInterface:Destroy()
	for info, Id in pairs(self._allObjs) do
		if info.obj then
			KE_SafeDelete(info.obj)
			info.obj = nil
		end
	end
	self._allObjs = {}
	self._objsById = {}
	self._allObjsPos = {}
	self._posListener = nil
end

function clsContainerInterface:Clear()
	self._allObjs = {}
	self._objsById = {}
	self._allObjsPos = {}
	self._posListener = nil
end
