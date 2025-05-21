local yangwu = fk.CreateSkill {
  name = "n_yangwu",
  tags = { Skill.Compulsory, },
}

local relx = { {"n_relx_v", Card.Spade, 12} }

yangwu:addEffect(fk.GamePrepared, {
  name = "n_yangwu",
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(yangwu.name) then
      return event == fk.GamePrepared or
        (target == player and player.phase == Player.Start)
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local treasure = player:getEquipment(Card.SubtypeTreasure)
    if not treasure or Fk:getCardById(treasure).name ~= "n_relx_v" then
      local id = U.prepareDeriveCards(player.room, relx, "yangwu_derivedcards")[1]
      local owner = room:getCardOwner(id) --[[ @as ServerPlayer ]]
      room:obtainCard(player, id, false, fk.ReasonPrey)
      if owner and owner ~= player and not owner.dead then
        room:damage { from = player, to = owner, damage = 1 }
      end
      if not player.dead then
        room:useCard({
          from = player,
          tos = { player},
          card = Fk:getCardById(id, true),
        })
      end
    elseif Fk:getCardById(treasure).name == "n_relx_v" then
      if not player:isKongcheng() then
        local c = room:askForCard(player, 1, 999, false, yangwu.name, true, ".|.|.|hand", "#n_yangwu-recast")
        if #c > 0 then room:recastCard(c, player, yangwu.name) end
      end
    end
  end,
})
yangwu:addEffect(fk.EventPhaseStart, {
  name = "n_yangwu",
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(yangwu.name) then
      return event == fk.GamePrepared or
        (target == player and player.phase == Player.Start)
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local treasure = player:getEquipment(Card.SubtypeTreasure)
    if not treasure or Fk:getCardById(treasure).name ~= "n_relx_v" then
      local id = U.prepareDeriveCards(player.room, relx, "yangwu_derivedcards")[1]
      local owner = room:getCardOwner(id) --[[ @as ServerPlayer ]]
      room:obtainCard(player, id, false, fk.ReasonPrey)
      if owner and owner ~= player and not owner.dead then
        room:damage { from = player, to = owner, damage = 1 }
      end
      if not player.dead then
        room:useCard({
          from = player,
          tos = { player },
          card = Fk:getCardById(id, true),
        })
      end
    elseif Fk:getCardById(treasure).name == "n_relx_v" then
      if not player:isKongcheng() then
        local c = room:askForCard(player, 1, 999, false, yangwu.name, true, ".|.|.|hand", "#n_yangwu-recast")
        if #c > 0 then room:recastCard(c, player, yangwu.name) end
      end
    end
  end,
})

return yangwu