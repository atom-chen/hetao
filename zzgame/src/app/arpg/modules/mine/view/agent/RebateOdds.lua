module("ui", package.seeall)

clsRebateOdds = class("clsRebateOdds",clsBaseUI)

g_EventMgr:RegisterEventType("rebatetype")

function clsRebateOdds:ctor(parent, preWnd)
    clsBaseUI.ctor(self,parent,"uistu/RebateOdds.csb")
    self.ScrollView_1 = self.AreaAuto
    self.preWnd = preWnd
    self.tRebate = ClsAgentDataMgr.GetInstance():GetRebate()

	self.Panel_3:getChildByName("Text_4"):setString("玩法/返点")
	
    self:InUiEvent()

    self.ScrollView_2:setScrollBarEnabled(false)
    self.ScrollView_3:setScrollBarEnabled(false)
    self.ScrollView_1:setScrollBarEnabled(false)
    
    self.types = 1

    g_EventMgr:AddListener(self,"on_req_bonus_detailed_get_list",self.reflesh,self)
    g_EventMgr:AddListener(self,"rebatetype",function(this,data)
        if data ~= self.types then
            if data == 1 then
                self.types = data
                proto.req_bonus_detailed_get_list({type = "k3"})
            elseif data == 2 then
                self.types = data
                proto.req_bonus_detailed_get_list({type = "ssc"})
            elseif data == 3 then
                self.types = data
                proto.req_bonus_detailed_get_list({type = "11x5"})
            elseif data == 4 then
                self.types = data
                proto.req_bonus_detailed_get_list({type = "lhc"})
            elseif data == 5 then
                self.types = data
                proto.req_bonus_detailed_get_list({type = "pk10"})
            elseif data == 6 then
                self.types = data
                proto.req_bonus_detailed_get_list({type = "fc3d"})
            elseif data == 7 then
                self.types = data
                proto.req_bonus_detailed_get_list({type = "pl3"})
            end
        end
    end)
    
    
    proto.req_bonus_detailed_get_list({type = "k3"})
end

function clsRebateOdds:dtor()
	if utils.IsValidCCObject(self.preWnd) then self.preWnd:setVisible(true) end
end

function clsRebateOdds:ForceAdapt()
	clsBaseUI.ForceAdapt(self)
	self.ScrollView_2:setContentSize(self.ScrollView_2:getContentSize().width, self.AreaAuto:getContentSize().height)
	self.ScrollView_2:setPositionY(self.AreaAuto:getPositionY())
	self.ScrollView_3:setPositionY(self:GetAdaptInfo().hAuto)
end

function clsRebateOdds:InUiEvent()
    utils.RegClickEvent(self.BtnClose,function()
        self:removeSelf()
    end)
    utils.RegClickEvent(self.Button_1,function()
        ClsUIManager.GetInstance():ShowPopWnd("clsSelectType")
    end)
end

