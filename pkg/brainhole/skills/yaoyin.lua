local yaoyin = fk.CreateSkill {
  name = "n_yaoyin",
  tags = { Skill.Limited, },
}



yaoyin:addEffect("active", {
  name = "n_yaoyin",
  anim_type = "control",
  card_num = 1,
  target_num = 1,
  card_filter = function(self, player, to_select, selected)
    return #selected == 0 and Fk:currentRoom():getCardArea(to_select) ~= Card.PlayerEquip
  end,
  target_filter = function(self, player, to_select, selected)
    return #selected == 0 and to_select ~= player and to_select:getNextAlive() ~= player
  end,
  can_use = function(self, player)
    return player:usedSkillTimes(yaoyin.name, Player.HistoryGame) == 0
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    local card = effect.cards[1]
    room:loseHp(player, 1, yaoyin.name)
    if player.dead then return end
    room:obtainCard(target, card, false, fk.ReasonGive)
    local prev = player:getLastAlive() --[[ @as ServerPlayer ]]
    room:swapSeat(prev, target)
    local card = Fk:cloneCard("analeptic")
    card.skillName = yaoyin.name
    local use = {}
    use.from = player
    use.tos = { player, target }
    use.card = card
    use.extraUse = true
    room:useCard(use)
  end,
})

return yaoyin