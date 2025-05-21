local n_fanxiu = fk.CreateSkill {
  name = "n_fanxiu",
  tags = { Skill.Limited, },
}



n_fanxiu:addEffect("active", {
  name = "n_fanxiu",
  anim_type = "drawcard",
  card_num = 0,
  target_num = 0,
  card_filter = Util.FalseFunc,
  prompt = function() return "#n_fanxiu" end,
  can_use = function(self, player)
    return player:usedSkillTimes(n_fanxiu.name, Player.HistoryGame) == 0
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

return n_fanxiu