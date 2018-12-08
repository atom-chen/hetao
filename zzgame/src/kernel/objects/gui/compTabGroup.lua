-------------------------
-- Tab标签
-------------------------
clsCompTabGroup = class("clsCompTabGroup", clsCoreObject)

clsCompTabGroup:RegisterEventType("ec_select_changed")

function clsCompTabGroup:ctor(btnType)
	clsCoreObject.ctor(self)
	assert(btnType=="checkbox" or btnType=="button")
	self._btnType = btnType
	self.tTabButtons = {}
end

function clsCompTabGroup:dtor()
	self.tTabButtons = {}
end

function clsCompTabGroup:AddTabButton(id, TabBtn)
	assert(id and TabBtn)
	assert(not self.tTabButtons[id], "id已占用: "..id)
	assert(not self:GetIdOfTabButton(TabBtn), "已经添加该按钮")
	
	self.tTabButtons[id] = TabBtn
	
	if self._btnType == "checkbox" then
		TabBtn:setSelected(false)
		TabBtn:addEventListener(function(sender, eventType)
			if eventType == ccui.CheckBoxEventType.selected then
				if self._selected_id == id then
		        	self:SetSelectedTabSlient(id)
		        else
		        	self:SetSelectedTab(id)
		        end 
			end
		end)
	else
	    utils.RegClickEvent(TabBtn, function()
			if self._selected_id == id then
	        	self:SetSelectedTabSlient(id)
	        else
	        	self:SetSelectedTab(id)
	        end 
		end)
	end
end

function clsCompTabGroup:SetSelectedTab(id)
	local old_selected_id = self._selected_id
	self._selected_id = id
	self:OnSelectChange(id, old_selected_id)
	self:FireEvent("ec_select_changed", id, old_selected_id)
end

function clsCompTabGroup:SetSelectedTabSlient(id)
	local old_selected_id = self._selected_id
	self._selected_id = id
	self:OnSelectChange(id, old_selected_id)
end

-- 切换标签后的表现（默认为高亮显示选中的按钮，外部可重写该方法来定制表现）
function clsCompTabGroup:OnSelectChange(id, old_selected_id)
	for btn_id, btn in pairs(self.tTabButtons) do
		if self._btnType == "checkbox" then
			btn:setSelected(btn_id == id)
		else
			btn:setHighlighted(btn_id == id)
		end
	end
end

function clsCompTabGroup:SetTabBtnEnable(id, bEnable)
	self.tTabButtons[id]:setEnabled(bEnable)
end

function clsCompTabGroup:GetSelectedId()
	return self._selected_id
end

function clsCompTabGroup:GetSelectedBtn()
	return self._selected_id and self.tTabButtons[self._selected_id]
end

function clsCompTabGroup:GetIdOfTabButton(TabBtn)
	for id, btn in pairs(self.tTabButtons) do
		if btn == TabBtn then
			return id
		end
	end
	return nil
end
