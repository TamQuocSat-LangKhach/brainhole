local n_songji = fk.CreateSkill {
  name = "n_songji",
}

---@param player ServerPlayer
local function songjiCanUse(player)
  local canSlash = not player:prohibitUse(Fk:cloneCard("slash"))
  local canPeach = not player:prohibitUse(Fk:cloneCard("peach"))

  canSlash = canSlash and table.find(player.room:getOtherPlayers(player, false), function(p)
    return player:inMyAttackRange(p) and
      not player:isProhibited(p, Fk:cloneCard("slash"))
  end)
  canPeach = canPeach and player:isWounded()
  return canSlash, canPeach
end

---@param player ServerPlayer
---@param move MoveCardsData
local function songjiCheckMove(player, move)
  local cards = player:getMark("n_pengji_dis")
  local valid = {}
  for _, info in ipairs(move.moveInfo) do
    if table.find(cards, function(id)
      return Fk:getCardById(id).trueName == Fk:getCardById(info.cardId).trueName
    end) then table.insert(valid, info.cardId) end
  end
  return valid
end

n_songji:addEffect(fk.AfterCardsMove, {
  name = "n_songji",
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(n_songji.name) then return end
    if player:getMark("n_songji-phase") > 0 then return end
    for _, move in ipairs(data) do
      if move.skillName == "n_pengji" and move.to == player
        and move.moveReason == fk.ReasonDraw then
        local a, b = songjiCanUse(player)
        if #songjiCheckMove(player, move) > 0 and (a or b) then
          return true
        end
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    local ids
    for _, move in ipairs(data) do
      if move.skillName == "n_pengji" and move.to == player
        and move.moveReason == fk.ReasonDraw then
        ids = songjiCheckMove(player, move)
        break
      end
    end
    local room = player.room
    local c = room:askForCard(player, 1, 1, true, n_songji.name, true,
      tostring(Exppattern{ id = ids }), "@n_songji")
    if #c == 0 then return end
    local choices = {}
    local s, p = songjiCanUse(player)
    if s then table.insert(choices, "slash") end
    if p then table.insert(choices, "peach") end
    -- table.insert(choices, "Cancel")
    local choice = room:askForChoice(player, choices, n_songji.name)
    if choice == "peach" then
      event:setCostData(self, {
        cards = c,
        cname = choice,
        tos = {player.id},
      })
      return true
    elseif choice == "slash" then
      local targets = table.filter(room:getOtherPlayers(player, false), function(p)
        return player:inMyAttackRange(p) and
          not player:isProhibited(p, Fk:cloneCard("slash"))
      end)
      targets = table.map(targets, Util.IdMapper)
      local p2 = room:askForChoosePlayers(player, targets, 1, 1, "@n_songji_slash",
        n_songji.name, true)
      if #p2 ~= 0 then
        event:setCostData(self, {
          cards = c,
          cname = choice,
          tos = p2,
        })
        return true
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local use = {}
    local dat = event:getCostData(self)
    use.from = player
    use.tos = table.map(dat,function (pid)
      return room:getPlayerById(pid)
    end)
    local card = Fk:cloneCard(dat.cname)
    card:addSubcard(dat.cards[1])
    card.skillName = n_songji.name
    use.card = card
    use.extraUse = true
    room:useCard(use)
    room:addPlayerMark(player, "n_songji-phase", 1)
    player:drawCards(1, n_songji.name)
  end,
})

return n_songji