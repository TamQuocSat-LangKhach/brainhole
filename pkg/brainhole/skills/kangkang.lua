local kangkang = fk.CreateSkill {
  name = "n_kangkang",
}



kangkang:addEffect(fk.DamageCaused, {
  name = "n_kangkang",
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(kangkang.name) and not data.to:isKongcheng() and
      (data.to == player:getNextAlive() or data.to:getNextAlive() == player) and
      player:usedSkillTimes(kangkang.name, Player.HistoryTurn) < 2
  end,
  on_use = function(self, event, _, player, data)
    local room = player.room
    local target = data.to
    local id = room:askForCardChosen(player, target, { card_data = { { "$Hand", target:getCardIds(Player.Hand) }  } }, kangkang.name)
    room:obtainCard(player, id, false, fk.ReasonPrey)
  end,
})

return kangkang