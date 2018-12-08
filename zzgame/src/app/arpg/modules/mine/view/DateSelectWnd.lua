-------------------------
-- 日期选择
-------------------------
module("ui", package.seeall)

clsDateSelectWnd = class("clsDateSelectWnd", clsBaseUI)

function clsDateSelectWnd:ctor(parent, callback)
	clsBaseUI.ctor(self, parent, "uistu/DateSelectWnd.csb", true)
	self.EditYear = utils.ReplaceTextField(self.EditYear, "", "ff000000")
	self.EditYear:setInputMode(cc.EDITBOX_INPUT_MODE_NUMERIC)
	self.EditMonth = utils.ReplaceTextField(self.EditMonth, "", "ff000000")
	self.EditMonth:setInputMode(cc.EDITBOX_INPUT_MODE_NUMERIC)
	self.EditDay = utils.ReplaceTextField(self.EditDay, "", "ff000000")
	self.EditDay:setInputMode(cc.EDITBOX_INPUT_MODE_NUMERIC)
	self.EditYear:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
	self.EditMonth:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
	self.EditDay:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
	
	self._sureCallback = callback
    local function IsRyear(year)
        if year%400 == 0 or (year % 4 == 0 and year % 100 ~= 0) then
            return true
        else
            return false
        end
    end
    local function Days(year,month)
        if month == 1 or month == 3 or month == 5 or month == 7 or month == 8 or month == 10 or month == 12 then 
            return 31
        elseif month == 4 or month == 6 or month == 9 or month == 11 then
            return 30
        else
            if IsRyear(year) then
                return 29
            else
                return 28
            end
        end
    end
	utils.RegClickEvent(self.BtnCancel,function() 
        self:removeSelf()
    end)
    utils.RegClickEvent(self.BtnSure,function() 
        if self._sureCallback then 
        	local year = self.EditYear:getString()
			local month = self.EditMonth:getString()
			local day = self.EditDay:getString()
			local tTime = {
				year = tonumber(year),
				month = tonumber(month),
				day = tonumber(day),
			}
			if not tTime.year then utils.TellMe("请填入正确的年份") return end
			if not tTime.month then utils.TellMe("请填入正确的月份") return end
			if not tTime.day then utils.TellMe("请填入正确的日期") return end
        	self._sureCallback(tTime) 
        	self:removeSelf()
        end
    end)
    
    
    self.EditYear:registerScriptEditBoxHandler(function(evenName, sender)
		local thisyear= os.date("%Y")
        if tonumber(self.EditYear:getString()) and tonumber(self.EditYear:getString()) > tonumber(thisyear) then
            utils.TellMe("请填入正确的年份")
            self.EditYear:setString(thisyear)
        end
        local year = self.EditYear:getString() 
		local month = self.EditMonth:getString()
		local day = self.EditDay:getString()
		self.lblTime:setString( string.format("%d-%02d-%02d", tonumber(year) or 0, tonumber(month) or 0, tonumber(day) or 0) )
	end)
	self.EditMonth:registerScriptEditBoxHandler(function(evenName, sender)
        local thisyear = os.date("%Y")
        local thismonth = os.date("%m")
        if tonumber(self.EditYear:getString()) and tonumber(self.EditMonth:getString()) and tonumber(self.EditYear:getString()) == tonumber(thisyear) and tonumber(self.EditMonth:getString()) > tonumber(thismonth) then
            utils.TellMe("请填入正确的月份")
            self.EditMonth:setString(thismonth)
        end
        if tonumber(self.EditMonth:getString()) and tonumber(self.EditMonth:getString()) > 12 then
            utils.TellMe("请填入正确的月份")
            self.EditMonth:setString(12)
        end
		local year = self.EditYear:getString()
		local month = self.EditMonth:getString()
		local day = self.EditDay:getString()
		self.lblTime:setString( string.format("%d-%02d-%02d", tonumber(year) or 0, tonumber(month) or 0, tonumber(day) or 0) )
	end)
	self.EditDay:registerScriptEditBoxHandler(function(evenName, sender)
        local thisyear = os.date("%Y")
        local thismonth = os.date("%m")
        local thisday = os.date("%d")
        if tonumber(self.EditYear:getString()) and tonumber(self.EditMonth:getString()) and tonumber(self.EditDay:getString()) then
            if tonumber(self.EditYear:getString()) == tonumber(thisyear) and tonumber(self.EditMonth:getString()) == tonumber(thismonth) and tonumber(self.EditDay:getString()) > tonumber(thisday) then
                utils.TellMe("请填入正确的日期")
                self.EditDay:setString(thisday)
            elseif tonumber(self.EditDay:getString()) > tonumber(Days(tonumber(self.EditYear:getString()),tonumber(self.EditMonth:getString()))) then
                utils.TellMe("请填入正确的日期")
                self.EditDay:setString(Days(tonumber(self.EditYear:getString()),tonumber(self.EditMonth:getString())))
            end
        end
        if tonumber(self.EditDay:getString()) and tonumber(self.EditDay:getString()) > 31 then
            utils.TellMe("请填入正确的日期")
            self.EditMonth:setString(31)
        end
		local year = self.EditYear:getString()
		local month = self.EditMonth:getString()
		local day = self.EditDay:getString()
		self.lblTime:setString( string.format("%d-%02d-%02d", tonumber(year) or 0, tonumber(month) or 0, tonumber(day) or 0) )
	end)
end

function clsDateSelectWnd:dtor()
	
end