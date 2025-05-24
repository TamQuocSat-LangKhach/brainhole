local n_fencha = fk.CreateSkill {
  name = "n_fencha",
  tags = { Skill.Limited, },
}

Fk:loadTranslationTable{
  ["n_fencha"] = "分叉",
  [":n_fencha"] = "限定技，出牌阶段，若你已受伤，你可以将一名角色的所有手牌与牌堆顶X张牌交换（X为牌堆牌数的个位数）。",
}

n_fencha:addEffect("active", {
  card_num = 0,
  target_num = 1,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected)
    return #selected == 0
  end,
  can_use = function(self, player)
    return player:usedSkillTimes(n_fencha.name, Player.HistoryGame) == 0 and player:isWounded()
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    if target:isKongcheng() and #room.draw_pile % 10 then return end
    local cards1 = target:getCardIds("h")
    table.shuffle(cards1)
    room:swapCardsWithPile(target, cards1, room:getNCards(room.draw_pile % 10), n_fencha.name, "Top", false, player)
  end,
})

return n_fencha