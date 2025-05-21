local n_subian = fk.CreateSkill {
  name = "n_subian",
}



n_subian:addEffect("active", {
  name = "n_subian",
  anim_type = "drawcard",
  card_num = 1,
  target_num = 0,
  prompt = function() return "#n_subian" end,
  card_filter = function(self, player, to_select, selected)
    return #selected == 0 and Fk:currentRoom():getCardArea(to_select) ~= Player.Equip
  end,
  can_use = function(self, player)
    return player:usedSkillTimes(n_subian.name, Player.HistoryPhase) == 0 and not player:isKongcheng()
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local card = Fk:getCardById(effect.cards[1])
    local toGain = room:printCard(card.name, card.suit, card.number)
    room:obtainCard(player, toGain, true, fk.ReasonPrey)
    -- room:setCardMark(toGain, "@@n_subian", 1)
    room:addTableMark(player, "n_subian-turn", toGain.id)
  end,
})

return n_subian