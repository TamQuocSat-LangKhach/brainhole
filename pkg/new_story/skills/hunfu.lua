local hunfu = fk.CreateSkill {

  name = "n_hunfu",

  tags = { Skill.Compulsory, },

}



hunfu:addEffect(fk.Death, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(self, false, true) then
      local availableTargets = {}
      local n = 0
      for _, p in ipairs(player.room.alive_players) do
        if p:getMark("@n_hunfu") > n then
          availableTargets = {}
          table.insert(availableTargets, p.id)
          n = p:getMark("@n_hunfu")
        elseif p:getMark("@n_hunfu") == n then
          table.insert(availableTargets, p.id)
        end
      end
      if #availableTargets > 0 then
        event:setCostData(self, availableTargets)
        return true
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    for _, p in ipairs(room.alive_players) do
      room:setPlayerMark(p, "@n_hunfu", 0)
    end
    room:doIndicate(player, event:getCostData(self))
    for _, pid in ipairs(event:getCostData(self)) do
      local p = room:getPlayerById(pid)
      room:addPlayerMark(p, "n_hunfucontrolled")
      player:control(p)
    end
  end,
})

hunfu:addEffect(fk.TurnEnd, {
  can_refresh = function(self, event, target, player)
    return target == player and target:getMark("n_hunfucontrolled") > 0
  end,
  on_refresh = function(_, event, target)
    local room = target.room
    room:setPlayerMark(target, "n_hunfucontrolled", 0)
    target:control(target)
  end,
})

hunfu:addEffect(fk.FinishJudge, {
  can_refresh = function(self, event, target, player)
    return player:hasSkill(hunfu.name)
  end,
  on_refresh = function(_, event, target)
    local room = target.room
    room:addPlayerMark(target, "@n_hunfu")
  end,
})
return hunfu
