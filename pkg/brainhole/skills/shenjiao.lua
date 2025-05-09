local shenjiao = fk.CreateSkill{
  name = "n_shenjiao",
}

Fk:loadTranslationTable{
  ["n_shenjiao"] = "神饺",
  ["#n_shenjiao-invoke"] = "神饺：你可以弃置一枚“饺”来为 %dest 回复一点体力",
  [":n_shenjiao"] = "出牌阶段，你可以弃置一枚“饺”标记并摸两张牌；一名其他角色进入濒死状态时，你可以弃置一枚“饺”标记，令其回复一点体力。",
}

shenjiao:addEffect('active', {
  anim_type = "drawcard",
  can_use = function (self, player, card)
    return player:getMark("@n_jiao") > 0
  end,
  card_num = 0,
  target_num = 0,
  card_filter = function() return false end,
  on_use = function (self, room, effect)
    local from = effect.from
    room:removePlayerMark(from, "@n_jiao", 1)
    from:drawCards(2, shenjiao.name)
  end
})

shenjiao:addEffect(fk.EnterDying, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return player ~= target and player:hasSkill("n_shenjiao") and player:getMark("@n_jiao") > 0
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askForSkillInvoke(player, "n_shenjiao", data, "#n_shenjiao-invoke::"..target.id)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:removePlayerMark(player, "@n_jiao", 1)
    room:doIndicate(player.id, { target.id })
    room:recover{
      who = target,
      num = 1,
      recoverBy = player,
      skillName = self.name
    }
  end,
})

return shenjiao
