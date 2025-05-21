local n_leimu = fk.CreateSkill {
  name = "n_leimu",
  tags = { Skill.Compulsory, },
}



n_leimu:addEffect(fk.EventPhaseStart, {
  name = "n_leimu",
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