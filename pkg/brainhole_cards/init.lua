-- SPDX-License-Identifier: GPL-3.0-or-later

local extension_card = Package:new("brainhole_cards", Package.CardPack)
extension_card.extensionName = "brainhole"

extension_card:loadSkillSkelsByPath("./packages/brainhole/pkg/brainhole_cards/skills")

local brick = fk.CreateCard{
  name = "n_brick",
  type=Card.TypeBasic,
  is_damage_card = true,
  skill = "n_brick_skill",
  special_skills = { "recast" },
}
extension_card:addCardSpec( "n_brick",Card.Heart,6 )

local n_relx_v = fk.CreateCard{
  name = "&n_relx_v",
  sub_type = Card.SubtypeTreasure,
  type=Card.TypeEquip,
  equip_skill = "#n_relx_skill",
}
extension_card:addCardSpec("n_relx_v",Card.Spade,12)


extension_card:loadCardSkels {
  brick,
  n_relx_v,
}

return extension_card
