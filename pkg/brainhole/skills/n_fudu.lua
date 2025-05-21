local n_fudu = fk.CreateSkill {
  name = "n_fudu",
}



n_fudu:addEffect(fk.CardUseFinished, {
  name = "n_fudu",
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(n_fudu.name) then return end
    if player:isKongcheng() then return end
    local use = data 
    local card = use.card
    if not (use.from ~= player and use.tos and (not card:isVirtual()) and (card.type == Card.TypeBasic or card:isCommonTrick())) then
      return
    end
    local tos = data.tos
    if #table.filter(player.room.alive_players, function(p) return table.contains(tos, p) end) ~= 1 then return end
    local room = player.room
    local target = use.tos[1] == player and use.from or use.tos[1]
    if target.dead then
      return
    end
    return player:canUseTo(card, target, { bypass_times = true, bypass_distances = true })
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local use = data 
    local target = use.tos[1] == player and use.from or use.tos[1]
    local ids = table.filter(player:getCardIds(Player.Hand), function(id)
      return use.card:compareColorWith(Fk:getCardById(id))
    end)
    local c = room:askForCard(player, 1, 1, false, n_fudu.name, true,
      tostring(Exppattern{ id = ids }),
      "@n_fudu::" .. target.id .. ":" .. use.card.name .. ":" .. use.card:getColorString())[1]
    if c then
      event:setCostData(self, c)
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local use = {}
    use.from = player
    use.tos = data.tos[1] == player
      and { data.from }
      or table.simpleClone(data.tos)
    local card = Fk:cloneCard(data.card.name)
    card:addSubcard(event:getCostData(self))
    card.skillName = n_fudu.name
    use.card = card
    use.extraUse = true
    room:useCard(use)
  end,
})

return n_fudu