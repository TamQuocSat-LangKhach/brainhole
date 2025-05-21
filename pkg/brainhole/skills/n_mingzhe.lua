local n_mingzhe = fk.CreateSkill {
  name = "n_mingzhe",
}



n_mingzhe:addEffect(fk.CardUsing, {
  name = "n_mingzhe",
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    if not (player:hasSkill(n_mingzhe.name) and player.phase == Player.NotActive and player:usedSkillTimes(n_mingzhe.name, Player.HistoryTurn) < 2) then return end
    event:setCostData(self, 0)
    if (player == target and data.card.color == Card.Red) then event:setCostData(self, event:getCostData(self) + 1) end
    return event:getCostData(self) > 0
  end,
  on_trigger = function(self, event, target, player, data)
    local x = event:getCostData(self)
    local ret
    for _ = 1, x do
      if event:getSkillData(self, "cancel_cost") or not player:hasSkill(n_mingzhe.name) or player:usedSkillTimes(n_mingzhe.name, Player.HistoryTurn) >= 2 then
        event:setSkillData(self, "cancel_cost", false)
        break
      end
      ret = self:doCost(event, target, player, data)
      if ret then return ret end
    end
  end,
  on_cost = function(self, event, target, player, data)
    if player.room:askForSkillInvoke(player, n_mingzhe.name, data) then
      return true
    end
    event:setSkillData(self, "cancel_cost", true)
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(1, n_mingzhe.name)
  end,
})
n_mingzhe:addEffect(fk.CardResponding, {
  name = "n_mingzhe",
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    if not (player:hasSkill(n_mingzhe.name) and player.phase == Player.NotActive and player:usedSkillTimes(n_mingzhe.name, Player.HistoryTurn) < 2) then return end
    event:setCostData(self, 0)
     if (player == target and data.card.color == Card.Red) then event:setCostData(self, event:getCostData(self) + 1) end
    return event:getCostData(self) > 0
  end,
  on_trigger = function(self, event, target, player, data)
    local x = event:getCostData(self)
    local ret
    for _ = 1, x do
      if event:getSkillData(self, "cancel_cost") or not player:hasSkill(n_mingzhe.name) or player:usedSkillTimes(n_mingzhe.name, Player.HistoryTurn) >= 2 then
        event:setSkillData(self, "cancel_cost", false)
        break
      end
      ret = self:doCost(event, target, player, data)
      if ret then return ret end
    end
  end,
  on_cost = function(self, event, target, player, data)
    if player.room:askForSkillInvoke(player, n_mingzhe.name, data) then
      return true
    end
    event:setSkillData(self, "cancel_cost", false)
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(1, n_mingzhe.name)
  end,
})
n_mingzhe:addEffect(fk.AfterCardsMove, {
  name = "n_mingzhe",
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    if not (player:hasSkill(n_mingzhe.name) and player.phase == Player.NotActive and player:usedSkillTimes(n_mingzhe.name, Player.HistoryTurn) < 2) then return end
    event:setCostData(self, 0)
    for _, move in ipairs(data) do
      if move.from == player and move.moveReason == fk.ReasonDiscard then
        for _, info in ipairs(move.moveInfo) do
          if (info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip) and
              Fk:getCardById(info.cardId).color == Card.Red then
            event:setCostData(self, event:getCostData(self) + 1)
          end
        end
      end
    end
    return event:getCostData(self) > 0
  end,
  on_trigger = function(self, event, target, player, data)
    local x = event:getCostData(self)
    local ret
    for _ = 1, x do
      if event:getSkillData(self, "cancel_cost") or not player:hasSkill(n_mingzhe.name) or player:usedSkillTimes(n_mingzhe.name, Player.HistoryTurn) >= 2 then
        event:setSkillData(self, "cancel_cost", false)
        break
      end
      ret = self:doCost(event, target, player, data)
      if ret then return ret end
    end
  end,
  on_cost = function(self, event, target, player, data)
    if player.room:askForSkillInvoke(player, n_mingzhe.name, data) then
      return true
    end
    event:setSkillData(self, "cancel_cost", true)
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(1, n_mingzhe.name)
  end,
})

return n_mingzhe
