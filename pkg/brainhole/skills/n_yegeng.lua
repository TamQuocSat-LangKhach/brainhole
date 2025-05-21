local n_yegeng = fk.CreateSkill {
  name = "n_yegeng",
  tags = { Skill.Compulsory, },
}



n_yegeng:addEffect(fk.EventPhaseStart, {
  name = "n_yegeng",
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(n_yegeng.name) and
        player.phase == Player.Finish
  end,
  on_use = function(self, event, target, player, data)
    if event:getCostData(self) then
      player:gainAnExtraTurn()
    else
      player:drawCards(1, n_yegeng.name)
    end
  end,
})
n_yegeng:addEffect(fk.EventPhaseStart, {
  can_refresh = function(self, event, target, player, data)
    if not (target == player and player:hasSkill(n_yegeng.name)) then return end
    return player.phase == Player.Finish
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    local mark_name = "@n_yegeng"
    if event == fk.EventPhaseStart then
      event:setCostData(self, player:getMark(mark_name) >= 3 + player:usedSkillTimes(n_yegeng.name), Player.HistoryRound)
      room:setPlayerMark(player, mark_name, 0)
    else
      room:addPlayerMark(player, mark_name, 1)
    end
  end
})
n_yegeng:addEffect(fk.CardUseFinished, {
  can_refresh = function(self, event, target, player, data)
    if not (target == player and player:hasSkill(n_yegeng.name)) then return end
    return data.card.type == Card.TypeTrick and
        data.card.sub_type ~= Card.SubtypeDelayedTrick and
        player.phase ~= Player.NotActive
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    local mark_name = "@n_yegeng"
    if event == fk.EventPhaseStart then
      event:setCostData(self, player:getMark(mark_name) >= 3 + player:usedSkillTimes(n_yegeng.name), Player.HistoryRound)
      room:setPlayerMark(player, mark_name, 0)
    else
      room:addPlayerMark(player, mark_name, 1)
    end
  end
})

return n_yegeng
