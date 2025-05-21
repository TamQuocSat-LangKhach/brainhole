local n_shenjiao = fk.CreateSkill {
  name = "n_shenjiao",
}



n_shenjiao:addEffect("active", {
  name = "n_shenjiao",
  anim_type = "drawcard",
  can_use =function (self, player)
    return player:getMark("@n_jiao") > 0
  end,
  card_num = 0,
  target_num = 0,
  card_filter = function() return false end,
  on_use = function (self, room, effect)
    local from = effect.from
    room:removePlayerMark(from, "@n_jiao", 1)
    from:drawCards(2, n_shenjiao.name)
  end
})

n_shenjiao:addEffect(fk.EnterDying, {
  name = "#n_shenjiao",
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return player ~= target and player:hasSkill("n_shenjiao") and player:getMark("@n_jiao") > 0
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askForSkillInvoke(player, "n_shenjiao", data, "#n_shenjiao-invoke::"..target.id)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke("n_shenjiao")
    room:notifySkillInvoked(player, "n_shenjiao", "support")
    room:removePlayerMark(player, "@n_jiao", 1)
    room:doIndicate(player, { target })
    room:recover{
      who = target,
      num = 1,
      recoverBy = player,
      skillName = n_shenjiao.name
    }
  end,
})

return n_shenjiao