ClsAgentDataMgr = class ("ClsAgentDataMgr",clsCoreObject)
ClsAgentDataMgr.__is_singleton = true

function ClsAgentDataMgr:ctor()
    clsCoreObject.ctor(self)
    ----- 1 代理报表  2 下级报表    3 投注明细  4 交易明细   5 会员管理(没有下级)   6 会员管理(有下级)
    self.nType = -1
    self.tInvite_code = {}
    self.memberdata = {}
    self.JuniorReprtDay = 0  --下级报表时间  0 今天   1 昨天   2 本月   3 上月
    self.nTrading_type = -1 --交易明细的种类  1  所有类型   2 提现记录  3 充值记录
    self.nBet_type = -1  --投注明细    0：全部，1：已中奖，2：和局，3：订单取消，4：待开奖，5：未中奖
    self.nBet_num = 0    --注单号
    self.sReportid = ""  --代理报表id
    self.sJuniorUid = ""  --下级报表uid
    self.tJuniorLevel = {} --用于存储上下级的id
    self.sBetUsername = ""  --投注明细username
    self.tRebate = {}
    self.tJuniorData = {}  --会员管理查看下级的信息
    self.sMemberid = ""  --会员管理is
    self.tAgentRepotTodayData = {} --下级报表 今天
    self.tAgentRepotYesterData = {} 
    self.tAgentRepotMonthData = {} 
    self.tAgentRepotLastMonthData = {}
    self.tAgetReportToday = {} --代理报表  今天
    self.tAgetReportYester = {}
    self.tAgetReportMonth = {}
    self.tAgetReportLastMonth = {}
    --代理中心投注明细
    self.tAgentBetDetail = {}
end

function ClsAgentDataMgr:SaveType(recvdata)
    self.nType = recvdata
end

function ClsAgentDataMgr:GetType()
    return self.nType
end

function ClsAgentDataMgr:SaveCode(recvdata)
    self.tInvite_code = recvdata
end

function ClsAgentDataMgr:GetCode()
    return self.tInvite_code
end

function ClsAgentDataMgr:SaveMemberdata(recvdata)
    self.memberdata = recvdata
end

function ClsAgentDataMgr:GetMemberdata()
    return self.memberdata
end

function ClsAgentDataMgr:SaveTradingType(recvdata)
    self.nTrading_type = recvdata
end

function ClsAgentDataMgr:GetTradingType()
    return self.nTrading_type
end

function ClsAgentDataMgr:SaveBetType(recvdata)
    self.nBet_type = recvdata
end

function ClsAgentDataMgr:GetBetType()
    return self.nBet_type
end

function ClsAgentDataMgr:SaveBetNum(recvdata)
    self.nBet_num = recvdata
end

function ClsAgentDataMgr:GetBetNum()
    return self.nBet_num
end

function ClsAgentDataMgr:SaveJuniorUid(recvdata)
    self.sJuniorUid = recvdata
end

function ClsAgentDataMgr:GetJuniorUid()
    return self.sJuniorUid
end

function ClsAgentDataMgr:SaveReportid(recvdata)
    self.sReportid = recvdata
end

function ClsAgentDataMgr:GetReportid()
    return self.sReportid
end

function ClsAgentDataMgr:SaveBetusername(recvdata)
    self.sBetUsername = recvdata
end

function ClsAgentDataMgr:GetBetusername()
    return self.sBetUsername
end

function ClsAgentDataMgr:SaveJuniorReportDay(recvdata)
    self.JuniorReprtDay = recvdata
end

function ClsAgentDataMgr:GetJuniorReportDay()
    return self.JuniorReprtDay
end

function ClsAgentDataMgr:SaveJuniorLevel(recvdata)
    self.tJuniorLevel = recvdata
end

function ClsAgentDataMgr:GetJuniorLevel()
    return self.tJuniorLevel
end

function ClsAgentDataMgr:SaveRebate(recvdata)
    self.tRebate = recvdata and recvdata.data and recvdata.data.self_rebate
    dump(self.tRebate)
end

function ClsAgentDataMgr:GetRebate()
    return self.tRebate
end

function ClsAgentDataMgr:SaveJuniorData(recvdata)
    self.tJuniorData = recvdata
end

function ClsAgentDataMgr:GetJuniorData()
  return self.tJuniorData
end

function ClsAgentDataMgr:SaveMemberid(recvdata)
    self.sMemberid = recvdata
end

function ClsAgentDataMgr:GetMemberid()
    return self.sMemberid
end

function ClsAgentDataMgr:SaveAgentRepotTodayData(recvdata)
    self.tAgentReportTodayData = recvdata
end

function ClsAgentDataMgr:GetAgentReportTodayData()
    return self.tAgentReportTodayData
end

function ClsAgentDataMgr:SaveAgentRepotYesterData(recvdata)
    self.tAgentRepotYesterData = recvdata
end

function ClsAgentDataMgr:GetAgentReportYesterData()
    return self.tAgentRepotYesterData
end

function ClsAgentDataMgr:SaveAgentRepotMonthData(recvdata)
    self.tAgentRepotMonthData = recvdata
end

function ClsAgentDataMgr:GetAgentRepotMonthData()
    return self.tAgentRepotMonthData
end

function ClsAgentDataMgr:SaveAgentRepotLastMonthData(recvdata)
    self.tAgentRepotLastMonthData = recvdata
end

function ClsAgentDataMgr:GetAgentRepotLastMonthData()
    return self.tAgentRepotLastMonthData
end

function ClsAgentDataMgr:SaveAgentReportToday(recvdata)
    self.tAgetReportToday = recvdata
end

function ClsAgentDataMgr:GetAgentReportToday()
    return self.tAgetReportToday
end

function ClsAgentDataMgr:SaveAgentReportYester(recvdata)
    self.tAgetReportYester = recvdata
end

function ClsAgentDataMgr:GetAgentReportYester()
    return self.tAgetReportYester
end

function ClsAgentDataMgr:SaveAgentReportMonth(recvdata)
    self.tAgetReportMonth = recvdata
end

function ClsAgentDataMgr:GetAgentReportMonth()
    return self.tAgetReportMonth
end

function ClsAgentDataMgr:SaveAgentReportLastMonth(recvdata)
    self.tAgetReportLastMonth = recvdata
end

function ClsAgentDataMgr:GetAgentReportLastMonth()
    return self.tAgetReportLastMonth
end

function ClsAgentDataMgr:SaveAgentBetDetail(recvdata)
    self.tAgentBetDetail = recvdata
end

function ClsAgentDataMgr:GetAgentBetDetail()
    return self.tAgentBetDetail
end