function clsRebateOdds:reflesh(recvdata)
    local max_rebate 
	if self.types == 1 then
        self.BtnText:setString("快3")
        max_rebate = self.tRebate.k3
    elseif self.types == 2 then
        self.BtnText:setString("时时彩")
        max_rebate = self.tRebate.ssc
    elseif self.types == 3 then
        self.BtnText:setString("11选5")
        max_rebate = self.tRebate["11x5"]
    elseif self.types == 4 then
        self.BtnText:setString("六合彩")
        max_rebate = self.tRebate.lhc
    elseif self.types == 5 then
        self.BtnText:setString("pk拾")
        max_rebate = self.tRebate.pk10
    elseif self.types == 6 then
        self.BtnText:setString("福彩3D")
        max_rebate = self.tRebate.fc3d
    elseif self.types == 7 then
        self.BtnText:setString("排列三")
        max_rebate = self.tRebate.pl3
    end
    
    if self.innerInterface_1 then KE_SafeDelete(self.innerInterface_1) end
	if self.innerInterface_2 then KE_SafeDelete(self.innerInterface_2) end
	if self.innerInterface_3 then KE_SafeDelete(self.innerInterface_3) end
    self.ScrollView_2:removeAllChildren()
    self.ScrollView_3:removeAllChildren()
    self.ScrollView_1:removeAllChildren()
    local data = recvdata.data
    local num = 0
    local num_1 = 0
    local num_2 = 0
    
    for i = tonumber(max_rebate),0.0,-0.1 do
        num = num + 1
    end
    
    for i = tonumber(data.user_rebate.rebate),0.0,-0.1 do
        num_2 = num_2 + 1
    end

    if #data.rows > 0 then
        for i=1,#data.rows do
            if data.rows[i].child and #data.rows[i].child>0 then
                for j = 1,#data.rows[i].child,1 do
                    if data.rows[i].child[j].child then
                        if  #data.rows[i].child[j].child > 0 then
                            for k = 1,#data.rows[i].child[j].child do
                                num_1 = num_1 + 1
                            end
                        end
                    else
                        num_1 = num_1 + 1
                    end
                end
            end
        end 
    end
    
    local WID, HEI = 140, 60
    local BtnW, BtnH = WID-2, HEI-2
    self.ScrollView_1:setInnerContainerSize(cc.size(160+num*WID, (num_1+1)*HEI))
	self.ScrollView_2:setInnerContainerSize(cc.size(160, (num_1+1)*HEI))
    self.ScrollView_3:setInnerContainerSize(cc.size(160+num*WID, HEI))
	
	local innerInterface_1 = clsContainerInterface.new(self.ScrollView_1, function(x, y)
		self.ScrollView_2:setInnerContainerPosition( cc.p(0,y) )
		self.ScrollView_3:setInnerContainerPosition( cc.p(x,0) )
	end)
	
	innerInterface_1:setItemSize(BtnW,BtnH)
	
    local innerInterface_2 = clsContainerInterface.new(self.ScrollView_2)
    local innerInterface_3 = clsContainerInterface.new(self.ScrollView_3)
	
    self.innerInterface_1 = innerInterface_1
    self.innerInterface_2 = innerInterface_2--左边单列列表
    self.innerInterface_3 = innerInterface_3
	
	local lblColor = cc.c3b(0,0,0)
	local anchor = cc.p(0,1)
	local respath = RES_CONFIG.common_white
	local refreshFunc = nil
	local createFunc = function(data) 
        local cell = utils.CreateScale9Sprite(respath)
		local lable = utils.CreateLabel(data, 20, lblColor)
		lable:setPosition(BtnW/2, BtnH/2)
		cell:addChild(lable)
        cell:setAnchorPoint(anchor)
		return cell
	end
    local createFunc_1 = function(data) 
        local cell = utils.CreateScale9Sprite(respath)
		local lable = utils.CreateLabel(data, 20, lblColor)
		lable:setPosition(BtnW/2, BtnH/2)
		cell:addChild(lable)
        cell:setAnchorPoint(anchor)
		return cell
	end
	
	local string_format = string.format
	local string_find = string.find
    local n = 0
    for i = tonumber(max_rebate),0.0,-0.1 do
        local data_2 = string_format("%0.1f",i)
        local i_x = 160 + n * WID
        local i_y = BtnH
        local bound_1 = {x = i_x,y = i_y,w=BtnW,h =BtnH}
        innerInterface_3:AddObjectDelay(nil, bound_1, createFunc, refreshFunc, data_2,{row = index,col = c})--顶部单行列表
        n = n+1
    end
    
    local index = 0
    if #data.rows > 0 then
        for i=1,#data.rows do
            if data.rows[i].child and #data.rows[i].child>0 then
                for j = 1,#data.rows[i].child,1 do
                    if data.rows[i].child[j].child then
                        if  #data.rows[i].child[j].child > 0 then
                            for k = 1,#data.rows[i].child[j].child do
                                index = index + 1
                                local data_1 = data.rows[i].name.."-"..data.rows[i].child[j].child[k].name
                                local i_x = 0
                                local i_y = self.ScrollView_2:getInnerContainerSize().height - index * HEI - 2
                                local bound_1 = {x = i_x,y = i_y,w=160,h =BtnH}
                                innerInterface_2:AddObjectDelay(nil, bound_1, createFunc_1, refreshFunc, data_1,{row = index,col = c})
                                local value = tonumber(string_format("%0.3f",tonumber(data.rows[i].child[j].child[k].rate) - tonumber(data.rows[i].child[j].child[k].rate_min)))/(num_2 - 1)
                                local difference = num_2 - num
                                for c = 1,num,1 do
                                    local p_x = 160 + ( c - 1 ) * WID
                                    local data_2 = tonumber(string_format("%0.3f",tonumber(data.rows[i].child[j].child[k].rate - (difference + c - 1)*value)))  -- data可是任意类型
			                        local bound = { x=p_x, y=i_y, w=BtnW, h=BtnH }
			                        innerInterface_1:AddObjectDelay(nil, bound, createFunc, refreshFunc, data_2,{row = index,col = c})
                                end
                            end
                        end
                    else
                        if not string_find(data.rows[i].child[j].rate,",") then
                            index = index + 1
                            local data_1 = data.rows[i].name.."-"..data.rows[i].child[j].name
                            --print("1111111111111111111111111111111111111"..data_1)
                            local i_x = 0
                            local i_y = self.ScrollView_2:getInnerContainerSize().height - index * HEI - 2
                            local bound_1 = {x = i_x,y = i_y,w=160,h=BtnH}
                            innerInterface_2:AddObjectDelay(nil, bound_1, createFunc_1, refreshFunc, data_1,{row = index,col = c})
                        
                            local value = (tonumber(string_format("%0.3f",tonumber(data.rows[i].child[j].rate))) - tonumber(string_format("%0.3f",tonumber(data.rows[i].child[j].rate_min))))/(num_2 - 1)
                            local difference = num_2 - num
                            for c = 1,num,1 do
                                local p_x = 160 + ( c - 1 ) * WID
                                local data_2 = tonumber(string_format("%0.3f",tonumber(data.rows[i].child[j].rate - (difference + c - 1)*value)))  -- data可是任意类型
                                local bound = { x=p_x, y=i_y, w=BtnW, h=BtnH }
                                innerInterface_1:AddObjectDelay(nil, bound, createFunc, refreshFunc, data_2,{row = index,col = c})
                            end
                        else
                            local str1
                            local str2
                            str1 = self:Strl(data.rows[i].child[j].rate,",")
                            str2 = self:Strl(data.rows[i].child[j].rate_min,",")
                            index = index + 1
                            local data_1 = data.rows[i].name.."-"..data.rows[i].child[j].name
                            local i_x = 0
                            local i_y = self.ScrollView_2:getInnerContainerSize().height - index * HEI - 2
                            local bound_1 = {x = i_x,y = i_y,w=160,h =BtnH}
                            innerInterface_2:AddObjectDelay(nil, bound_1, createFunc_1, refreshFunc, data_1,{row = index,col = c})

                            local value = tonumber(string_format("%0.3f",(tonumber(str1) - tonumber(str2))/(num_2-1)))
                            local difference = num_2 - num
                            for c = 1,num,1 do
                                local p_x = 160 + ( c - 1 ) * WID
                                local data_2 = tonumber(string_format("%0.3f",tonumber(str1) - (difference + c - 1)*value))  -- data可是任意类型
                                local bound = { x=p_x, y=i_y, w=BtnW, h=BtnH }
                                innerInterface_1:AddObjectDelay(nil, bound, createFunc, refreshFunc, data_2,{row = index,col = c})
                            end
                        end
                    end
                end
            end
        end 
    end
    innerInterface_1:CheckSeeable()
    innerInterface_2:CheckSeeable()
    innerInterface_3:CheckSeeable()
end

function clsRebateOdds:Strl(str,symbol)
    local len = string.len(str)
    local index = string.find(str,symbol)
    local str1 = string.sub(str,1,index - 1)
    local str2 = string.sub(str,index+1,len)
    return str1
end