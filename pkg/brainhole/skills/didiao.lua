local didiao = fk.CreateSkill{
  name = "n_didiao",
}

Fk:loadTranslationTable{
  ["n_didiao"] = "低调",
  [":n_didiao"] = "每当你使用锦囊牌后，你可以弃置一张牌，获得一枚“饺”标记。",
  ["#n_didiao-discard"] = "低调：你可以弃置一张牌，获得一枚“饺”",
  ["@n_jiao"] = "饺",
}

didiao:addEffect(fk.CardUsing, {
  anim_type = "drawcard",
  events = {fk.CardUsing},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and data.card.type == Card.TypeTrick and
      not player:isNude()
  end,
  on_cost = function(self, event, target, player, data)
    local c = player.room:askForDiscard(player, 1, 1, true, self.name, true, ".", "#n_didiao-discard", true)
    if c[1] then
      self.cost_data = c[1]
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:throwCard(self.cost_data, self.name, player, player)
    room:addPlayerMark(player, "@n_jiao", 1)
  end,
})

return didiao
