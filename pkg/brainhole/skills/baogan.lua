local baogan = fk.CreateSkill{
  name = "n_baogan",
  tags={Skill.Limited,},
}

Fk:loadTranslationTable{
  ["n_baogan"] = "爆肝",
  ["@@n_baogan"] = "爆肝",
  [":n_baogan"] = "限定技，出牌阶段，你可以令〖编程〗变得也可使用打出黑桃牌直到你下回合开始。",
  ["#n_baogan"] = "爆肝:令“编程”也可使用打出黑桃牌直到你下回合开始！",
}

baogan:addEffect('active', {
  card_num = 0,
  target_num = 0,
  frequency = Skill.Limited,
  prompt = "#n_baogan",
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryGame) == 0
  end,
  card_filter = Util.FalseFunc,
  on_use = function(self, room, effect)
    room:setPlayerMark(effect.from, "@@n_baogan", 1)
  end,
})
baogan:addEffect(fk.TurnStart, {
  can_refresh = function(self, event, target, player, data)
    return target == player and player:getMark("@@n_baogan") > 0
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "@@n_baogan", 0)
  end,
})

return baogan
