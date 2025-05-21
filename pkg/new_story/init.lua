local extension = Package:new("new_story")
extension.extensionName = "brainhole"

extension:loadSkillSkelsByPath("./packages/brainhole/pkg/new_story/skills")

dofile("packages/brainhole/pkg/new_story/trans.lua")
local pengtuo = General:new(extension, "nd_story__pengtuo", "qun", 3)
pengtuo:addSkills { "n_fuji", "n_poulian" }

local zhonglimu = General:new(extension, "nd_story__zhonglimu", "wu", 3)
zhonglimu:addSkills { "n_dutian", "n_fuyi" }

local huangjinfashi = General:new(extension, "nd_story__huangjinfashi", "qun", 3, 3, General.Female)
huangjinfashi:addSkills { "n_leiji", "n_hunfu" }

local n_guoxiu = General:new(extension, "n_guoxiu", "wei", 4)
n_guoxiu:addSkills { "n_cizhi" }

local n_wanghou = General:new(extension, "n_wanghou", "wei", 3)
n_wanghou:addSkills { "n_jianliang", "n_anjun" }
n_wanghou:addRelatedSkills { "n_fenliang" }

local n_jiequan = General:new(extension, "n_jiequan", "wu", 4)
n_jiequan:addSkills { "n_huiwan", "n_jiequanisbest" }

local zhushixing = General:new(extension, "n_pujing", "qun", 3)
zhushixing:addSkills { "n_huayuan", "n_yunyou" }

local guanning = General:new(extension, "n_guanning", "qun", 3, 7)
guanning:addSkills { "n_dunshi" }
guanning:addRelatedSkills { "n_yingma" }

local caocao = General:new(extension, "n_jz__caocao", "wei", 4)
caocao:addSkills { "n_jianxiong", "n_dianlun" }

local xuchu = General:new(extension, "n_jz__xuchu", "wei", 4)
xuchu:addSkills { "n_luoyi", "n_jizhan" }

local lvbu = General:new(extension, "n_jz__lvbu", "qun", 4)
lvbu:addSkills { "wushuang", "n_yixiao", "n_panshi" }

local weiyan = General:new(extension, "n_jz__weiyan", "shu", 4)
weiyan:addSkills { "n_kuangle", "n_shicha", "kuanggu" }

local sunquan = General:new(extension, "n_jz__sunquan", "wu", 3, 10)
sunquan:addSkills { "n_yingfa", "n_shiwan", "ex__zhiheng" }
sunquan:addRelatedSkills { "tycl__zhiheng", "n_huiwan" }

local huatuo = General:new(extension, "n_jz__huatuo", "qun", 3)
huatuo:addSkills { "n_mafei", "n_jijiu" }

return extension
