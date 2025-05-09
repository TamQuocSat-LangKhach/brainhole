local yegeng = fk.CreateSkill{
  name = "n_yegeng",
}

Fk:loadTranslationTable{
  ["n_yegeng"] = "夜更",
  ["@n_yegeng"] = "夜更",
  [":n_yegeng"] = "锁定技，结束阶段，若你本回合使用普通锦囊牌数量不小于3+X，" ..
    "你进行一个额外的回合，否则你摸一张牌。（X为你本轮内发动过该技能的次数）",
}

local mark_name = "@n_yegeng"

yegeng:addEffect(fk.EventPhaseStart, {
  anim_type = "drawcard",
  frequency = Skill.Compulsory,
  can_trigger = function(self, event, target, player, data)
    local ret =  target == player and player:hasSkill(yegeng.name) and
      player.phase == Player.Finish
    return ret
  end,
  on_use = function(self, event, target, player, data)
    if player:getMark("n_yegeng-turn") ~= 0 then
      player:gainAnExtraTurn()
    else
      player:drawCards(1, self.name)
    end
  end,

  can_refresh = function(self, event, target, player, data)
    if not (target == player and player:hasSkill(yegeng.name)) then return end
    return player.phase == Player.Finish
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    room:setPlayerMark(player, "n_yegeng-turn",
      (player:getMark(mark_name) >= 3 + player:usedSkillTimes(yegeng.name, Player.HistoryRound)) and 1 or 0)
    room:setPlayerMark(player, mark_name, 0)
  end,
})

yegeng:addEffect(fk.CardUseFinished, {
  can_refresh = function(self, event, target, player, data)
    if not (target == player and player:hasSkill(yegeng.name)) then return end
    return data.card.type == Card.TypeTrick and
      data.card.sub_type ~= Card.SubtypeDelayedTrick and
      player.phase ~= Player.NotActive
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:addPlayerMark(player, mark_name, 1)
  end
})

yegeng:addTest(function(room, me)
  local exnihilo = room:printCard("ex_nihilo", Card.Heart, 7)
  local exnihilo2 = room:printCard("ex_nihilo", Card.Heart, 7)
  local exnihilo3 = room:printCard("ex_nihilo", Card.Heart, 7)
  local snatch = room:printCard("snatch", Card.Spade, 9)
  local snatch2 = room:printCard("snatch", Card.Spade, 9)
  local snatch3 = room:printCard("snatch", Card.Spade, 9)
  local comp2 = room.players[2]
  local cards
  FkTest.setNextReplies(me, {
    json.encode { card = exnihilo.id },
    json.encode { card = exnihilo2.id },
    json.encode { card = exnihilo3.id },
    "",
    json.encode { card = snatch.id, targets = { comp2.id } },
  })
  FkTest.setRoomBreakpoint(me, "AskForCardChosen")
  FkTest.runInRoom(function()
    cards = comp2:drawCards(3)
    room:handleAddLoseSkills(me, yegeng.name)
    room:obtainCard(me, { exnihilo, exnihilo2, exnihilo3 })
    me:gainAnExtraTurn(false, "", { who = me, reason = "",
      phase_table = { Player.Play, Player.Finish } })
  end)
  FkTest.setNextReplies(me, {
    tostring(cards[1]),
    json.encode { card = snatch2.id, targets = { comp2.id } },
    tostring(cards[2]),
    json.encode { card = snatch3.id, targets = { comp2.id } },
    tostring(cards[3]),
  })
  FkTest.resumeRoom()
  lu.assertEquals(#me:getCardIds("h"), 5)
  lu.assertEquals(me:usedSkillTimes(yegeng.name, Player.HistoryGame), 2)
end)

return yegeng
