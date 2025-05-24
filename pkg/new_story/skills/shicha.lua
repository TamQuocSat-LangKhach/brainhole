local shicha = fk.CreateSkill {
  name = "n_shicha",
}

Fk:loadTranslationTable{
  ["n_shicha"] = "失察",
  [":n_shicha"] = "其他角色以你为唯一目标使用【杀】后，其可以展示牌堆顶的X张牌（X为你“狂乐”记录的花色数-2，且至少为0），"..
  "然后每有一张牌花色与“狂乐”记录的花色相同，令此【杀】伤害+1，且你不能使用“狂乐”记录花色的牌响应此【杀】。若如此做，"..
  "此【杀】结算结束后，清除“狂乐”记录的花色。",

  ["#n_shicha_invoke"] = "是否发动 %src 的技能“失察”，对其可能强中并可能加伤？",
}

shicha:addEffect(fk.TargetSpecified, {
  anim_type = "negative",
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(shicha.name) and data.card.trueName == "slash" and
      data:isOnlyTarget(player) and player:getMark("@[suits]n_kuangle") ~= 0
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
    room:setPlayerMark(player, shicha.name, 1)
    cardUseEvent:addExitFunc(function()
      room:setPlayerMark(player, shicha.name, 0)
      room:setPlayerMark(player, "@[suits]n_kuangle", 0)
    end)
    local suits = player:getMark("@[suits]n_kuangle")
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