-------------------------
-- 性别选择
-------------------------
module("ui", package.seeall)

clsSexSelectWnd = class("clsSexSelectWnd", clsBaseUI)

function clsSexSelectWnd:ctor(parent, callback)
	clsBaseUI.ctor(self, parent, "uistu/SexSelectWnd.csb")
	self._sureCallback = callback
	self._curSelect = const.GENDER.MALE
    self.BtnFemale:setTitleColor(cc.c3b(65,65,70))
    self.BtnMale:setTitleColor(cc.c3b(250,11,11))
    
	utils.RegClickEvent(self.BtnCancel,function() 
        self:removeSelf()
    end)
    utils.RegClickEvent(self.BtnSure,function() 
        if self._sureCallback then self._sureCallback(self._curSelect) end
        self:removeSelf()
    end)
    utils.RegClickEvent(self.BtnMale,function() 
        self._curSelect = const.GENDER.MALE
        self.BtnFemale:setTitleColor(cc.c3b(65,65,70))
        self.BtnMale:setTitleColor(cc.c3b(250,11,11))
    end)
    utils.RegClickEvent(self.BtnFemale,function() 
        self._curSelect = const.GENDER.FEMALE
        self.BtnMale:setTitleColor(cc.c3b(65,65,70))
        self.BtnFemale:setTitleColor(cc.c3b(250,11,11))
    end)
end

function clsSexSelectWnd:dtor()
	
end