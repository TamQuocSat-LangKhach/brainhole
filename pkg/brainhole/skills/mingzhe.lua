local mingzhe = fk.CreateSkill{
  name = "n_mingzhe",
}

Fk:loadTranslationTable{
  ["n_mingzhe"] = "明哲",
  [":n_mingzhe"] = "每回合限两次，当你于回合外使用、打出或因弃置而失去一张红色牌时，你可以摸一张牌。",
}

local mingzhe_tab = {
  on_trigger = function(self, event, target, player, data)
    local x = self.cost_data
    local ret
    for _ = 1, x do
      if self.cancel_cost or not player:hasSkill(mingzhe.name) or player:usedSkillTimes(mingzhe.name, Player.HistoryTurn) >= 2 then
        self.cancel_cost = false
        break
      end
      ret = self:doCost(event, target, player, data)
      if ret then return ret end
    end
  end,
  on_cost = function(self, event, target, player, data)
    if player.room:askForSkillInvoke(player, self.name, data) then
      return true
    end
    self.cancel_cost = true
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(1, self.name)
  end,
}

mingzhe:addEffect(fk.CardUsing, {
  anim_type = "defensive",
  events = {fk.CardUsing, fk.CardResponding, fk.AfterCardsMove},
  can_trigger = function(self, event, target, player, data)
    if not (player:hasSkill(mingzhe.name) and player.phase == Player.NotActive and player:usedSkillTimes(mingzhe.name, Player.HistoryTurn) < 2) then return end
    self.cost_data = 0
    if (player == target and data.card.color == Card.Red) then self.cost_data = self.cost_data + 1 end
    return self.cost_data > 0
  end,
  on_trigger = mingzhe_tab.on_trigger,
  on_cost = mingzhe_tab.on_cost,
  on_use = mingzhe_tab.on_use,
})
mingzhe:addEffect(fk.CardResponding, {
  anim_type = "defensive",
  events = {fk.CardUsing, fk.CardResponding, fk.AfterCardsMove},
  can_trigger = function(self, event, target, player, data)
    if not (player:hasSkill(mingzhe.name) and player.phase == Player.NotActive and player:usedSkillTimes(mingzhe.name, Player.HistoryTurn) < 2) then return end
    self.cost_data = 0
    if (player == target and data.card.color == Card.Red) then self.cost_data = self.cost_data + 1 end
    return self.cost_data > 0
  end,
  on_trigger = mingzhe_tab.on_trigger,
  on_cost = mingzhe_tab.on_cost,
  on_use = mingzhe_tab.on_use,
})
mingzhe:addEffect(fk.AfterCardsMove, {
  anim_type = "defensive",
  events = {fk.CardUsing, fk.CardResponding, fk.AfterCardsMove},
  can_trigger = function(self, event, target, player, data)
    if not (player:hasSkill(mingzhe.name) and player.phase == Player.NotActive and player:usedSkillTimes(mingzhe.name, Player.HistoryTurn) < 2) then return end
    self.cost_data = 0
    for _, move in ipairs(data) do
      if move.from == player.id and move.moveReason == fk.ReasonDiscard then
        for _, info in ipairs(move.moveInfo) do
          if (info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip) and
          Fk:getCardById(info.cardId).color == Card.Red then
            self.cost_data = self.cost_data + 1
          end
        end
      end
    end
    return self.cost_data > 0
  end,
  on_trigger = mingzhe_tab.on_trigger,
  on_cost = mingzhe_tab.on_cost,
  on_use = mingzhe_tab.on_use,
})

return mingzhe
