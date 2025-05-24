local n_yegeng = fk.CreateSkill {
  name = "n_yegeng",
  tags = { Skill.Compulsory, },
}

Fk:loadTranslationTable{
  ["n_yegeng"] = "夜更",
  [":n_yegeng"] = "锁定技，结束阶段，若你本回合使用普通锦囊牌数量不小于3+X，你进行一个额外的回合，否则你摸一张牌。（X为你本轮内发动过该技能的次数）",

  ["@n_yegeng-turn"] = "夜更",
}

n_yegeng:addEffect(fk.EventPhaseStart, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(n_yegeng.name) and player.phase == Player.Finish
  end,
  on_use = function(self, event, target, player, data)
    local num = #player.room.logic:getEventsOfScope(GameEvent.UseCard, 999, function (e)
      return e.data.from == player and e.data.card:isCommonTrick()
    end, Player.HistoryTurn)
    if num >= 3 + player:usedSkillTimes(n_yegeng.name, Player.HistoryRound) then
      player:gainAnExtraTurn()
    else
      player:drawCards(1, n_yegeng.name)
    end
  end,
})

n_yegeng:addEffect(fk.AfterCardUseDeclared, {
  can_refresh = function (self, event, target, player, data)
    return target == player and player:hasSkill(self, true) and player.room.current == player and data.card:isCommonTrick()
  end,
  on_refresh = function (self, event, target, player, data)
    local room = player.room
    local num = #room.logic:getEventsOfScope(GameEvent.UseCard, 999, function (e)
      return e.data.from == player and e.data.card:isCommonTrick()
    end, Player.HistoryTurn)
    room:setPlayerMark(player, "@n_yegeng-turn", num.."/"..(3 + player:usedSkillTimes(n_yegeng.name, Player.HistoryRound)))
  end,
})

return n_yegeng
