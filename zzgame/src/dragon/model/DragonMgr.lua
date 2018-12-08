-------------------------
-- 管理器
-------------------------
local json = require("kernel.framework.json")
local crypto = require("kernel.framework.crypto")


local ClsDragonMgr = class("ClsDragonMgr", clsCoreObject)
ClsDragonMgr.__is_singleton = true

function ClsDragonMgr:ctor()
	clsCoreObject.ctor(self)
	self._domain_lsit = {}
end

function ClsDragonMgr:dtor()

end

function ClsDragonMgr:req_domain_list()
	local DRAGON_CFG = require("dragon.config")
	for _, domain in ipairs(DRAGON_CFG.domain_list) do
		HttpUtil:callXhrGet({}, domain, "", nil, cc.XMLHTTPREQUEST_RESPONSE_STRING, function(bIsError, resp_data, tArgs, assist_info)
			local recvdata = resp_data and json.decode(resp_data)
			local data = recvdata and recvdata.data 
			if type(data) == "table" then
				for _, domainAddr in ipairs(data) do
					table.insert( self._domain_lsit, domainAddr )
				end
			end
			dump(self._domain_lsit)
		end)
	end
end

function ClsDragonMgr:GetDomainList()
    return self._domain_lsit
end

return ClsDragonMgr
