--------------------
-- 管理器
--------------------
ClsPlayerInfoMgr = class("ClsPlayerInfoMgr", clsCoreObject)

function ClsPlayerInfoMgr:ctor()
	clsCoreObject.ctor(self)
    self._tPlayerInfo = {}
end

function ClsPlayerInfoMgr:dtor()

end

function ClsPlayerInfoMgr:SavePlayerInfoData(Uid, Type, data)
    self._tPlayerInfo[Uid] = data
end

function ClsPlayerInfoMgr:GetPlayerInfoData(Uid, Type)
    return self._tPlayerInfo[Uid]
end