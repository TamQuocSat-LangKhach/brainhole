local chunzhen = fk.CreateSkill {
  name = "n_chunzhen",
  tags = { Skill.Compulsory, },
}



chunzhen:addEffect(fk.AfterCardTargetDeclared, {
  name = "n_chunzhen",
  mute = true,
  can_trigger = function(self, event, target, player, data)
    if not (target == player and player:hasSkill(chunzhen.name)) then
      return false
    end
    return data.card:getSubtypeString() == "normal_trick" and data.tos and #data.tos > 1
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke(chunzhen.name)
    room:notifySkillInvoked(player, chunzhen.name, "special")
    local tos = room:askForChoosePlayers(player, table.map(data.tos,Util.IdMapper), 1, 1,
      "#n_chunzhen-choose", chunzhen.name, false)
    
    data:removeTarget(room:getPlayerById(tos[1]))
    room:addPlayerMark(player, "@n_chunzhen", 1)
  end,
})
chunzhen:addEffect(fk.DamageInflicted, {
  name = "n_chunzhen",
  mute = true,
  can_trigger = function(self, event, target, player, data)
    if not (target == player and player:hasSkill(chunzhen.name)) then
      return false
    end
    return data.damageType == fk.ThunderDamage and player:getMark("@n_chunzhen") > 0
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke(chunzhen.name)
    room:notifySkillInvoked(player, chunzhen.name, "defensive")
    room:removePlayerMark(player, "@n_chunzhen", 1)
    data.damage = data.damage - 1
  end,
})

return chunzhen
