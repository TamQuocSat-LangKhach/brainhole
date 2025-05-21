local n_fenliang = fk.CreateSkill {

  name = "n_fenliang",

  tags = {  },

}



n_fenliang:addEffect("active", {
  name = "n_fenliang",
  anim_type = "support",
  card_num = 3,
  target_num = 1,
  prompt = "#n_fenliang-prompt",
  card_filter = function(self, player, to_select, selected)
    return #selected < 3 and Fk:currentRoom():getCardArea(to_select) ~= Player.Equip
  end,
  target_filter =function (self, player, to_select, selected, selected_cards)
        return #selected == 0 and #to_select:getPile("n_liang") > 0 and #selected_cards == 3
  end,
  can_use = function(self, player)
    return player:usedSkillTimes(n_fenliang.name, Player.HistoryPhase) == 0 and player:isWounded()
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    room:obtainCard(target, effect.cards, false, fk.ReasonGive, player, n_fenliang.name)
    if #target:getPile("n_liang") > 0 and not player.dead and player:isWounded() then
      local supply = table.random(target:getPile("n_liang"), math.random(1, player:getLostHp()))
      room:obtainCard(player, supply, true, fk.ReasonPrey, player, n_fenliang.name)
    end
  end,
})

return n_fenliang