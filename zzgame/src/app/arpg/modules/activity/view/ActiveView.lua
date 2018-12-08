module("ui",package.seeall)

clsActiveView = class("clsActiveView",clsBaseUI)

function clsActiveView:ctor(parent)
	clsBaseUI.ctor(self, parent, "uistu/Activity.csb")
	self.ListView = self.AreaAuto
	self.ListView:setScrollBarEnabled(false)
	
    g_EventMgr:AddListener(self, "on_req_activity_list", self.on_req_activity_list, self)
    
    proto.req_activity_list({show_way = "3"})
    
    if ClsLoginMgr.GetInstance():IsLogonSucc() then
	    if not clsActiveMgr.GetInstance():GetRewardData() then
	    	proto.req_daily_reward_reward_info()
	    end
	    if not clsActiveMgr.GetInstance():GetGradeData() then
	    	proto.req_grade_grade_info()
	    end
	end
end

function clsActiveView:dtor()

end

local color_list = {
	--cc.c3b(255,0,0),
	cc.c3b(240,203,24),
	cc.c3b(245,39,190),
	cc.c3b(173,139,193),
    cc.c3b(243,157,192),
    cc.c3b(83,183,119),
    cc.c3b(250,120,8),
    cc.c3b(0,139,215),
    cc.c3b(242,159,105),
    cc.c3b(137,117,232),
    cc.c3b(181,127,238),
}
function clsActiveView:on_req_activity_list(recvdata)
    local data = recvdata and recvdata.data
	self.ListView:removeAllItems()
	--clsActiveMgr.GetInstance():SaveGradeImg(data.rows[1].img_base64)
    local AcList = clsActiveMgr.GetInstance():GetActivityList() or {}
    AcList.total = AcList.total or 0
    
    local item = cc.CSLoader:createNode("uistu/item.csb")
    local listItem = item:getChildByName("maincell")
    local OtherActive = ClsHomeMgr.GetInstance():GetHomeConfigData() and ClsHomeMgr.GetInstance():GetHomeConfigData().sys_activity or ""
    --jinji_jiangli开启了哪一个
    local nNumber
    --开启了多少个
    local c
    local function Apart(str)
        local number = ""
        if string.len(str) > 1 then
            for i = 1,string.len(str),1 do
                if string.sub(str,i,i) ~= "," then
                    if i == 1 then
                        number = string.sub(str,1,1)
                    else
                        number = number..string.sub(str,i,i)
                    end
                end 
            end
        else
            number = str
        end
        number = tonumber(number)
        return number
    end 
    nNumber = Apart(OtherActive)
    if nNumber == 1 or nNumber == 12 then
        local info = {
		    title = "晋级奖励",
		    extra_title = "会员每升一级，都能获取奖励，最高可达38888元。…",
		
	    }
        --clsActiveMgr.GetInstance():SaveGradeImg(recvdata.data.rows[1].img_base64)
	    local itemwnd = listItem:clone()
	    self:RefleshItem(itemwnd, 1, info)
	    utils.RegClickEvent(itemwnd:getChildByName("Button"),function() 
		    ClsUIManager.GetInstance():ShowPanel("clsGradeView")
	    end)
	    self.ListView:pushBackCustomItem(itemwnd)
    end
    if nNumber == 2 or nNumber == 12 then
	    local info = {
		    title = "每日加奖",
		    extra_title = "每日加奖是根据会员昨日投注金额进行加奖，奖金无上…",
		
	    }
	    local itemwnd = listItem:clone()
        if nNumber == 12 then
	        self:RefleshItem(itemwnd, 2, info)
        else
            self:RefleshItem(itemwnd, 1, info)
        end
	    utils.RegClickEvent(itemwnd:getChildByName("Button"),function() 
		    ClsUIManager.GetInstance():ShowPanel("clsRewardDay")
	    end)
	    self.ListView:pushBackCustomItem(itemwnd)
    end
    if nNumber == 1 or nNumber == 2 then
        c = 1
    elseif nNumber == 12 then
        c = 2 
    else
        c = 0
    end
    --
    local rows = AcList and AcList.rows or {}
    for j, info in ipairs(rows) do
    	local wnd = listItem:clone()
    	self:RefleshItem(wnd, j+c, info)
    	self.ListView:pushBackCustomItem(wnd)
    	
    	utils.RegClickEvent(wnd:getChildByName("Button"),function() 
			ClsUIManager.GetInstance():ShowPanel("clsActView", info)
		end)
    end
end

function clsActiveView:RefleshItem(wnd, idx, info)
    local idx_sort = idx
	wnd:getChildByName("activity"):setString(info.title or "")
    wnd:getChildByName("describe"):setString(info.extra_title or "")
    utils.AdaptFont(wnd:getChildByName("activity"), wnd:getChildByName("activity"):getFontSize())
    utils.AdaptFont(wnd:getChildByName("describe"), wnd:getChildByName("describe"):getFontSize())
    if idx == 1 then
        wnd:getChildByName("Image_2"):setColor(cc.c3b(255,0,0))
    else
        if (idx-1)%10 == 0 then 
            idx = 10 
        else 
            idx = (idx-1)%10 
        end
        wnd:getChildByName("Image_2"):setColor(color_list[idx])
    end
    wnd:getChildByName("sort"):setString(idx_sort)
end