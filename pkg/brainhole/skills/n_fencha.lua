local n_fencha = fk.CreateSkill {
  name = "n_fencha",
  tags = { Skill.Limited, },
}



n_fencha:addEffect("active", {
  name = "n_fencha",
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
    local to = effect.tos[1]
    local moves = {}
    local handcards = to:getCardIds("h")
    if #handcards > 0 then
      table.shuffle(handcards)
      table.insert(moves, {
        ids = handcards,
        from = to,
        toArea = Card.DrawPile,
        moveReason = fk.ReasonExchange,
        proposer = player,
      })
    end
    local n = #room.draw_pile % 10
    if n > 0 then
      table.insert(moves, {
        ids = room:getNCards(n),
        to = to,
        toArea = Card.PlayerHand,
        moveReason = fk.ReasonExchange,
        proposer = player,
      })
    end
    if #moves > 0 then
      room:moveCards(table.unpack(moves))
    end
  end,
})

return n_fencha