local hunfu = fk.CreateSkill {
  name = "n_hunfu",
  tags = { Skill.Compulsory, },
}

Fk:loadTranslationTable{
  ["n_hunfu"] = "魂附",
  [":n_hunfu"] = "锁定技，一名角色完成判定后，其获得一枚“判”。你死亡时，操控“判”标记最多的角色直到其下回合结束。",

  ["@n_hunfu"] = "判",

  ["$n_hunfu1"] = "七千里记黄天途，家山何处？",
  ["$n_hunfu2"] = "填海水以将枯，心早成灰。",
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
  can_refresh = function(self, event, target, player, data)
    return target == player and target:getMark("n_hunfucontrolled") > 0
  end,
  on_refresh = function(self, event, target, player, data)
    local room = target.room
    room:setPlayerMark(target, "n_hunfucontrolled", 0)
    target:control(target)
  end,
})

hunfu:addEffect(fk.FinishJudge, {
  can_refresh = function(self, event, target, player, data)
    return player:hasSkill(hunfu.name)
  end,
  on_refresh = function(self, event, target, player, data)
    local room = target.room
    room:addPlayerMark(target, "@n_hunfu")
  end,
})

hunfu:addEffect(fk.GameOverJudge, {
  can_refresh = function (self, event, target, player, data)
    return target == player and Fk.game_modes[player.room.settings.gameMode]:getWinner(target) ~= ""
  end,
  on_refresh = function(self, event, target, player, data)
    local room = target.room
    for _, p in ipairs(room.players) do
      p:control(p)
    end
  end,
})

return hunfu
