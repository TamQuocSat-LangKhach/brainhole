local qujing = fk.CreateSkill {

  name = "n_yunyou",

  tags = { Skill.Compulsory, },

}



qujing:addEffect(fk.EventPhaseStart, {
  name = "n_yunyou",
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(qujing.name)
      and player.phase == Player.Finish
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:swapSeat(player, player:getNextAlive()--[[ @as ServerPlayer[] ]])
  end,
})

return qujing