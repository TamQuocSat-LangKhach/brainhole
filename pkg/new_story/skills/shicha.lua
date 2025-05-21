local shicha = fk.CreateSkill {

  name = "n_shicha",

  tags = {  },

}



shicha:addEffect(fk.TargetSpecified, {
  name = "n_shicha",
  anim_type = "negative",
  mute = true,
  can_trigger = function(self, event, target, player, data)
    if not (target == player and data.card.trueName == "slash" and
      #data:getAllTargets()== 1) then p("111") return false end
    local room = player.room
    local to = data.to
    p("222")
    return to:hasSkill(shicha.name) and to:getMark("@[suits]n_kuangle") ~= 0
  end,
  on_cost = function(self, event, target, player, data)
      return player.room:askToSkillInvoke(player, {
        skill_name = shicha.name,
        data = nil,
        prompt = "#n_shicha_invoke:" .. data.to.id
      })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local logic = room.logic
    local cardUseEvent = logic:getCurrentEvent().parent
    local to = data.to
    to:broadcastSkillInvoke(shicha.name)
    room:notifySkillInvoked(to, shicha.name)
    room:setPlayerMark(to, shicha.name, 1)
    cardUseEvent:addExitFunc(function()
      room:setPlayerMark(to, shicha.name, 0)
      room:setPlayerMark(to, "@[suits]n_kuangle", 0)
    end)
    local suits = to:getMark("@[suits]n_kuangle")
    if suits == 0 or #suits <= 2 then return end
    local cards = room:getNCards(#suits - 2)
    room:moveCardTo(cards, Card.DiscardPile) 
    data.additionalDamage = (data.additionalDamage or 0) +
    #table.filter(cards, function(id)
      local c = Fk:getCardById(id)
      return table.contains(suits, c.suit)
    end)
  end,
})

shicha:addEffect("prohibit", {
  name = "#n_shicha_prohibit",
  prohibit_use = function(self, player, card)
    if Fk.currentResponsePattern ~= "jink" or card.name ~= "jink" then
      return false
    end
    if player:getMark("n_shicha") == 0 then return false end
    local suits = player:getMark("@[suits]n_kuangle")
    if suits == 0 then return false end
    if table.contains(suits, card.suit) then
      return true
    end
  end,
})

return shicha