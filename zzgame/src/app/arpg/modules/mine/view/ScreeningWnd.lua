module("ui",package.seeall)

local SCREETING_CFG = {
	WITHDRAW = {
		title = "提现记录筛选",
		typelist = {
			[1] = { type = "1", name="审核中" },
			[2] = { type = "2", name="提现成功" },
			[3] = { type = "4", name="预备提现" },
			[4] = { type = "5", name="审核未通过" },
		},
	},
	RECHARGE = {
		title = "充值记录筛选",
		typelist = {
			[1] = { type = "", name="全部" },
			[2] = { type = "1", name="银行转账" },
			[3] = { type = "2", name="线上入款" },
			[4] = { type = "3", name="彩豆充值" },
			[5] = { type = "4", name="人工存入" },
		},
	},
	ACCOUNT_DETAIL = {
		title = "账户明细筛选",
		typelist = {
			[1] = { type = "1", name="彩票下註" },
			[2] = { type = "2", name="彩票派彩" },
			[3] = { type = "3", name="優惠退水" },
			[4] = { type = "4", name="註單取消" },
			[5] = { type = "5", name="綫上入款" },
			[6] = { type = "6", name="公司入款" },
			[7] = { type = "7", name="綫上入款不含優惠" },
			[8] = { type = "8", name="公司入款無優惠" },
			[9] = { type = "11", name="優惠活動" },
			[10] = { type = "12", name="人工存入" },
			[11] = { type = "13", name="人工取出" },
			[12] = { type = "14", name="公司出款" },
			[13] = { type = "15", name="彩豆充值" },
			[14] = { type = "5,6,12,15,7,8,18", name="入款明細" },
			[15] = { type = "13,14", name="出款明細" },
			[16] = { type = "18", name="取消出款" },
			[17] = { type = "19", name="代理退傭" },
			[18] = { type = "20", name="晉級獎勵" },
			[19] = { type = "21", name="額度轉換" },
			[20] = { type = "22", name="嘉獎獎勵" },
			[21] = { type = "0", name="全部" },
		},
	},
}

clsScreeningWnd = class("clsScreeningWnd",clsBaseUI)

function clsScreeningWnd:ctor(parent, argInfo)
    clsBaseUI.ctor(self,parent,"uistu/ScreeningWnd.csb")
    
    local ScreetType = argInfo.ScreetType
    self.ScreetCfg = SCREETING_CFG[ScreetType]
    assert(self.ScreetCfg)
    self._callback = argInfo.callback
    self.y_start = 0
    self.m_start = 0
    self.d_start = 0
    self.y_end = 0
    self.m_end = 0
    self.d_end = 0
    self._conditionType = { type = "", name="全部" }
    self.time_start = ""
    self.time_end = ""
    
    self:InitUI()
end

function clsScreeningWnd:dtor()
    
end

function clsScreeningWnd:InitUI()
	self.lblTitle:setString(self.ScreetCfg.title)
	
	local infolist = self.ScreetCfg.typelist
	local cnt = #infolist
	local margin = { left=10, bottom=4, right=10, top=4}
	local innerGrid = clsInnerGrid.new(self.TypeArea:getContentSize().width, 3, cnt, 60, nil, margin)
	self.TypeArea:setContentSize(innerGrid:GetSize())
	local btnWid, btnHei = innerGrid:GetCellSize()
	btnWid = 170
	btnHei = 50
	local tabGroup = clsCompTabGroup.new("button")
    for idx, info in ipairs(infolist) do
    	local curBtn = ccui.Button:create("uistu/bg/item_bank_selected.png", "uistu/bg/red_bg_square.png", "uistu/bg/red_bg_square.png")
    	self.TypeArea:addChild(curBtn)
    	tabGroup:AddTabButton(idx, curBtn)
    	curBtn:setScale9Enabled(true)
    	curBtn:setContentSize(btnWid, btnHei)
    	curBtn:setTitleText(info.name)
    	curBtn:setTitleFontSize(20)
    	curBtn:setTitleColor(cc.c3b(22,22,22))
    	curBtn:setPosition( innerGrid:GetPosByIdx(idx) )
    end
    tabGroup:AddListener(self, "ec_select_changed", function(tabGroup, id, old_selected_id)
		self._conditionType = infolist[id]
	end)
    self.boxbg_0:setContentSize(self.PanelTop:getContentSize().width, self.TypeArea:getPositionY()+self.TypeArea:getContentSize().height+self.PanelTop:getContentSize().height+10)
    self.PanelTop:setPositionY(self.boxbg_0:getContentSize().height-10)
    
    utils.RegClickEvent(self.BtnCancel,function()
        self:removeSelf()
    end)
    
    utils.RegClickEvent(self.BtnSure,function()
    	if self._callback then
    		local conditions = {
    			time_start = self.time_start,
    			time_end = self.time_end,
    			typeinfo = self._conditionType,
    		}
    		self._callback(conditions)
    	end
        self:removeSelf()
    end)
    
    utils.RegClickEvent(self.Button_1,function()
        ClsUIManager.GetInstance():ShowPopWnd("clsDateSelectWnd2", function(tTime)
            tTime.year,tTime.month,tTime.day = self:mintime(tTime.year,tTime.month,tTime.day)
            self.y_start = tTime.year
            self.m_start = tTime.month
            self.d_start = tTime.day
        	self.Button_1:setTitleText(string.format("起：%d-%02d-%02d",tTime.year,tTime.month,tTime.day))
            self.time_start = string.format("%d%02d%02d",tTime.year,tTime.month,tTime.day)
        end)
    end)
    utils.RegClickEvent(self.Button_2,function() 
        ClsUIManager.GetInstance():ShowPopWnd("clsDateSelectWnd2", function(tTime)
            tTime.year,tTime.month,tTime.day=self:maxtime(tTime.year,tTime.month,tTime.day,self.y_start,self.m_start,self.d_start)
        	print("cccccccccccccccccccccccccccccccccccccccccccc:"..tTime.month..tTime.day..tTime.year)
            self.Button_2:setTitleText(string.format("止：%d-%02d-%02d",tTime.year,tTime.month,tTime.day))
            self.time_end = string.format("%d%02d%02d",tTime.year,tTime.month,tTime.day)
        end)
    end)
