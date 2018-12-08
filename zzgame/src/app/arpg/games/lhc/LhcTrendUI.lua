-------------------------
-- 趋势图
-------------------------
module("ui", package.seeall)

clsLhcTrendUI = class("clsLhcTrendUI", clsBaseUI)

function clsLhcTrendUI:ctor(parent)
	clsBaseUI.ctor(self, parent, "uistu/TrendUI.csb")
	
	local sz = self.AreaAuto:getContentSize()
	local itemSz = self.ItemHm:getContentSize()
	self.ListHm = clsCompList.new(self.AreaAuto, ccui.ScrollViewDir.vertical, sz.width, sz.height, itemSz.width, itemSz.height+2)
	self.ListHm:setScrollBarEnabled(false)
    self.ListHm:setBounceEnabled(false)
    local itemSz = self.ItemZh:getContentSize()
	self.ListZh = clsCompList.new(self.AreaAuto, ccui.ScrollViewDir.vertical, sz.width, sz.height, itemSz.width, itemSz.height+2)
	self.ListZh:setScrollBarEnabled(false)
    self.ListZh:setBounceEnabled(false)
    local itemSz = self.ItemTm:getContentSize()
	self.ListTm = clsCompList.new(self.AreaAuto, ccui.ScrollViewDir.vertical, sz.width, sz.height, itemSz.width, itemSz.height+2)
	self.ListTm:setScrollBarEnabled(false)
    self.ListTm:setBounceEnabled(false)
    self:initListHm()
	self:initListZh()
	self:initListTm()
	
	self._iPage = 1
	self.ListHm:setVisible(true)
	self.TitleHm:setVisible(true)
	self.ListZh:setVisible(false)
	self.TitleZh:setVisible(false)
	self.ListTm:setVisible(false)
	self.TitleTm:setVisible(false)
	
	utils.RegClickEvent(self.BtnClose, function() 
		self:removeSelf()
	end)
	utils.RegClickEvent(self.BtnHm, function() 
		self._iPage = 1
		self.Line:setPositionX(self.BtnHm:getPositionX())
		self.ListHm:setVisible(true)
		self.TitleHm:setVisible(true)
		self.ListZh:setVisible(false)
		self.TitleZh:setVisible(false)
		self.ListTm:setVisible(false)
		self.TitleTm:setVisible(false)
		self.BtnHm:setTitleColor(const.COLOR.RED)
		self.BtnZh:setTitleColor(const.COLOR.BLACK)
		self.BtnTm:setTitleColor(const.COLOR.BLACK)
		self:RefleshHm()
	end)
	utils.RegClickEvent(self.BtnZh, function() 
		self._iPage = 2
		self.Line:setPositionX(self.BtnZh:getPositionX())
		self.ListHm:setVisible(false)
		self.TitleHm:setVisible(false)
		self.ListZh:setVisible(true)
		self.TitleZh:setVisible(true)
		self.ListTm:setVisible(false)
		self.TitleTm:setVisible(false)
		self.BtnHm:setTitleColor(const.COLOR.BLACK)
		self.BtnZh:setTitleColor(const.COLOR.RED)
		self.BtnTm:setTitleColor(const.COLOR.BLACK)
		self:RefleshZh()
	end)
	utils.RegClickEvent(self.BtnTm, function() 
		self._iPage = 3
		self.Line:setPositionX(self.BtnTm:getPositionX())
		self.ListHm:setVisible(false)
		self.TitleHm:setVisible(false)
		self.ListZh:setVisible(false)
		self.TitleZh:setVisible(false)
		self.ListTm:setVisible(true)
		self.TitleTm:setVisible(true)
		self.BtnHm:setTitleColor(const.COLOR.BLACK)
		self.BtnZh:setTitleColor(const.COLOR.BLACK)
		self.BtnTm:setTitleColor(const.COLOR.RED)
		self:RefleshTm()
	end)
	
	g_EventMgr:AddListener(self, "on_req_goucai_game_trend_list", self.on_req_goucai_game_trend_list, self)
end

function clsLhcTrendUI:dtor()
	
end

function clsLhcTrendUI:initListHm()
	local createFunc = function(CellObj)
		local info = CellObj:GetCellData()
		
		local wndHm = self.ItemHm:clone()
		utils.getNamedNodes(wndHm)
		wndHm.lblIssue:setString(info.kithe)
		
		local sum = 0
		for i=1, 7 do
			wndHm["lblSx"..i]:setString(info.number_arr[i].sx)
			wndHm["lblNum"..i]:setString(info.number_arr[i].num)
			wndHm["ballImg"..i]:setColor(const.GAME_LHC_COLOR[info.number_arr[i].sb])
		end
		
		return wndHm
	end
	self.ListHm:SetCellCreator(createFunc)
