local jizhan = fk.CreateSkill {
  name = "n_jizhan",
}

Fk:loadTranslationTable{
  ["n_jizhan"] = "急斩",
  [":n_jizhan"] = "你的回合外，当其他角色于一回合内每发动六次技能后，你可以视为对其使用了一张不可响应的【杀】；若其未受伤，此【杀】伤害基数+1。",

  ["@n_jizhan-turn"] = "急斩",
  ["#n_jizhan-invoke"] = "急斩: 现在你可以视为对 %dest 使用一张强中的【杀】，可能有加伤",

  ["$n_jizhan"] = "纳命来！",
}

jizhan:addEffect(fk.AfterSkillEffect, {
  anim_type = "offensive",
  can_trigger = function(self, _, target, player, data)
    local slash = Fk:cloneCard 'slash'
    return player:hasSkill(jizhan.name) and player.phase == Player.NotActive and
      target and target ~= player and
      player.room.logic:getCurrentEvent().n_can_jizhan and
      not player:prohibitUse(slash) and
      not player:isProhibited(target, slash)
  end,
  on_cost = function(self, event, target, player, data)
     return player.room:askToSkillInvoke(player,{
      skill_name=jizhan.name,
      data=data,
      prompt="#n_jizhan-invoke::"..target.id
    })
  end,
  on_use = function(self, _, target, player, data)
    local room = player.room
    local slash = Fk:cloneCard 'slash'
    slash.skillName = jizhan.name
    room:useCard {
      from = player,
      tos = { target},
      card = slash,
      additionalDamage = target:isWounded() and 0 or 1,
      disresponsiveList = room.alive_players,
    }
  end,
})
jizhan:addEffect(fk.AfterSkillEffect, {
  can_refresh = function(self, _, target, player, data)
    return player:hasSkill(jizhan.name) and player.phase == Player.NotActive and
      target and target ~= player and
      table.contains(target:getSkillNameList(), data.skill:getSkeleton().name) and not data.skill.is_delay_effect and
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
return jizhan