end

function clsScreeningWnd:mintime(y,m,d)
    y = tonumber(y)
    m = tonumber(m)
    d = tonumber(d)
    local year = tonumber(os.date("%Y"))
    local month = tonumber(os.date("%m"))
    local day = tonumber(os.date("%d"))
    if y < year-1 or m < month-2 then
        y = year
        m = month - 2 
        d = day
        utils.TellMe("仅限于查询两个月以内的记录")
    elseif y == year-1 and (month == 1 or month == 2 ) then
        if month == 1 and m < 11 then
            m = 11
            d = day
            utils.TellMe("仅限于查询两个月以内的记录")
        end
        if month == 2 and m < 12 then
            m = 12
            d = day
            utils.TellMe("仅限于查询两个月以内的记录")
        end
    elseif y == year and (m > month or (m == month and d > day)) then
        m = month
        d = day
        utils.TellMe("前选择正确的时间段")
    end
    return y,m,d
end

function clsScreeningWnd:maxtime(y,m,d,y1,m1,d1)
    y = tonumber(y)
    y1 = tonumber(y1)
    m = tonumber(m)
    m1 = tonumber(m1)
    d1 = tonumber(d1)
    d = tonumber(d)
    local year = tonumber(os.date("%Y"))
    local month = tonumber(os.date("%m"))
    local day = tonumber(os.date("%d"))
    if y1 ~= 0 and m1 ~= 0 and d1~=0 then
        if y < y1 then
            y = y1
            m = m1
            d = d1
            utils.TellMe("前选择正确的时间段")
        elseif y== y1 and m < m1 then
            y = y1
            m = m1
            d = d1
            utils.TellMe("前选择正确的时间段")
        elseif y == y1 and m == m1 and d < d1 then
            y = y1
            m = m1
            d = d1
            utils.TellMe("前选择正确的时间段")
        end
        if y > year then
            y = year
            m = month
            d = day
            utils.TellMe("前选择正确的时间段")
        elseif y == year and m > month then
            y = year
            m = month
            d = day
            utils.TellMe("前选择正确的时间段")
        elseif y == year and m == month and d > day then
            y = year
            m = month
            d = day
            utils.TellMe("前选择正确的时间段")
        end
    else
        if y < year-1 or m < month-2 then
            y = year
            m = month - 2 
            d = day
            utils.TellMe("仅限于查询两个月以内的记录")
        elseif y == year-1 and (month == 1 or month == 2 ) then
            y = year -1 
            if month == 1 and m < 11 then
                m = 11
                d = day
                utils.TellMe("仅限于查询两个月以内的记录")
            end
            if month == 2 and m < 12 then
                m = 12
                d = day
                utils.TellMe("仅限于查询两个月以内的记录")
            end
        elseif y == year and (m > month or (m == month and d > day)) then
            y = year
            m = month
            d = day
            utils.TellMe("前选择正确的时间段")
        end
        if y > year then
            y = yaer
            m = month
            d = day
            utils.TellMe("前选择正确的时间段")
        elseif y == year and m > month then
            y = yaer
            m = month
            d = day
            utils.TellMe("前选择正确的时间段")
        elseif y == year and m == month and d > day then
            y = yaer
            m = month
            d = day
            utils.TellMe("前选择正确的时间段")
        end
    end
    return y,m,d
end