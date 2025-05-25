local extension = Package:new("new_story")
extension.extensionName = "brainhole"

extension:loadSkillSkelsByPath("./packages/brainhole/pkg/new_story/skills")

Fk:loadTranslationTable{
  ["brainhole_new_story"] = "脑洞-新的故事",
  ["new_story"] = "新的故事",

  ["nd_story"] = "新的故事",
  ["n_jz"] = "互联网六艺",
}

General:new(extension, "nd_story__pengtuo", "qun", 3):addSkills { "n_fuji", "n_poulian" }
Fk:loadTranslationTable{
  ["nd_story__pengtuo"] = "彭脱",
  ["designer:nd_story__pengtuo"] = "notify",
}

General:new(extension, "nd_story__zhonglimu", "wu", 3):addSkills { "n_dutian", "n_fuyi" }
Fk:loadTranslationTable{
  ["nd_story__zhonglimu"] = "钟离牧",
  ["designer:nd_story__zhonglimu"] = "notify",
}

General:new(extension, "nd_story__huangjinfashi", "qun", 3, 3, General.Female):addSkills { "n_leiji", "n_hunfu" }
Fk:loadTranslationTable{
  ["nd_story__huangjinfashi"] = "黄巾法师",
  ["designer:nd_story__huangjinfashi"] = "notify",
  ["cv:nd_story__huangjinfashi"] = "北月畫仙",
  ["~nd_story__huangjinfashi"] = "飞尘塞眼，苍生泪、犹似平时……",
}

General:new(extension, "n_guoxiu", "wei", 4):addSkills { "n_cizhi" }
Fk:loadTranslationTable{
  ["n_guoxiu"] = "郭修",
  ["designer:n_guoxiu"] = "notify",
}

local n_wanghou = General:new(extension, "n_wanghou", "wei", 3)
n_wanghou:addSkills { "n_jianliang", "n_anjun" }
n_wanghou:addRelatedSkills { "n_fenliang" }
Fk:loadTranslationTable{
  ["n_wanghou"] = "王垕",
  ["designer:n_wanghou"] = "notify",
}

General:new(extension, "n_jiequan", "wu", 4):addSkills { "n_huiwan", "n_jiequanisbest" }
Fk:loadTranslationTable{
  ["n_jiequan"] = "界权",
  ["designer:n_jiequan"] = "notify",
  ["~n_jiequan"] = "父兄大计，权，实憾矣。",
}

General:new(extension, "n_pujing", "qun", 3):addSkills { "n_huayuan", "n_yunyou" }
Fk:loadTranslationTable{
  ["n_pujing"] = "普净",
  ["designer:n_pujing"] = "notify",
}

General:new(extension, "n_guanning", "qun", 3, 7):addSkills { "n_dunshi" }
Fk:loadTranslationTable{
  ["n_guanning"] = "菅宁",
  ["designer:n_guanning"] = "RalphR",
  ["~n_guanning"] = "近城远山，皆是人间。",
}

General:new(extension, "n_jz__caocao", "wei", 4):addSkills { "ex__jianxiong", "n_dianlun" }
Fk:loadTranslationTable{
  ["n_jz__caocao"] = "典曹操",
  ["designer:n_jz__caocao"] = "notify",
}

General:new(extension, "n_jz__xuchu", "wei", 4):addSkills { "n_luoyi", "n_jizhan" }
Fk:loadTranslationTable{
  ["n_jz__xuchu"] = "急许褚",
  ["designer:n_jz__xuchu"] = "notify",
  ["~n_jz__xuchu"] = "我还能…接着打…",
}

General:new(extension, "n_jz__lvbu", "qun", 4):addSkills { "wushuang", "n_yixiao", "n_panshi" }
Fk:loadTranslationTable{
  ["n_jz__lvbu"] = "孝吕布",
  ["designer:n_jz__lvbu"] = "notify",
  ["~n_jz__lvbu"] = "刘备！奸贼！汝乃天下最无信义之人！",
}

General:new(extension, "n_jz__weiyan", "shu", 4):addSkills { "n_kuangle", "n_shicha", "kuanggu" }
Fk:loadTranslationTable{
  ["n_jz__weiyan"] = "乐魏延",
  ["designer:n_jz__weiyan"] = "notify",
}

local sunquan = General:new(extension, "n_jz__sunquan", "wu", 3, 10)
sunquan:addSkills { "n_yingfa", "n_shiwan", "ex__zhiheng" }
sunquan:addRelatedSkills { "tycl__zhiheng", "n_huiwan" }
Fk:loadTranslationTable{
  ["n_jz__sunquan"] = "赢孙权",
  ["designer:n_jz__sunquan"] = "notify",
}

