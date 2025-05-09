local chonggou = fk.CreateSkill{
  name = "n_chonggou",
}

Fk:loadTranslationTable{
  ["n_chonggou"] = "重构",
  [":n_chonggou"] = "结束阶段，你可以摸三张牌并弃三张牌，若本回合有被拷打的角色，其先执行此效果。",
}

chonggou:addEffect(fk.EventPhaseStart, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.phase == Player.Finish
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    for _, p in ipairs(room.alive_players) do
      if p:getMark("@@n_kaoda-turn") > 0 then
        p:drawCards(3, self.name)
        room:askForDiscard(p, 3, 3, true, self.name, false)
      end
    end
    player:drawCards(3, self.name)
    room:askForDiscard(player, 3, 3, true, self.name, false)
  end,
})

return chonggou
