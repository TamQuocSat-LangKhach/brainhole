local nuzhan = fk.CreateSkill {

  name = "n_jizhan",

  tags = {  },

}



nuzhan:addEffect(fk.AfterSkillEffect, {
  name = "n_jizhan",
  anim_type = "offensive",
  can_trigger = function(self, _, target, player, data)
    local slash = Fk:cloneCard 'slash'
    return player:hasSkill(nuzhan.name) and player.phase == Player.NotActive and
      target and target ~= player and
      player.room.logic:getCurrentEvent().n_can_jizhan and
      not player:prohibitUse(slash) and
      not player:isProhibited(target, slash)
  end,
  on_cost = function(self, event, target, player, data)
     return player.room:askToSkillInvoke(player,{
      skill_name=nuzhan.name,
      data=data,
      prompt="#n_jizhan-invoke::"..target.id
    })
  end,
  on_use = function(self, _, target, player, data)
    local room = player.room
    local slash = Fk:cloneCard 'slash'
    slash.skillName = nuzhan.name
    room:useCard {
      from = player,
      tos = { target},
      card = slash,
      additionalDamage = target:isWounded() and 0 or 1,
      disresponsiveList = room.alive_players,
    }
  end,
})
nuzhan:addEffect(fk.AfterSkillEffect, {
  can_refresh = function(self, _, target, player, data)
    return player:hasSkill(nuzhan.name) and player.phase == Player.NotActive and
      target and target ~= player and
      target:hasSkill(data.skill) and data.skill.visible and
      not player.room.logic:getCurrentEvent().n_jizhan_counted
  end,
  on_refresh = function(self, _, target, _, _)
    local room = target.room
    local cur = room.logic:getCurrentEvent()
    cur.n_jizhan_counted = true
    room:addPlayerMark(target, "@n_jizhan-turn", 1)
    if (target:getMark("@n_jizhan-turn") % 6 == 0) then
      cur.n_can_jizhan = true
    end
  end,
})
return nuzhan