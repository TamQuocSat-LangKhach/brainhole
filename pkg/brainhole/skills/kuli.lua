local kuli = fk.CreateSkill {
  name = "n_kuli",
  tags = { Skill.Compulsory, },
}

local equip_subtypes = {
  Card.SubtypeWeapon,
  Card.SubtypeArmor,
  Card.SubtypeDefensiveRide,
  Card.SubtypeOffensiveRide,
  Card.SubtypeTreasure
}

kuli:addEffect(fk.AfterCardsMove, {
  name = "n_kuli",
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(kuli.name) then return end
    for _, move in ipairs(data) do
      if move.to == player and move.toArea == Card.PlayerEquip then
        for _, st in ipairs(equip_subtypes) do
          if not player:hasEmptyEquipSlot(st) then
            return true
          end
        end
        return false
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    for _, st in ipairs(equip_subtypes) do
      if not player:hasEmptyEquipSlot(st) then
        room:addPlayerEquipSlots(player, Util.convertSubtypeAndEquipSlot(st))
        if player:isAlive() then player:drawCards(2, kuli.name) end
      end
    end
  end,
})

return kuli