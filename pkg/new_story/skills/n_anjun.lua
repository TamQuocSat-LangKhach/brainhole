local n_anjun = fk.CreateSkill {

  name = "n_anjun",

  tags = { Skill.Compulsory, },

}



n_anjun:addEffect(fk.DamageCaused, {
  name = "n_anjun",
  anim_type = "negative",
  can_trigger = function(self, event, target, player, data)
    return data.to == player and player:hasSkill(n_anjun.name) and #player:getPile("n_liang") == 0 and
    target and (table.contains({"caocao", "godcaocao"}, Fk.generals[target.general].trueName) or target.role == "lord"
    or (target.deputyGeneral ~= "" and table.contains({"caocao", "godcaocao"}, Fk.generals[target.deputyGeneral].trueName)))
  end,
  on_use = function(self, event, target, player, data)
    data.damage = data.damage + 1
  end,
})

return n_anjun