end
function clsLhcTrendUI:initListZh()
	local createFunc = function(CellObj)
		local info = CellObj:GetCellData()
		
		local color = {}
        color["red"] = 0
        color["green"] = 0
        color["blue"] = 0
		local sum = 0
		
		for i=1, 7 do
			sum = sum + tonumber(info.number_arr[i].num)
            if info.number_arr[i].sb == "red" then
                if i ~= 7 then
                    color["red"] = color["red"] +1
                else
                    color["red"] = color["red"] +1.5
                end
            elseif info.number_arr[i].sb == "green" then
                if i ~= 7 then
                    color["green"] = color["green"] +1
                else
                    color["green"] = color["green"] +1.5
                end
            elseif info.number_arr[i].sb == "blue" then
                if i ~= 7 then
                    color["blue"] = color["blue"] +1
                else
                    color["blue"] = color["blue"] +1.5
                end
            end
		end
		--- num1 红波计数  num2 绿波计数  num3 蓝波计数
        local function max(num1,num2,num3)
            if num1 > num2 then
                if num1 > num3 then
                    return "红波"
                else
                    return "蓝波"
                end
            else
                if num2 > num3 then
                    return "绿波"
                else
                    return "蓝波"
                end
            end
        end
        
		local wndZh = self.ItemZh:clone()
		utils.getNamedNodes(wndZh)
		wndZh.lblZhIssue:setString(info.kithe)
		wndZh.lblZhZongshu:setString(sum)
		wndZh.lblZhDanshuang:setString(sum%2==0 and "双" or "单")
		wndZh.lblZhDaxiao:setString(sum>=150 and "大" or "小")
		wndZh.lblZhQisebo:setString(max(color["red"],color["green"],color["blue"]))
		
		return wndZh
	end
	self.ListZh:SetCellCreator(createFunc)
end
function clsLhcTrendUI:initListTm()
	local createFunc = function(CellObj)
		local info = CellObj:GetCellData()
		
		local color = {}
        color["red"] = 0
        color["green"] = 0
        color["blue"] = 0
		local sum = 0
		
		for i=1, 7 do
			sum = sum + tonumber(info.number_arr[i].num)
            if info.number_arr[i].sb == "red" then
                if i ~= 7 then
                    color["red"] = color["red"] +1
                else
                    color["red"] = color["red"] +1.5
                end
            elseif info.number_arr[i].sb == "green" then
                if i ~= 7 then
                    color["green"] = color["green"] +1
                else
                    color["green"] = color["green"] +1.5
                end
            elseif info.number_arr[i].sb == "blue" then
                if i ~= 7 then
                    color["blue"] = color["blue"] +1
                else
                    color["blue"] = color["blue"] +1.5
                end
            end
		end
		--- num1 红波计数  num2 绿波计数  num3 蓝波计数
        local function max(num1,num2,num3)
            if num1 > num2 then
                if num1 > num3 then
                    return "红波"
                else
                    return "蓝波"
                end
            else
                if num2 > num3 then
                    return "绿波"
                else
                    return "蓝波"
                end
            end
        end
		
		local tema = tonumber( info.number_arr[7].num )
        local _nHe = math.floor(tema/10 + tema%10)
        local _nTail = tema%10
		local wndTm = self.ItemTm:clone()
		utils.getNamedNodes(wndTm)
		wndTm.lblTmIssue:setString(info.kithe)
		wndTm.lblTmDanshuang:setString(tema%2==0 and "双" or "单")
		wndTm.lblTmDaxiao:setString(tema == 49 and "和" or (tema>=25 and "大" or "小"))
		wndTm.lblTmHedanshuang:setString(_nHe%2==0 and "双" or "单")
		wndTm.lblTmHedaxiao:setString(tema == 49 and "和" or _nHe>=7 and "大" or "小")
		wndTm.lblTmDaxiaowei:setString(tema == 49 and "和" or _nTail>=5 and "大" or "小")
		
		return wndTm
	end
	self.ListTm:SetCellCreator(createFunc)
end

function clsLhcTrendUI:SetGid(gid)
	self.gid = gid
	proto.req_goucai_game_trend_list({gid=gid})
	proto.req_home_tip_award_way({id=tostring(gid)})
end

function clsLhcTrendUI:on_req_goucai_game_trend_list(recvdata, tArgs)
	local rows = recvdata and recvdata.data and recvdata.data.rows
	if not rows then return end
	self._rows = rows
	
	print("------------刷新页面", self._iPage)
	if self._iPage == 1 then
		self:RefleshHm()
	elseif self._iPage ==  2 then
		self:RefleshZh()
	else
		self:RefleshTm()
	end
end

function clsLhcTrendUI:RefleshHm()
	if self._hmInited then return end
	local rows = self._rows
	if not rows then return end
	self._hmInited = true 
	
	local ListHm = self.ListHm
	ListHm:RemoveAll()
	for i, info in ipairs(rows) do
		ListHm:Insert(info)
	end
	ListHm:ForceReLayout()
end

function clsLhcTrendUI:RefleshTm()
	if self._tmInited then return end
	local rows = self._rows
	if not rows then return end
	self._tmInited = true 
	
	local ListTm = self.ListTm
	ListTm:RemoveAll()
	for i, info in ipairs(rows) do
		ListTm:Insert(info)
	end
	ListTm:ForceReLayout()
end

function clsLhcTrendUI:RefleshZh()
	if self._zhInited then return end
	local rows = self._rows
	if not rows then return end
	self._zhInited = true 
	
	local ListZh = self.ListZh
	ListZh:RemoveAll()
	for i, info in ipairs(rows) do
		ListZh:Insert(info)
	end
	ListZh:ForceReLayout()
end
