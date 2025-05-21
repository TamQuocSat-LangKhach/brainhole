local n_didiao = fk.CreateSkill {
  name = "n_didiao",
}



n_didiao:addEffect(fk.CardUsing, {
  name = "n_didiao",
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(n_didiao.name) and data.card.type == Card.TypeTrick and
      not player:isNude()
  end,
  on_cost = function(self, event, target, player, data)
    local c = player.room:askForDiscard(player, 1, 1, true, n_didiao.name, true, ".", "#n_didiao-discard", true)
    if c[1] then
      event:setCostData(self, c[1])
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:throwCard(event:getCostData(self), n_didiao.name, player, player)
    room:addPlayerMark(player, "@n_jiao", 1)
  end,
})

return n_didiao