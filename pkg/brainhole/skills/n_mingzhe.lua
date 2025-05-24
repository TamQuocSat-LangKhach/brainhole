local n_mingzhe = fk.CreateSkill {
  name = "n_mingzhe",
}

Fk:loadTranslationTable{
  ["n_mingzhe"] = "明哲",
  [":n_mingzhe"] = "每回合限两次，当你于回合外使用、打出或因弃置而失去一张红色牌时，你可以摸一张牌。",
}

n_mingzhe:addEffect(fk.AfterCardsMove, {
  anim_type = "drawcard",
  trigger_times = function (self, event, target, player, data)
    local n = 0
    if player:hasSkill(n_mingzhe.name) and player.room.current ~= player then
      for _, move in ipairs(data) do
        if move.from == player and table.contains({fk.ReasonUse, fk.ReasonResponse, fk.ReasonDiscard}, move.moveReason) then
          for _, info in ipairs(move.moveInfo) do
            if (info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip) and
              Fk:getCardById(info.cardId).color == Card.Red then
              n = n + 1
            end
          end
        end
      end
    end
    return n
  end,
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(n_mingzhe.name) and player:usedSkillTimes(n_mingzhe.name, Player.HistoryTurn) < 2
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(1, n_mingzhe.name)
  end,
})

return n_mingzhe
