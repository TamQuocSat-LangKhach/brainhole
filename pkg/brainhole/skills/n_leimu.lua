local n_leimu = fk.CreateSkill {
  name = "n_leimu",
  tags = { Skill.Compulsory, },
}

Fk:loadTranslationTable{
  ["n_leimu"] = "泪目",
  [":n_leimu"] = "锁定技，准备阶段，若你的体力值为全场最少，且你的体力上限小于7，你增加1点体力上限并回复1点体力。",
}

n_leimu:addEffect(fk.EventPhaseStart, {
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(n_leimu.name) and target == player and player.phase == Player.Start and player.maxHp < 7 then
      return not table.find(player.room.alive_players, function (p)
        return p.hp < player.hp
      end)
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:changeMaxHp(player, 1)
    if not player.dead and player:isWounded() then
      room:recover { num = 1, skillName = n_leimu.name, who = player, recoverBy = player}
    end
  end,
})

return n_leimu