local yunyou = fk.CreateSkill {
  name = "n_yunyou",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["n_yunyou"] = "云游",
  [":n_yunyou"] = "锁定技，结束阶段，你与下家交换座位。",
}

yunyou:addEffect(fk.EventPhaseStart, {
  name = "n_yunyou",
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(yunyou.name)
      and player.phase == Player.Finish
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:swapSeat(player, player:getNextAlive()--[[ @as ServerPlayer[] ]])
  end,
})

return yunyou