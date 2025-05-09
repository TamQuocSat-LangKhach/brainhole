local subian = fk.CreateSkill{
  name = "n_subian",
}

Fk:loadTranslationTable{
  ["n_subian"] = "速编",
  [":n_subian"] = "出牌阶段限一次，你可以获得一张手牌的复制牌。",
  ["#n_subian"] = "速编：获得一张手牌的复制",
}

subian:addEffect('active', {
  anim_type = "drawcard",
  card_num = 1,
  target_num = 0,
  prompt = function() return "#n_subian" end,
  card_filter = function(self, player, to_select, selected)
    return #selected == 0 and Fk:currentRoom():getCardArea(to_select) ~= Player.Equip
  end,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0 and not player:isKongcheng()
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

return subian
