local n_cizhi = fk.CreateSkill {
  name = "n_cizhi",
}

Fk:loadTranslationTable{
  ["n_cizhi"] = "刺智",
  [":n_cizhi"] = "当你对一名角色造成伤害后，若你的体力值不大于其，则你可以对其造成1点伤害。",
}

n_cizhi:addEffect(fk.Damage, {
  name = "n_cizhi",
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(n_cizhi.name) and
      data.to:isAlive() and player.hp <= data.to.hp
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:damage {
      from = player,
      to = data.to,
      damage = 1,
    }
  end,
})

return n_cizhi