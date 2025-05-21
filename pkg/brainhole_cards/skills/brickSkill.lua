local brickSkill = fk.CreateSkill {
  name = "n_brick_skill",
}



brickSkill:addEffect("cardskill", {
  name = "n_brick_skill",
  max_round_use_time = 1,
  can_use = function(self, player, card, extra_data)
    return (extra_data and extra_data.bypass_times) or table.find(Fk:currentRoom().alive_players, function(p)
      return self:withinTimesLimit(player, Player.HistoryRound, card, "n_brick", p)
    end)
  end,
  target_num = 1,
  mod_target_filter = function(self, player, to_select, selected, card, extra_data)
    return player ~= to_select and
    not (not (extra_data and extra_data.bypass_distances) and not self:withinDistanceLimit(player, true, card, to_select))
  end,
  target_filter = function(self, player, to_select, selected, selected_cards, card, extra_data)
    if Util.CardTargetFilter(self, player, to_select, selected, {}, card, extra_data) then
      return self:modTargetFilter(player,to_select, selected, card, extra_data) and
          (#selected > 0 or self:withinTimesLimit(player, Player.HistoryRound, card, "n_brick", to_select)
            or (extra_data and extra_data.bypass_times))
    end
  end,
  on_effect = function(self, room, effect)
    local from = effect.from
    local to = effect.to
    local cards = room:getSubcardsByRule(effect.card, { Card.Processing })
    if #cards > 0 and not to.dead then
      room:obtainCard(to, effect.card, true, fk.ReasonGive, from.id)
    end
    if to.dead or from.dead then return false end
    room:damage({
      from = from,
      to = to,
      card = effect.card,
      damage = 1,
      damageType = fk.NormalDamage,
      skillName = brickSkill.name
    })
  end
})

return brickSkill
