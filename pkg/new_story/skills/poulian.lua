local poulian = fk.CreateSkill {

  name = "n_poulian",

  tags = {},

}

--当其他角色一次性获得不少于两张牌时，你可以改为由你获得它们，然后不能再对其发动此技能直到其进入濒死状态。

poulian:addEffect(fk.BeforeCardsMove, {
  name = "n_poulian",
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(poulian.name) then return false end
    local room = player.room
    local guzheng_pairs = {}
    for _, move in ipairs(data) do
      if move.toArea == Card.PlayerHand and move.to and move.to ~= player and
          not table.contains(move.to:getTableMark(poulian.name), player.id) then
        guzheng_pairs[move.to.id] = (guzheng_pairs[move.to.id] or 0) + #move.moveInfo
      end
    end
    for key, value in pairs(guzheng_pairs) do
      if value > 1 then
        return true
      end
    end
  end,
  on_trigger = function(self, event, target, player, data)
    local room = player.room
    local targets = {}
    local guzheng_pairs = {}
    for _, move in ipairs(data) do
      if move.toArea == Card.PlayerHand and move.to and move.to ~= player and
          not table.contains(move.to:getTableMark(poulian.name), player.id) then
        guzheng_pairs[move.to.id] = (guzheng_pairs[move.to.id] or 0) + #move.moveInfo
      end
    end
    for key, value in pairs(guzheng_pairs) do
      if value > 1 then
        table.insertIfNeed(targets, key)
      end
    end
    room:sortByAction(table.map(targets,Util.Id2PlayerMapper))
    for _, target_id in ipairs(targets) do
      if not player:hasSkill(poulian.name) then break end
      local skill_target = room:getPlayerById(target_id)
      event:setCostData(self, guzheng_pairs[target_id])
      self:doCost(event, skill_target, player, data)
    end
  end,
  on_cost = function(self, event, target, player, data)
    if target then
      return player.room:askToSkillInvoke(player, {
        skill_name = poulian.name,
        data = data,
        prompt = "#n_poulian::" .. target.id .. ":" .. event:getCostData(self)
      })
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if target then
      room:doIndicate(player, { target })
      for _, move in ipairs(data) do
        if move.to == target then
          local mark = target:getTableMark(poulian.name)
          table.insert(mark, player.id)
          room:setPlayerMark(target, poulian.name, mark)
          move.to = player
          break
        end
      end
    end
  end,
})
poulian:addEffect(fk.EnterDying, {
  can_refresh = function(self, event, target, player, data)
    return target == player
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:setPlayerMark(player, poulian.name, {})
  end,
})
return poulian
