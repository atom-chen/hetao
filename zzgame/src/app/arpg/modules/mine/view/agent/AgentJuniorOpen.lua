-------------------------
-- 下级开户
-------------------------
module("ui", package.seeall)

clsAgentJuniorOpen = class("clsAgentJuniorOpen", clsBaseUI)

function clsAgentJuniorOpen:ctor(parent, preWnd)
	clsBaseUI.ctor(self, parent, "uistu/AgentJuniorOpen.csb")
	self.K3 = utils.ReplaceTextField(self.K3,"uistu/common/null.png","FF111111")
    self.Ssc = utils.ReplaceTextField(self.Ssc,"uistu/common/null.png","FF111111")
    self.Elevenfive = utils.ReplaceTextField(self.Elevenfive,"uistu/common/null.png","FF111111")
    self.Lhc = utils.ReplaceTextField(self.Lhc,"uistu/common/null.png","FF111111")
    self.Pks = utils.ReplaceTextField(self.Pks,"uistu/common/null.png","FF111111")
    self.Fc3D = utils.ReplaceTextField(self.Fc3D,"uistu/common/null.png","FF111111")
    self.Pl3 = utils.ReplaceTextField(self.Pl3,"uistu/common/null.png","FF111111")
    
    self.K3:setInputMode(cc.EDITBOX_INPUT_MODE_DECIMAL)
    self.Ssc:setInputMode(cc.EDITBOX_INPUT_MODE_DECIMAL)
    self.Elevenfive:setInputMode(cc.EDITBOX_INPUT_MODE_DECIMAL)
    self.Lhc:setInputMode(cc.EDITBOX_INPUT_MODE_DECIMAL)
    self.Pks:setInputMode(cc.EDITBOX_INPUT_MODE_DECIMAL)
    self.Fc3D:setInputMode(cc.EDITBOX_INPUT_MODE_DECIMAL)
    self.Pl3:setInputMode(cc.EDITBOX_INPUT_MODE_DECIMAL)
    
	self.preWnd = preWnd
	if table.is_empty(ClsAgentDataMgr.GetInstance():GetRebate()) then 
    	proto.req_invite_code_list()
    end
    g_EventMgr:AddListener(self,"on_req_invite_code_list",self.init,self,true)
    self:InitGlbEvents()
    
    self:InitUiEvents()
	self:CheckTab(1)
end

function clsAgentJuniorOpen:init(recvdata)
    self:Refresh(recvdata)
end

function clsAgentJuniorOpen:dtor()
	if utils.IsValidCCObject(self.preWnd) then self.preWnd:setVisible(true) end
end

function clsAgentJuniorOpen:CheckOpenType(openType)
	assert(openType == 1 or openType == 2)
	self._openType = openType
    self._codeType = openType
	self.CheckBox_1:setSelected(openType == 2)
	self.CheckBox_2:setSelected(openType == 1)
	self.CheckBox_1:setTouchEnabled(openType ~= 2)
	self.CheckBox_2:setTouchEnabled(openType ~= 1)
end

function clsAgentJuniorOpen:CheckCodeType(codeType)
	assert(codeType == 1 or codeType == 2)
	self._codeType = codeType
    self._openType = codeType
	self.CheckBox_1_0:setSelected(codeType == 2)
	self.CheckBox_2_0:setSelected(codeType == 1)
	self.CheckBox_1_0:setTouchEnabled(codeType ~= 2)
	self.CheckBox_2_0:setTouchEnabled(codeType ~= 1)
	proto.req_agent_invite_code_list({type = codeType })
end

function clsAgentJuniorOpen:CheckTab(tab)
	assert(tab==1 or tab==2)
	self.Panel_1:setVisible(tab==1)
	self.Panel_20:setVisible(tab==2)
	
	self.Button_1:setColor( tab==2 and cc.c3b(220,59,64) or cc.c3b(255,255,255) )
	self.Text_1:setTextColor( tab==2 and cc.c3b(255,255,255) or cc.c3b(255,0,0) )
	
	self.Button_2:setColor( tab==1 and cc.c3b(220,59,64) or cc.c3b(255,255,255) )
	self.Text_2:setTextColor( tab==1 and cc.c3b(255,255,255) or cc.c3b(255,0,0) )
	
	if tab==1 then 
		self:CheckOpenType(self._openType or 2) 
	else
		self:CheckCodeType(self._codeType or 2)
	end
end

