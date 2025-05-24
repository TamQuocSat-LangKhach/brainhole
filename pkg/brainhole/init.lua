local extension = Package:new("brainhole")

extension.extensionName = "brainhole"

extension:loadSkillSkelsByPath("./packages/brainhole/pkg/brainhole/skills")

Fk:loadTranslationTable{
  ["brainhole"] = "脑洞包",
  ["n_pigeon"] = "鸽",
}

General(extension, "n_zy", "n_pigeon", 3):addSkills { "n_juanlao", "n_yegeng" }
Fk:loadTranslationTable{
  ["n_zy"] = "ＺＹ",
  ["designer:n_zy"] = "notify",
}

General(extension, "n_wch", "n_pigeon", 3):addSkills { "n_didiao", "n_shenjiao" }
Fk:loadTranslationTable{
  ["n_wch"] = "饺神",
  ["designer:n_wch"] = "Notify",
  ["illustrator:n_wch"] = "来自网络",
}

General(extension, "n_qunlingdao", "n_pigeon", 3):addSkills { "n_lingxiu", "n_qunzhi" }
Fk:loadTranslationTable{
  ["n_qunlingdao"] = "群领导",
  ["~n_qunlingdao"] = "我还会继续看群的...",
  ["designer:n_qunlingdao"] = "notify",
}

General(extension, "n_hospair", "n_pigeon", 3, 3, General.Female):addSkills { "n_fudu", "n_mingzhe" }
Fk:loadTranslationTable{
  ["n_hospair"] = "惑神",
  ["designer:n_hospair"] = "Notify",
  ["illustrator:n_hospair"] = "来自网络",
}

General(extension, "n_xxyheaven", "n_pigeon", 3, 3, General.Female)
  :addSkills { "n_kaoda", "n_chonggou", "n_kuiping" }
Fk:loadTranslationTable{
  ["n_xxyheaven"] = "心变",
  ["designer:n_xxyheaven"] = "notify",
}

local youmukon = General:new(extension, "n_youmukon", "n_pigeon", 3, 3, General.Female)
youmukon.trueName = "th_youmu"
youmukon:addSkills { "n_yaodao", "n_huanmeng" }
Fk:loadTranslationTable{
  ["n_youmukon"] = "妖梦厨",
  ["designer:n_youmukon"] = "妖梦厨",
  ["~n_youmukon"] = "（Biu~）",
  ["!n_youmukon"] = "（Spell Card Bonus!）",
}

local emoprincess = General(extension, "n_emoprincess", "n_pigeon", 3, 3, General.Female)
emoprincess.trueName = "emoprincess"
emoprincess:addSkills { "n_leimu", "n_xiaogeng", "n_fencha" }
Fk:loadTranslationTable{
  ["n_emoprincess"] = "emo",
  ["designer:n_emoprincess"] = "emo",
}

General(extension, "n_daotuwang", "n_pigeon", 3):addSkills { "n_daotu" }
Fk:loadTranslationTable{
  ["n_daotuwang"] = "盗图王",
  ["designer:n_daotuwang"] = "Notify",
  ["~n_daotuwang"] = "盗图王，你.....",
  ["illustrator:n_daotuwang"] = "网络",
  ["#n_daotuwang"] = "人畜无害",
}

local nyutan = General(extension, "n_nyutan", "n_pigeon", 3)
nyutan.gender = General.Female
nyutan:addCompanions{ "os__niujin", "niufu" }
nyutan:addSkills { "n_tuguo", "n_niuzhi" }
Fk:loadTranslationTable{
  ["n_nyutan"] = "Nyutan_",
  ["designer:n_nyutan"] = "notify",
}

local ralph = General(extension, "n_ralph", "n_pigeon", 3)
ralph.gender = General.Female
ralph.trueName = "th_kogasa"
ralph:addSkills { "n_subian", "n_rigeng", "n_fanxiu" }
Fk:loadTranslationTable{
  ["n_ralph"] = "Ｒ神",
  ["designer:n_ralph"] = "notify",
}

General(extension, "n_0t", "n_pigeon", 3, 3, General.Female):addSkills { "n_cejin", "n_yinghui" }
Fk:loadTranslationTable{
  ["n_0t"] = "聆听",
  ["designer:n_0t"] = "notify",
}

General(extension, "n_notify", "n_pigeon", 3):addSkills { "n_biancheng", "n_tiaoshi", "n_baogan" }
Fk:loadTranslationTable{
  ["n_notify"] = "Notify_",
  ["designer:n_notify"] = "notify",
}

General(extension, "n_mabaoguo", "qun", 4):addSkills { "n_hunyuan", "n_lianbian"}
Fk:loadTranslationTable{
  ["n_mabaoguo"] = "马保国",
  ["designer:n_mabaoguo"] = "notify",
  ["~n_mabaoguo"] = "这两个年轻人不讲武德，来，骗！来，偷袭！我六十九岁的老同志，这好吗这不好。",
}

General(extension, "n_xujiale", "qun", 4):addSkills { "n_pengji", "n_songji"}
Fk:loadTranslationTable{
  ["n_xujiale"] = "徐嘉乐",
  ["~n_xujiale"] = "最后一次啊，注意看啊",
  ["#n_xujiale"] = "厨邦大师",
  ["designer:n_xujiale"] = "穈穈哒的招来",
  ["cv:n_xujiale"] = "徐嘉乐",
  ["illustrator:n_xujiale"] = "视频截图",
}

General(extension, "n_jiege", "qun", 4):addSkills { "n_yaoyin", "n_kangkang"}
Fk:loadTranslationTable{
  ["n_jiege"] = "杰哥",
  ["#n_jiege"] = "转大人指导",
  ["designer:n_jiege"] = "zyc12241252",
  ["illustrator:n_jiege"] = "网络",
  ["~n_jiege"] = "阿玮…你要干嘛…对不起…",
}

General(extension, "n_awei", "qun", 3):addSkills { "n_suijie", "n_jujie"}
Fk:loadTranslationTable{
  ["n_awei"] = "阿玮",
  ["#n_awei"] = "在杰难逃",
  ["designer:n_awei"] = "Notify",
  ["illustrator:n_awei"] = "网络",
  ["~n_awei"] = "透，死了啦，都是你害的啦，拜托！",
}

General(extension, "n_dingzhen", "qun", 4):addSkills { "n_yangwu", "n_chunzhen"}
Fk:loadTranslationTable{
  ["n_dingzhen"] = "丁真",
}

General(extension, "n_guojicheng", "qun", 3):addSkills { "n_chiyao", "n_rulai"}
Fk:loadTranslationTable{
  ["n_guojicheng"] = "郭继承",
  ["~n_guojicheng"] = "你怎么可以骂老师…",
}

General(extension, "n_shaheshang", "god", 3):addSkills { "n_liusha", "n_kuli"}
Fk:loadTranslationTable{
  ["n_shaheshang"] = "沙和尚",
  ["#n_shaheshang"] = "任劳任怨",
  ["designer:n_shaheshang"] = "西游杀",
  ["illustrator:n_shaheshang"] = "",
}

return extension
