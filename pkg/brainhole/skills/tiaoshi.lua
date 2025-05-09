local tiaoshi = fk.CreateSkill{
  name = "n_tiaoshi",
}

Fk:loadTranslationTable{
  ["n_tiaoshi"] = "调试",
  [":n_tiaoshi"] = "出牌阶段，你可以弃置X张牌并摸一张牌。（X为本阶段发动过该技能的次数）",
  ["#n_tiaoshi"] = "调试：弃置 %arg 张牌，然后摸 1 张牌",
}

tiaoshi:addEffect('active', {
  anim_type = "drawcard",
  target_num = 0,
  prompt = function(self, player)
    return "#n_tiaoshi:::" .. player:usedSkillTimes(self.name)
  end,
  card_num = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase)
  end,
  card_filter = function(self, player, to_select, selected)
    return #selected < player:usedSkillTimes(self.name) and
      not player:prohibitDiscard(Fk:getCardById(to_select))
  end,
  on_use = function(self, room, effect)
    local from = effect.from
    if #effect.cards > 0 then
      room:throwCard(effect.cards, self.name, from)
    end
    from:drawCards(1, self.name)
  end
})

return tiaoshi