--注册控件事件
function clsAgentJuniorOpen:InitUiEvents()
	utils.RegClickEvent(self.BtnClose, function() self:removeSelf() end)
    utils.RegClickEvent(self.Button_4,function()
    	self:setVisible(false)
        ClsUIManager.GetInstance():ShowPanel("clsRebateOdds", self)
    end)
    
    utils.RegClickEvent(self.Button_1,function()
        self:CheckTab(1)
    end)
    utils.RegClickEvent(self.Button_2,function()
        self:CheckTab(2)
    end)
    
    utils.RegClickEvent(self.Button_5,function()
        local params = {}
        params.ssc = self.Ssc:getText()
        params.k3 = self.K3:getText()
        params.lhc = self.Lhc:getText()
        params["11x5"] = self.Elevenfive:getText()
        params.fc3d = self.Fc3D:getText()
        params.pl3 = self.Pl3:getText()
        params.pk10 = self.Pks:getText()
        params.type = self._openType
        if not params.type then
            utils.TellMe("请选择开户类型")
            return
        end
        for k, v in pairs(params) do 
        	if not v or v == "" then
        		utils.TellMe("请输入正确的返点数")
        		return
        	end
        end
        proto.req_create_invite_code(params)
    end)
    
    local function SelectEvent_1(sender,eventType)
        if eventType == ccui.CheckBoxEventType.selected then
            self:CheckOpenType(2)
        end
    end
    self.CheckBox_1:addEventListener(SelectEvent_1)
    local function SelectEvent_2(sender,eventType)
        if eventType == ccui.CheckBoxEventType.selected then
			self:CheckOpenType(1)
        end
    end
    self.CheckBox_2:addEventListener(SelectEvent_2)

    local function SelectEvent_3(sender,eventType)
        self:CheckCodeType(2)
    end
    self.CheckBox_1_0:addEventListener(SelectEvent_3)
    local function SelectEvent_4(sender,eventType)
        self:CheckCodeType(1)
    end
    self.CheckBox_2_0:addEventListener(SelectEvent_4)
    self.K3:registerScriptEditBoxHandler(function(evenName, sender)
        if evenName == "return" then
            local data = tonumber(self.K3:getString())
            if not data then
                utils.TellMe("请输入正确的返点数据")
                self.K3:setString(null)
                return
            else
                if math.floor(data) == data then
                    self.K3:setString(data..".0")
                end
                if data < 0.1 then
                    self.K3:setString(0.1)
                    return
                elseif data > self.nK3 then
                    self.K3:setString(self.nK3)
                    if math.floor(tonumber(self.nK3)) == tonumber(self.nK3) then
                        self.K3:setString(self.nK3..".0")
                    end
                    return
                end
            end
        end
    end)
    self.Ssc:registerScriptEditBoxHandler(function(evenName, sender)
        if evenName == "return" then
            local data = tonumber(self.Ssc:getString())
            if not data then
                utils.TellMe("请输入正确的返点数据")
                self.Ssc:setString(null)
                return
            else
                if math.floor(data) == data then
                    self.Ssc:setString(data..".0")
                end
                if data < 0.1 then
                    self.Ssc:setString(0.1)
                    return
                elseif data > self.nSsc then
                    self.Ssc:setString(self.nSsc)
                    if math.floor(tonumber(self.nSsc)) == tonumber(self.nSsc) then
                        self.Ssc:setString(self.nSsc..".0")
                    end
                    return
                end
            end
        end
    end)
    self.Elevenfive:registerScriptEditBoxHandler(function(evenName, sender)
        if evenName == "return" then
            local data = tonumber(self.Elevenfive:getString())
            if not data then
                utils.TellMe("请输入正确的返点数据")
                self.Elevenfive:setString(null)
                return
            else
                if math.floor(data) == data then
                    self.Elevenfive:setString(data..".0")
                end
                if data < 0.1 then
                    self.Elevenfive:setString(0.1)
                    return
                elseif data > self.n11x5 then
                    self.Elevenfive:setString(self.n11x5)
                    if math.floor(tonumber(self.n11x5)) == tonumber(self.n11x5) then
                        self.Elevenfive:setString(self.n11x5..".0")
                    end
                    return
                end
            end
        end
    end)
    self.Lhc:registerScriptEditBoxHandler(function(evenName, sender)
        if evenName == "return" then
            local data = tonumber(self.Lhc:getString())
            if not data then
                utils.TellMe("请输入正确的返点数据")
                self.Lhc:setString(null)
                return
            else
                if math.floor(data) == data then
                    self.Lhc:setString(data..".0")
                end
                if data < 0.1 then
                    self.Lhc:setString(0.1)
                    return
                elseif data > self.nLhc then
                    self.Lhc:setString(self.nLhc)
                    if math.floor(tonumber(self.nLhc)) == tonumber(self.nLhc) then
                        self.Lhc:setString(self.nLhc..".0")
                    end
                    return
                end
            end
        end
    end)
    self.Pks:registerScriptEditBoxHandler(function(evenName, sender)
        if evenName == "return" then
            local data = tonumber(self.Pks:getString())
            if not data then
                utils.TellMe("请输入正确的返点数据")
                self.Pks:setString(null)
                return
            else
                if math.floor(data) == data then
                    self.Pks:setString(data..".0")
                end
                if data < 0.1 then
                    self.Pks:setString(0.1)
                    return
                elseif data > self.nPk10 then
                    self.Pks:setString(self.nPk10)
                    if math.floor(tonumber(self.nPk10)) == tonumber(self.nPk10) then
                        self.Pks:setString(self.nPk10..".0")
                    end
                    return
                end
            end
        end
    end)
    self.Fc3D:registerScriptEditBoxHandler(function(evenName, sender)
        if evenName == "return" then
            local data = tonumber(self.Fc3D:getString())
            if not data then
                utils.TellMe("请输入正确的返点数据")
                self.Fc3D:setString(null)
                return
            else
                if math.floor(data) == data then
                    self.Fc3D:setString(data..".0")
                end
                if data < 0.1 then
                    self.Fc3D:setString(0.1)
                    return
                elseif data > self.nFc3d then
                    self.Fc3D:setString(self.nFc3d)
                    if math.floor(tonumber(self.nFc3d)) == tonumber(self.nFc3d) then
                        self.Fc3D:setString(self.nFc3d..".0")
                    end
                    return
                end
            end
        end
    end)
    self.Pl3:registerScriptEditBoxHandler(function(evenName, sender)
        if evenName == "return" then
            local data = tonumber(self.Pl3:getString())
            if not data then
                utils.TellMe("请输入正确的返点数据")
                self.Pl3:setString(null)
                return
            else
                if math.floor(data) == data then
                    self.Pl3:setString(data..".0")
                end
                if data < 0.1 then
                    self.Pl3:setString(0.1)
                    return
                elseif data > self.nPl3 then
                    self.Pl3:setString(self.nPl3)
                    if math.floor(tonumber(self.nPl3)) == tonumber(self.nPl3) then
                        self.Pl3:setString(self.nPl3..".0")
                    end
                    return
                end
            end
        end
    end)
