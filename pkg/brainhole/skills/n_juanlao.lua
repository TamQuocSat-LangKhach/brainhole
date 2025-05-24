local n_juanlao = fk.CreateSkill {
  name = "n_juanlao",
}

Fk:loadTranslationTable{
  ["n_juanlao"] = "奆佬",
  [":n_juanlao"] = "出牌阶段限一次，你可以视为使用了本回合你使用过的上一张非转化普通锦囊牌。",

  ["@[:]n_juanlao-turn"] = "奆佬",
}

n_juanlao:addEffect("viewas", {
  card_filter = Util.FalseFunc,
  view_as = function(self, player, cards)
    local cname = player:getMark("@[:]n_juanlao-turn")
    if cname == 0 then return end
    local ret = Fk:cloneCard(cname)
    return ret
  end,
  enabled_at_play = function(self, player)
    if player:usedSkillTimes(n_juanlao.name, Player.HistoryPhase) > 0 then return end
    local cname = player:getMark("@[:]n_juanlao-turn")
    if cname == 0 then return end
    return player:canUse(Fk:cloneCard(cname))
  end,
})

n_juanlao:addEffect(fk.CardUseFinished, {
  can_refresh = function(self, event, target, player, data)
    return target == player and player:hasSkill(n_juanlao.name) and
      data.card:isCommonTrick() and not data.card:isVirtual() and
      player.room.current == player
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "@[:]n_juanlao-turn", data.card.name)
  end,
})

return n_juanlao