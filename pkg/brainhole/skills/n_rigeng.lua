local n_rigeng = fk.CreateSkill {
  name = "n_rigeng",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["n_rigeng"] = "日更",
  [":n_rigeng"] = "锁定技，出牌阶段结束后，若你本阶段使用过至少3*X张牌，你执行一个额外的出牌阶段（X为本回合已发动过本技能的次数+1）。",
  ["@n_rigeng-phase"] = "日更",
}

n_rigeng:addEffect(fk.EventPhaseEnd, {
  anim_type = "offensive",
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

local spec = {
  can_refresh = function (self, event, target, player, data)
    return target == player and player:hasSkill(self, true) and player.phase == Player.Play
  end,
  on_refresh = function (self, event, target, player, data)
    local room = player.room
    local num = #room.logic:getEventsOfScope(GameEvent.UseCard, 999, function (e)
      return e.data.from == player
    end, Player.HistoryPhase)
    room:setPlayerMark(player, "@n_rigeng-phase", num.."/"..(3 + 3 * player:usedSkillTimes(n_rigeng.name, Player.HistoryTurn)))
  end,
}

n_rigeng:addEffect(fk.EventPhaseStart, spec)
n_rigeng:addEffect(fk.AfterCardUseDeclared, spec)

return n_rigeng