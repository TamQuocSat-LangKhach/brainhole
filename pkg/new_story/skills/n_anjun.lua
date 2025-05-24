local n_anjun = fk.CreateSkill {
  name = "n_anjun",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["n_anjun"] = "安军",
  [":n_anjun"] = "锁定技，若你没有“粮”，曹操或者主公对你造成的伤害+1。",
}

n_anjun:addEffect(fk.DamageCaused, {
  anim_type = "negative",
  can_trigger = function(self, event, target, player, data)
    return data.to == player and player:hasSkill(n_anjun.name) and #player:getPile("n_liang") == 0 and
    target and (table.contains({"caocao", "godcaocao"}, Fk.generals[target.general].trueName) or target.role == "lord"
    or (target.deputyGeneral ~= "" and table.contains({"caocao", "godcaocao"}, Fk.generals[target.deputyGeneral].trueName)))
  end,
  on_use = function(self, event, target, player, data)
    data:changeDamage(1)
  end,
})

return n_anjun