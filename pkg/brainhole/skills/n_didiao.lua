local n_didiao = fk.CreateSkill {
  name = "n_didiao",
}

Fk:loadTranslationTable{
  ["n_didiao"] = "低调",
  [":n_didiao"] = "每当你使用锦囊牌后，你可以弃置一张牌，获得一枚“饺”标记。",

  ["#n_didiao-discard"] = "低调：你可以弃置一张牌，获得一枚“饺”",
  ["@n_jiao"] = "饺",
}

n_didiao:addEffect(fk.CardUsing, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(n_didiao.name) and data.card.type == Card.TypeTrick and
      not player:isNude()
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local card = room:askToDiscard(player, {
      min_num = 1,
      max_num = 1,
      include_equip = true,
      skill_name = n_didiao.name,
      prompt = "#n_didiao-discard",
      cancelable = true,
      skip = true,
    })
    if #card > 0 then
      event:setCostData(self, {cards = card})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:addPlayerMark(player, "@n_jiao", 1)
    room:throwCard(event:getCostData(self).cards, n_didiao.name, player, player)
  end,
})

return n_didiao