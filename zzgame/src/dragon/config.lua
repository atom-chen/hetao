local DRAGON_CFG = {}

DRAGON_CFG.domain_list = {
    "https://www.wpub1dkjflsdakjfsdkgdfjsdfj.com",
    "https://www.wpub2dkjflsdakjfsdkgdfjsdfj.com",
    "https://www.wpub3dkjsadfsadfgklfjsdfj.com",
    "https://www.wpub5dkjsadsadfybboixm.com",
}

DRAGON_CFG.highdef_domain = "https://www.yikaiapi.com"

DRAGON_CFG.WS_ERROR_TBL = {
    [0] = "消息体格式错误",
    [1] = "token错误",
    [2] = "未登陆",
    [3] = "被禁言",
    [4] = "聊天室禁言",
    [10] = "发送内容包含违规字词",
    [11] = "VIP发言限制",
    [12] = "VIP每分钟发言限制",
    [13] = "VIP分享限制",
}

return DRAGON_CFG
