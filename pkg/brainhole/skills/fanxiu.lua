local fanxiu = fk.CreateSkill{
  name = "n_fanxiu",
}

Fk:loadTranslationTable{
  ["n_fanxiu"] = "翻修",
  [":n_fanxiu"] = "限定技，出牌阶段，你可以获得本回合牌堆和弃牌堆中所有通过〖速编〗复制出来的卡牌。",
  ["#n_fanxiu"] = "翻修：获得本回合牌堆和弃牌堆中所有通过〖速编〗复制出来的卡牌",
}

fanxiu:addEffect('active', {
  anim_type = "drawcard",
  card_num = 0,
  target_num = 0,
  card_filter = Util.FalseFunc,
  frequency = Skill.Limited,
  prompt = "#n_fanxiu",
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryGame) == 0
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local ids = player:getTableMark("n_subian-turn")
    for i = #ids , 1, -1 do
      local id = ids[i]
      if room:getCardArea(id) ~= Card.DiscardPile and room:getCardArea(id) ~= Card.DrawPile then
        table.remove(ids, i)
      end
    end
    if #ids > 0 then
      local dummy = Fk:cloneCard("dilu")
      dummy:addSubcards(ids)
      room:obtainCard(player, dummy, false, fk.ReasonPrey)
    end
  end,
})

return fanxiu
