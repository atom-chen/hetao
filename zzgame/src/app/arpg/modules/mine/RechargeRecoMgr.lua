ClsRechargeRecoMgr = class("ClsRechargeRecoMgr",clsCoreObject)
ClsRechargeRecoMgr.__is_singleton = true

function ClsRechargeRecoMgr:ctor()
    clsCoreObject.ctor(self)
    self.RechargeRecord = {}
    self.RechargeDetail = {}
    self.RechargeDate = {}
    
    self.RechargeRecharge = {}
end

function ClsRechargeRecoMgr:SaveRechargeRecord(data)
    self.RechargeRecord = data
end

function ClsRechargeRecoMgr:GetRechargeRecord()
    return self.RechargeRecord
end

function ClsRechargeRecoMgr:SaveRechargeDetail(data)
    self.RechargeDetail = data
end

function ClsRechargeRecoMgr:GetRechargeDetail()
    return self.RechargeDetail
end

function ClsRechargeRecoMgr:SaveRechargeDate(data)
    self.RechargeDate = data
end

function ClsRechargeRecoMgr:GetRechargeDate()
    return self.RechargeDate
end

------------------- 充值流程 -----------------------------------
--[[
  / 内部网页 */
  public static final int JUMP_MODE_WEB_INNER = 1;
  / 银行卡转账 */
  public static final int JUMP_MODE_BANK = 2;
  / 公众号扫码 */
  public static final int JUMP_MODE_QRCODE_PUBLIC = 3;
  / 个人扫码 */
  public static final int JUMP_MODE_QRCODE_PERSONAL = 4;
  /** 外部网页 */
  public static final int JUMP_MODE_WEB_OUTER = 5;


1. type == bank 跳转银行卡支付
2. 4和2直接跳转。
3. 其它调用 /pay/pay/pay_do 支付接口再确定跳转。
]]
function ClsRechargeRecoMgr:SaveRechargeRecharge(data)
    self.RechargeRecharge = data
end

function ClsRechargeRecoMgr:GetRechargeRecharge()
    return self.RechargeRecharge
end