end

-- 注册全局事件
function clsAgentJuniorOpen:InitGlbEvents()
	g_EventMgr:AddListener(self,"on_req_create_invite_code",self.on_req_create_invite_code,self)
    g_EventMgr:AddListener(self,"on_req_agent_invite_code_list",self.on_req_agent_invite_code_list,self)
end

function clsAgentJuniorOpen:Refresh(recvdata)
    local data = ClsAgentDataMgr.GetInstance():GetRebate() or {}
    self.nSsc = tonumber(data.ssc) or 0
    self.nK3 = tonumber(data.k3) or 0
    self.n11x5 = tonumber(data["11x5"]) or 0
    self.nFc3d = tonumber(data.fc3d) or 0
    self.nPl3 = tonumber(data.pl3) or 0
    self.nPk10 = tonumber(data.pk10) or 0
    self.nLhc = tonumber(data.lhc) or 0

    self.K3:setPlaceHolder("自身返点"..self.nK3..",可设置返点0.1~"..self.nK3)
    self.Ssc:setPlaceHolder("自身返点"..self.nSsc..",可设置返点0.1~"..self.nSsc)
    self.Elevenfive:setPlaceHolder("自身返点"..self.n11x5..",可设置返点0.1~"..self.n11x5)
    self.Lhc:setPlaceHolder("自身返点"..self.nLhc..",可设置返点0.1~"..self.nLhc)
    self.Pks:setPlaceHolder("自身返点"..self.nPk10..",可设置返点0.1~"..self.nPk10)
    self.Fc3D:setPlaceHolder("自身返点"..self.nFc3d..",可设置返点0.1~"..self.nFc3d)
    self.Pl3:setPlaceHolder("自身返点"..self.nPl3..",可设置返点0.1~"..self.nPl3)
end

function clsAgentJuniorOpen:on_req_create_invite_code(recvdata, tArgs)
    self.K3:setString("")
    self.Ssc:setString("")
    self.Elevenfive:setString("")
    self.Lhc:setString("")
    self.Pks:setString("")
    self.Fc3D:setString("")
    self.Pl3:setString("")
    proto.req_agent_invite_code_list({ type = tArgs.type })
    self:CheckTab(2)
end

function clsAgentJuniorOpen:on_req_agent_invite_code_list(recvdata, tArgs)
	if tArgs.type ~= self._codeType then return end
    self.ListView_1:removeAllChildren()
    
    local data = recvdata and recvdata.data 
    if not data then
    	self.Nodata:setVisible(false)
    	return
    end
    
    local invite_codes = data.invite_codes or {}
    
    self.Nodata:setVisible(#invite_codes==0)
    
    self.ListView_1:setItemModel(self.Button_8)
    for i,v in ipairs(invite_codes) do
        self.ListView_1:pushBackDefaultItem()
        local Btn = self.ListView_1:getItem(i-1)
        if v.type == 2 or v.type=="2" then
            Btn:getChildByName("type"):setString("代理")
        else
            Btn:getChildByName("type"):setString("用户")
        end
      --  utils.TellMe("===="..v.type..type(v.type))
        Btn:getChildByName("invite_code"):setString(v.invite_code)
        Btn:getChildByName("time"):setString(os.date( "%Y-%m-%d", tonumber(v.addtime) ) or "")
        Btn:getChildByName("num"):setString("注册("..v.register_num..")")
        utils.RegClickEvent(Btn,function()
            ClsAgentDataMgr.GetInstance():SaveCode(v)
            ClsAgentDataMgr.GetInstance():SaveMemberdata(v)
            ClsUIManager.GetInstance():ShowPopWnd("clsCountMessage")
        end)
    end
    gameutil.MarkAllLoaded(self.ListView_1)
end