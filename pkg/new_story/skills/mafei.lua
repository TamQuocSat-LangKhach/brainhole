local mafei = fk.CreateSkill {

  name = "n_mafei",

  tags = {  },

}



mafei:addEffect("active", {
  name = "n_mafei",
  anim_type = "support",
  prompt = "#n_mafei-active",
  card_num = 1,
  card_filter =function (self, player, to_select, selected)
        return #selected == 0 and Fk:getCardById(to_select).color == Card.Red and
      Fk:currentRoom():getCardArea(to_select) == Player.Hand and
      not player:prohibitDiscard(Fk:getCardById(to_select))
  end,
  target_num = 1,
  target_filter =function (self, player, to_select, selected, selected_cards)
     return #selected == 0 and to_select:isWounded()
      and player:canUseTo(Fk:cloneCard("peach"), to_select)
  end,
  on_use = function (self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    room:throwCard(effect.cards, mafei.name, player)
    if player.dead or not target:isWounded() then return end
    room:useVirtualCard("peach", nil, player, target, mafei.name, true)
  end
})

mafei:addEffect(fk.CardUsing, {
  name = "#n_mafei_trigger",
  --mafei,
  mute = true,
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(mafei.name) and data.card.trueName == "peach"
      and player:getMark("n_mafei-turn") == 0
      and table.find(data.tos, function(pid) return pid ~= player end)
  end,
  on_cost = function (self, event, target, player, data)
   
    if  player.room:askToSkillInvoke(player,{
      skill_name=mafei.name,
      data=data,
      prompt="#n_mafei-invoke::"..data.tos[1].id
    }) then
      event:setCostData(self, { tos = data.tos })
      return true
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    room:notifySkillInvoked(player, mafei.name, "special")
    player:broadcastSkillInvoke(mafei.name)
    room:addPlayerMark(player, "n_mafei-turn")
    for _, pid in ipairs(data.tos) do
      if pid ~= player then
        local p = pid
        local record = room:getTag("n_mafei_rest") or {}
        table.insert(record, pid)
        room:setTag("n_mafei_rest", record)
        room:killPlayer({ who = p })
      end
    end
    if player:isAlive() then
      local cards = room:getCardsFromPileByRule(".|.|heart,diamond", 1)
      if #cards > 0 then
        room:obtainCard(player, cards[1], false, fk.ReasonJustMove, player, mafei.name)
      end
    end
  end,
})
mafei:addEffect(fk.BeforeGameOverJudge, {
  name = "#n_mafei_trigger",
  --mafei,
  mute = true,
  can_refresh = function (self, event, target, player, data)
    return table.contains(player.room:getTag("n_mafei_rest") or {}, target)
  end,
  on_refresh = function (self, event, target, player, data)
    target._splayer:setDied(false)
    local room = player.room
    local record = room:getTag("n_mafei_rest") or {}
    table.removeOne(record, target)
    room:setTag("n_mafei_rest", record)
    room:setPlayerRest(target, 1)
  end
})
return mafei