local kuli = fk.CreateSkill {
  name = "n_kuli",
  tags = { Skill.Compulsory, },
}

Fk:loadTranslationTable{
  ["n_kuli"] = "苦力",
  [":n_kuli"] = "锁定技，当牌进入你的装备区后，你每缺少某种类别的空置装备栏，便获得一个额外的对应类别的装备栏并摸两张牌。<br>"..
  "<font color=>注：UI未适配多装备栏，需要等待游戏软件版本更新，请勿反馈显示问题。</font>",
}

local equip_subtypes = {
  Card.SubtypeWeapon,
  Card.SubtypeArmor,
  Card.SubtypeDefensiveRide,
  Card.SubtypeOffensiveRide,
  Card.SubtypeTreasure
}

kuli:addEffect(fk.AfterCardsMove, {
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