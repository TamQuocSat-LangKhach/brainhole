local dutian = fk.CreateSkill {
  name = "n_dutian",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["n_dutian"] = "度田",
  [":n_dutian"] = "锁定技，你获得牌后，记录获得的数量。当你使用点数为X的牌后，你摸两张牌并将记录数设为X+1（X为记录的数量）。",

  ["@n_dutian"] = "度田",
}

dutian:addEffect(fk.CardUsing, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(dutian.name) and
      data.card.number == player:getMark("@n_dutian")
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local x = player:getMark("@n_dutian")
    player:drawCards(2, dutian.name)
    room:setPlayerMark(player, "@n_dutian", x + 1)
  end,
})
dutian:addEffect(fk.AfterCardsMove, {
  can_refresh = function(self, event, target, player, data)
    return player:hasSkill(dutian.name)
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    local cards = {}
    for _, move in ipairs(data) do
      if move.to and move.to == player and move.toArea == Player.Hand then
        for _, info in ipairs(move.moveInfo) do
          table.insertIfNeed(cards, info.cardId)
        end
      end
    end
    if #cards == 0 then return end
    room:setPlayerMark(player, "@n_dutian", #cards)
  end,
})
return dutian