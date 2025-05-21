local n_suijie = fk.CreateSkill {
  name = "n_suijie",
}



n_suijie:addEffect(fk.TargetConfirmed, {
  name = "n_suijie",
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(n_suijie.name) and
      data.from ~= player and
      table.contains(
        { "peach", "analeptic", "amazing_grace", "god_salvation" },
        data.card.name)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    if room:askForSkillInvoke(player, n_suijie.name, nil, "#n_suijie_ask:" .. data.from.id) then
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local from = data.from
    from:drawCards(1, n_suijie.name)
    local a, b = player:getHandcardNum(), from:getHandcardNum()
    if a < b and player:isAlive() then
      player:drawCards(b - a, n_suijie.name)
    end
  end,
})

return n_suijie