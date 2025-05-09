local huanmeng = fk.CreateSkill{
  name = "n_huanmeng",
}

Fk:loadTranslationTable{
  ["n_huanmeng"] = "寰梦",
  [":n_huanmeng"] = "你受到伤害后，若你的体力值最低，可以摸一张牌并结束回合。",
  ["$n_huanmeng1"] = "（XP感叹号）",
  ["$n_huanmeng2"] = "（XP错误）",
  ["$n_huanmeng3"] = "（XP关键性终止）",
}

huanmeng:addEffect(fk.Damaged, {
  anim_type = "masochism",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and not table.find(player.room:getOtherPlayers(player, false), function(p)
      return p.hp < player.hp
    end)
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askForSkillInvoke(player, self.name, nil, "#n_huanmeng-invoke")
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    -- player:broadcastSkillInvoke(self.name)
    -- room:notifySkillInvoked(player, self.name)
    player:drawCards(1, self.name)
    room.logic:breakTurn()
  end,
})

return huanmeng
