local chiyao = fk.CreateSkill {
  name = "n_chiyao",
}



chiyao:addEffect(fk.CardUsing, {
  name = "n_chiyao",
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return target ~= player and player:hasSkill(chiyao.name) and player:usedSkillTimes(chiyao.name, Player.HistoryTurn) < 2 and
      data.card.is_damage_card and not data.card:isVirtual() and not player:isNude()
  end,
  on_cost = function(self, event, target, player, data)
    local c = player.room:askForDiscard(player, 1, 1, true, chiyao.name, true,
      ".|.|heart", "#n_chiyao-discard:::" .. data.card:toLogString(), true)
    if c[1] then
      event:setCostData(self, {tos = {target.id}, cards = c})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:throwCard(event:getCostData(self).cards, chiyao.name, player, player)
    if not player.dead and not target:isNude() then
      local card = room:askForCardChosen(player, target, "he", chiyao.name)
      room:throwCard({card}, chiyao.name, target, player)
    end
    if data.toCard then
      data.toCard = nil
    else
      data.tos = {}
    end
    --room.logic:getCurrentEvent().parent:shutdown()
  end,
})

return chiyao