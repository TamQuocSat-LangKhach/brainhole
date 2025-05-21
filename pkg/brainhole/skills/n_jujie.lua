local n_jujie = fk.CreateSkill {
  name = "n_jujie",
}



n_jujie:addEffect(fk.TargetConfirmed, {
  name = "n_jujie",
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    if not (target == player and player:hasSkill(n_jujie.name)) then return end
    if event == fk.TargetConfirmed then
      return data.from ~= player and data.card.is_damage_card
    else
      local e = player.room.logic:getCurrentEvent():findParent(GameEvent.UseCard)
      return (e and e.n_jujie_list or {})[player.id] ~= nil and data.from and
          data.from:getHandcardNum() > player:getHandcardNum()
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    if event == fk.TargetConfirmed then
      local ids = room:askForDiscard(player, 1, 1, true, n_jujie.name, true,
        ".", "#n_jujie_ask::" .. data.from.id .. ":" .. data.card.name, true)
      if #ids > 0 then
        event:setCostData(self, { cards = ids })
        return true
      end
    else
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if event == fk.TargetConfirmed then
      room:throwCard(event:getCostData(self).cards, n_jujie.name, player, player)
      local e = room.logic:getCurrentEvent():findParent(GameEvent.UseCard)
      e.n_jujie_list = e.n_jujie_list or {}
      e.n_jujie_list[player.id] = true
    else
      local from = data.from
      local a, b = player:getHandcardNum(), from:getHandcardNum()
      if a < b then
        room:askForDiscard(from, b - a, b - a, false, n_jujie.name, false)
      end
    end
  end,
})
n_jujie:addEffect(fk.Damaged, {
  name = "n_jujie",
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    if not (target == player and player:hasSkill(n_jujie.name)) then return end
    if event == fk.TargetConfirmed then
      return data.from ~= player.id and data.card.is_damage_card
    else
      local e = player.room.logic:getCurrentEvent():findParent(GameEvent.UseCard)
      return (e and e.n_jujie_list or {})[player.id] ~= nil and data.from and
          data.from:getHandcardNum() > player:getHandcardNum()
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    if event == fk.TargetConfirmed then
      local ids = room:askForDiscard(player, 1, 1, true, n_jujie.name, true,
        ".", "#n_jujie_ask::" .. data.from.id .. ":" .. data.card.name, true)
      if #ids > 0 then
        event:setCostData(self, { cards = ids })
        return true
      end
    else
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local from = data.from
    if from then
      local a, b = player:getHandcardNum(), from:getHandcardNum()
      if a < b then
        room:askForDiscard(from, b - a, b - a, false, n_jujie.name, false)
      end
    end
  end,
})

return n_jujie
