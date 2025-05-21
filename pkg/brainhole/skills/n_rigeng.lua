local n_rigeng = fk.CreateSkill {
  name = "n_rigeng",
  tags = { Skill.Compulsory, },
}



n_rigeng:addEffect(fk.EventPhaseEnd, {
  name = "n_rigeng",
  anim_type = "offensive",
  events = {fk.EventPhaseEnd},
  frequency = Skill.Compulsory,
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(n_rigeng.name) and player == target and player.phase == Player.Play then
      return #player.room.logic:getEventsOfScope(GameEvent.UseCard, 999, function (e)
        return e.data.from == player
      end, Player.HistoryPhase) >= (3 + 3 * player:usedSkillTimes(n_rigeng.name, Player.HistoryTurn))
    end
  end,
  on_use = function(self, event, target, player, data)
    player:gainAnExtraPhase(Player.Play)
  end,
})
n_rigeng:addEffect(fk.EventPhaseStart, {
  refresh_events = {fk.EventPhaseStart, fk.AfterCardUseDeclared},
  can_refresh = function (self, event, target, player, data)
    return player:hasSkill(self, true) and player.phase == Player.Play
  end,
  on_refresh = function (self, event, target, player, data)
    local room = player.room
    local num = #room.logic:getEventsOfScope(GameEvent.UseCard, 999, function (e)
      return e.data.from == player
    end, Player.HistoryPhase)
    room:setPlayerMark(player, "@n_rigeng-phase", num.."/"..(3 + 3 * player:usedSkillTimes(n_rigeng.name, Player.HistoryTurn)))
  end,
})
n_rigeng:addEffect(fk.AfterCardUseDeclared, {
  refresh_events = {fk.EventPhaseStart, fk.AfterCardUseDeclared},
  can_refresh = function (self, event, target, player, data)
    return player:hasSkill(self, true) and player.phase == Player.Play
  end,
  on_refresh = function (self, event, target, player, data)
    local room = player.room
    local num = #room.logic:getEventsOfScope(GameEvent.UseCard, 999, function (e)
      return e.data.from == player
    end, Player.HistoryPhase)
    room:setPlayerMark(player, "@n_rigeng-phase", num.."/"..(3 + 3 * player:usedSkillTimes(n_rigeng.name, Player.HistoryTurn)))
  end,
})

return n_rigeng