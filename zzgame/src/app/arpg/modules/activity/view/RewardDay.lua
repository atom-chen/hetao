module("ui",package.seeall)

clsRewardDay = class("clsRewardDay",clsBaseUI)

function clsRewardDay:ctor(parent)
    clsBaseUI.ctor(self,parent,"uistu/DayReward.csb")
    local data = clsActiveMgr.GetInstance():GetRewardData()
    self:req_daily_reward_reward_info(data)
    proto.req_daily_reward_reward_info()
    self:InUiEvent()
    self:RefreshUI()
end


function clsRewardDay:InUiEvent()
    utils.RegClickEvent(self.BtnClose,function() self:removeSelf() end)
    g_EventMgr:AddListener(self,"on_req_daily_reward_reward_info",self.req_daily_reward_reward_info,self)
    g_EventMgr:AddListener(self,"on_req_daily_reward_pull",self.req_daily_reward_pull,self)
end

function clsRewardDay:RefreshUI()
    local reward_info = ClsHomeMgr.GetInstance():GetRewardInfo()
    if not reward_info then return end
    self.Day_wardsimg:setScale9Enabled(false)
	self.Day_wardsimg:ignoreContentAdaptWithSize(true)
    self.Day_wardsimg:SetLoadedCallback(function()
    	local szImg = self.Day_wardsimg:getContentSize()
    	if self.Day_wardsimg._gifSprite then
    		szImg = self.Day_wardsimg._gifSprite:getContentSize()
    	end
    	local w, h = self.AreaAuto:getContentSize().width, szImg.height*self.AreaAuto:getContentSize().width/szImg.width
    	self.Day_wardsimg:SetMaxSize(w,h)
    	if self.Day_wardsimg._gifSprite then
    		self.Day_wardsimg._gifSprite:setPosition(w/2,h/2)
    	end
    	self.AreaAuto:requestDoLayout()
    end)
    self.Day_wardsimg:LoadTextureSync(ClsHomeMgr.GetInstance():GetHomeConfigData().jinji_jiajiang[2].img_base64)
    self.Text_2:setString(reward_info[1].."+")
    self.Text_3:setString(reward_info[2].."+")
    self.Text_4:setString(reward_info[3].."+")
end

function clsRewardDay:req_daily_reward_reward_info(recvdata)
	recvdata = recvdata or clsActiveMgr.GetInstance():GetRewardData()
    local rewarddata = recvdata and recvdata.data or {}
    self.yester_bet:setString(rewarddata.valid_price)
    self.grade:setString(string.format("VIP-%d",rewarddata.vip_id or 0))
    self.reward_percent:setString(rewarddata.rate)
    self.reward:setString(rewarddata.money)
    if rewarddata.is_reward and rewarddata.is_reward == 1 then
        self.ReciveBtn:setEnabled(true)
        self.ReciveBtn:setTitleText("领取")
        self.ReciveBtn:setTitleColor(cc.c3b(244,244,244))
        utils.RegClickEvent(self.ReciveBtn,function()
            proto.req_daily_reward_pull()
        end)
    else
        self.ReciveBtn:setEnabled(false)
        self.ReciveBtn:setTitleText("不可领取")
        self.ReciveBtn:setTitleColor(cc.c3b(22,22,22))
    end
end

function clsRewardDay:req_daily_reward_pull(recvdata)
    if recvdata.code == 200 then
        utils.TellMe("领取成功")
        self.ReciveBtn:setEnabled(false)
        self.ReciveBtn:setTitleText("不可领取")
        self.ReciveBtn:setTitleColor(cc.c3b(22,22,22))
    end
end