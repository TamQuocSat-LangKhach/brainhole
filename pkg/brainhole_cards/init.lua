-- SPDX-License-Identifier: GPL-3.0-or-later

local extension_card = Package:new("brainhole_cards", Package.CardPack)
extension_card.extensionName = "brainhole"

extension_card:loadSkillSkelsByPath("./packages/brainhole/pkg/brainhole_cards/skills")

Fk:loadTranslationTable{
  ["brainhole_cards"] = "脑洞包卡牌",
}

local brick = fk.CreateCard{
  name = "n_brick",
  type=Card.TypeBasic,
  is_damage_card = true,
  skill = "n_brick_skill",
  special_skills = { "recast" },
}
extension_card:addCardSpec( "n_brick", Card.Heart, 6 )
Fk:loadTranslationTable{
  ["n_brick"] = "砖",
  [":n_brick"] = "基本牌<br/>"..
  "<b>时机</b>：出牌阶段<br/>"..
  "<b>目标</b>：攻击范围内的一名其他角色<br/>"..
  "<b>效果</b>：交给其此牌，对目标角色造成1点伤害，然后本轮不能再使用【砖】。",

  ["n_brick_skill"] = "砖",
  ["#n_brick_skill"] = "将【砖】交给攻击范围内一名角色，并对其造成1点伤害",
}

local n_relx_v = fk.CreateCard{
  name = "&n_relx_v",
  sub_type = Card.SubtypeTreasure,
  type=Card.TypeEquip,
  equip_skill = "#n_relx_skill",
}
extension_card:addCardSpec("n_relx_v", Card.Spade, 12)
Fk:loadTranslationTable{
  ["n_relx_v"] = "悦刻五",
  [":n_relx_v"] = "装备牌·宝物<br/>"..
  "<b>宝物技能</b>：锁定技，当你使用非装备牌指定目标后，若你没有红色基本牌，你摸X张牌，然后若X>1，你对自己造成1点雷电伤害"..
  "（X为此牌指定的目标数）。<br/>"..
  "<font color=><small>都什么年代了还在抽传统焉？</small></font>",

  ["#n_relx_skill"] = "悦刻五",
}

extension_card:loadCardSkels {
  brick,
  n_relx_v,
}

return extension_card
