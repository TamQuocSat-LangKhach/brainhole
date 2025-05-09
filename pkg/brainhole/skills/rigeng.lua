local rigeng = fk.CreateSkill{
  name = "n_rigeng",
}

Fk:loadTranslationTable{
  ["n_rigeng"] = "日更",
  [":n_rigeng"] = "锁定技，出牌阶段结束后，若你本阶段使用过至少3*X张牌，你执行一个额外的出牌阶段（X为本回合已发动过本技能的次数+1）。",
  ["@n_rigeng-phase"] = "日更",
}

rigeng:addEffect(fk.EventPhaseEnd, {
  anim_type = "offensive",
  frequency = Skill.Compulsory,
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) and player == target and player.phase == Player.Play then
      return #player.room.logic:getEventsOfScope(GameEvent.UseCard, 999, function (e)
        return e.data[1].from == player.id
      end, Player.HistoryPhase) >= (3 + 3 * player:usedSkillTimes(self.name, Player.HistoryTurn))
    end
  end,
  on_use = function(self, event, target, player, data)
    player:gainAnExtraPhase(Player.Play)
  end,
})

local refresh_tab = {
  can_refresh = function (self, event, target, player, data)
    return player:hasSkill(self, true) and player.phase == Player.Play
  end,
  on_refresh = function (self, event, target, player, data)
    local room = player.room ---@type Room
    local num = #room.logic:getEventsOfScope(GameEvent.UseCard, 999, function (e)
      return e.data.from == player
    end, Player.HistoryPhase)
    room:setPlayerMark(player, "@n_rigeng-phase", num.."/"..(3 + 3 * player:usedSkillTimes(self.name, Player.HistoryTurn)))
  end,
}

rigeng:addEffect(fk.EventPhaseStart, {
  can_refresh = refresh_tab.can_refresh,
  on_refresh = refresh_tab.on_refresh,
})
rigeng:addEffect(fk.AfterCardUseDeclared, {
  can_refresh = refresh_tab.can_refresh,
  on_refresh = refresh_tab.on_refresh,
})

return rigeng
