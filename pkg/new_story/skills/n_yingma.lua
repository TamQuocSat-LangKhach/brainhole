local n_yingma = fk.CreateSkill {
  name = "n_yingma",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["n_yingma"] = "赢麻",
  [":n_yingma"] = "锁定技，准备阶段，若你体力上限小于7，加1点上限。",
}

n_yingma:addEffect(fk.EventPhaseStart, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(n_yingma.name) and player.phase == Player.Start and player.maxHp < 7
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:changeMaxHp(player, 1)
  end,
})

return n_yingma