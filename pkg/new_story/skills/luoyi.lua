local luoyi = fk.CreateSkill {

  name = "n_luoyi",

  tags = {  },

}



luoyi:addEffect(fk.DrawNCards, {
  name = 'n_luoyi',
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(luoyi.name) and data.n > 0
  end,
  on_use = function(self, event, target, player, data)
    data.n = data.n - 1
    player.room:addPlayerMark(player, "@@n_luoyi", 1)
  end,
})
luoyi:addEffect(fk.EventPhaseStart, {
  can_refresh = function(self, event, target, player, data)
    return target == player and player.phase == Player.RoundStart
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "@@n_luoyi", 0)
  end,
})
luoyi:addEffect(fk.DamageCaused, {
  name = "#n_luoyi_trigger",
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and not data.chain and data.card and
      ((player:getMark("@@n_luoyi") > 0 and (data.card.trueName == "slash" or data.card.name == "duel")) or
      (player:hasSkill(luoyi.name) and #player:getCardIds("e") == 0 and data.card.name == "slash"))
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke("n_luoyi")
    room:notifySkillInvoked(player, "n_luoyi")
    if player:getMark("@@n_luoyi") > 0 and (data.card.trueName == "slash" or data.card.name == "duel") then
      data.damage = data.damage + 1
    end
    if player:hasSkill(luoyi.name) and #player:getCardIds("e") == 0 and data.card.name == "slash" then
      data.damage = data.damage + 1
    end
  end,
})

return luoyi