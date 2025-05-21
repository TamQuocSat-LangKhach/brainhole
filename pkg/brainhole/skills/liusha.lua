local liusha = fk.CreateSkill {
  name = "n_liusha",
}



liusha:addEffect(fk.TargetConfirming, {
  name = "n_liusha",
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    local ret = target == player and player:hasSkill(liusha.name) and
        data.card:getSubtypeString() == "normal_trick" and
        not table.contains(data:getAllTargets(), data.from)
    if ret then
      return not player:isAllNude()
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local prompt = "#n_liusha"
    local cards = room:askForDiscard(player, 1, 1, true, liusha.name, true, ".|.|diamond", prompt, true)
    if #cards > 0 then
      event:setCostData(self, cards)
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local toId = data.from
    local to = toId
    room:throwCard(event:getCostData(self), liusha.name, player, player)
    if player.dead then return end
    local choices = { "n_liusha_choice1" }
    if not to:isNude() then table.insert(choices, "n_liusha_choice2") end
    local choice = room:askForChoice(player, choices, liusha.name)
    if choice == "n_liusha_choice1" then
      data:cancelTarget(player)
      data:addTarget(toId)
    else
      local c = room:askForCardChosen(player, to, "he", liusha.name)
      room:obtainCard(player, c, false, fk.ReasonPrey, player)
    end
  end,
})

return liusha
