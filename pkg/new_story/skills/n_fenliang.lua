local n_fenliang = fk.CreateSkill {
  name = "n_fenliang",
}

Fk:loadTranslationTable{
  ["n_fenliang"] = "分粮",
  [":n_fenliang"] = "出牌阶段限一次，若你已受伤，你可以交给有“粮”的角色三张手牌，从“粮”中获得随机的1~X张牌（X为你损失体力值）。",

  ["#n_fenliang-prompt"] = "分粮：你可以将三张手牌交给有“粮”的角色，获得随机张“粮”",
}

n_fenliang:addEffect("active", {
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