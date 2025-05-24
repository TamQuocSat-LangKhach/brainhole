local n_fanxiu = fk.CreateSkill {
  name = "n_fanxiu",
  tags = { Skill.Limited, },
}

Fk:loadTranslationTable{
  ["n_fanxiu"] = "翻修",
  [":n_fanxiu"] = "限定技，出牌阶段，你可以获得本回合牌堆和弃牌堆中所有通过〖速编〗复制出来的卡牌。",
  ["#n_fanxiu"] = "翻修：获得本回合牌堆和弃牌堆中所有通过〖速编〗复制出来的卡牌",
}

n_fanxiu:addEffect("active", {
  anim_type = "drawcard",
  prompt = "#n_fanxiu",
  card_num = 0,
  target_num = 0,
  card_filter = Util.FalseFunc,
  can_use = function(self, player)
    return player:usedSkillTimes(n_fanxiu.name, Player.HistoryGame) == 0
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local ids = table.filter(player:getTableMark("n_subian-turn"), function (id)
      return table.contains(room.draw_pile, id) or table.contains(room.discard_pile, id)
    end)
    if #ids > 0 then
      room:obtainCard(player, ids, false, fk.ReasonPrey)
    end
  end,
})

return n_fanxiu