General:new(extension, "n_jz__huatuo", "qun", 3):addSkills { "n_mafei", "n_jijiu" }
Fk:loadTranslationTable{
  ["n_jz__huatuo"] = "麻华佗",
  ["designer:n_jz__huatuo"] = "notify",
  ["illustrator:n_jz__huatuo"] = "黑羽",
}

local zhouyu = General:new(extension, "q_zhouyu", "wu", 3)
zhouyu.total_hidden = true
zhouyu:addSkills { "yingzi", "fanjian" }

local machao = General:new(extension, "q_machao", "shu", 4)
machao.total_hidden = true
machao:addSkills { "mashu", "tieqi" }

local sunshangxiang = General:new(extension, "q_sunshangxiang", "wu", 3, 3, General.Female)
sunshangxiang.total_hidden = true
sunshangxiang:addSkills { "xiaoji", "jieyin" }

local daqiao = General:new(extension, "q_daqiao", "wu", 3, 3, General.Female)
daqiao.total_hidden = true
daqiao:addSkills { "guose", "liuli" }

local xiaoqiao = General:new(extension, "q_xiaoqiao", "wu", 3, 3, General.Female)
xiaoqiao.total_hidden = true
xiaoqiao:addSkills { "tianxiang", "hongyan" }

local luxun = General:new(extension, "q_luxun", "wu", 3)
luxun.total_hidden = true
luxun:addSkills { "qianxun", "lianying" }

local huangyueying = General:new(extension, "q_huangyueying", "shu", 3, 3, General.Female)
huangyueying.total_hidden = true
huangyueying:addSkills { "jizhi", "qicai" }

local spsunshangxian = General:new(extension, "q_spsunshangxiang", "shu", 3, 3, General.Female)
spsunshangxian.total_hidden = true
spsunshangxian:addSkills { "liangzhu", "fanxiang" }

local bulianshi = General:new(extension, "q_bulianshi", "wu", 3, 3, General.Female)
bulianshi.total_hidden = true
bulianshi:addSkills { "anxu", "zhuiyi" }

local zhangchunhua = General:new(extension, "q_zhangchunhua", "wei", 3, 3, General.Female)
zhangchunhua.total_hidden = true
zhangchunhua:addSkills { "jueqing", "shangshi" }

local madai = General:new(extension, "q_madai", "shu", 4)
madai.total_hidden = true
madai:addSkills { "mashu", "nos__qianxi" }

local wangyi = General:new(extension, "q_wangyi", "wei", 3, 3, General.Female)
wangyi.total_hidden = true
wangyi:addSkills { "nos__zhenlie", "nos__miji" }

local guanyinping = General:new(extension, "q_guanyinping", "shu", 3, 3, General.Female)
guanyinping.total_hidden = true
guanyinping:addSkills { "xuehen", "huxiao", "wuji" }

local liru = General:new(extension, "q_liru", "qun", 3)
liru.total_hidden = true
liru:addSkills { "ol_ex__juece", "ol_ex__mieji", "fencheng" }

local caiwenji = General:new(extension, "q_caiwenji", "qun", 3, 3, General.Female)
caiwenji.total_hidden = true
caiwenji:addSkills { "beige", "duanchang" }

local spdiaochan = General:new(extension, "q_spdiaochan", "qun", 3, 3, General.Female)
spdiaochan.total_hidden = true
spdiaochan:addSkills { "lihun", "biyue" }

local fuhuanghou = General:new(extension, "q_fuhuanghou", "qun", 3, 3, General.Female)
fuhuanghou.total_hidden = true
fuhuanghou:addSkills { "zhuikong", "qiuyuan" }

Fk:loadTranslationTable{
  ["q_zhouyu"] = "Q周瑜",
  ["q_machao"] = "Q马超",
  ["q_sunshangxiang"] = "Q香香",
  ["q_daqiao"] = "Q大乔",
  ["q_xiaoqiao"] = "Q小乔",
  ["q_luxun"] = "Q陆逊",
  ["q_huangyueying"] = "Q月英",
  ["q_spsunshangxiang"] = "Q蜀香",
  ["q_bulianshi"] = "Q步步",
  ["q_zhangchunhua"] = "Q春哥",
  ["q_madai"] = "Q马岱",
  ["q_wangyi"] = "Q王异",
  ["q_guanyinping"] = "Q银屏",
  ["q_liru"] = "Q李儒",
  ["q_caiwenji"] = "Q文姬",
  ["q_spdiaochan"] = "Q貂蝉",
  ["q_fuhuanghou"] = "Q伏后",
}

return extension
