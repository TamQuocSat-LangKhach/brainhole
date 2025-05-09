local juanlao = fk.CreateSkill{
  name = "n_juanlao",
}

Fk:loadTranslationTable {
  ["n_juanlao"] = "奆佬",
  ["@[:]n_juanlao-turn"] = "奆佬",
  [":n_juanlao"] = "出牌阶段限一次，你可以视为使用了本回合你使用过的" ..
    "上一张非转化普通锦囊牌。",
}

juanlao:addEffect('viewas', {
  name = "n_juanlao",
  enabled_at_play = function(self, player)
    if player:usedSkillTimes(juanlao.name, Player.HistoryPhase) > 0 then return end
    local cname = player:getMark("@[:]n_juanlao-turn")
    if cname == 0 then return end
    return player:canUse(Fk:cloneCard(cname))
  end,
  enabled_at_response = function(self, player)
    -- FIXME: should have some way to know current response pattern here
    -- return player:getMark("@[:]n_juanlao-turn") == "nullification"
    return false
  end,

  card_filter = Util.FalseFunc,
  view_as = function(self, player, cards)
    local cname = player:getMark("@[:]n_juanlao-turn")
    if cname == 0 then return end
    local ret = Fk:cloneCard(cname)
    return ret
  end,
})

juanlao:addEffect(fk.CardUseFinished, {
  can_refresh = function(self, event, target, player, data)
    if not (target == player and player:hasSkill(self)) then return end
    return data.card.type == Card.TypeTrick and
      data.card.sub_type ~= Card.SubtypeDelayedTrick and
      (not data.card:isVirtual()) and
      player.phase ~= Player.NotActive
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    local mark_name = "@[:]n_juanlao-turn"
    room:setPlayerMark(player, mark_name, data.card.name)
  end,
})

juanlao:addTest(function(room, me)
  local exnihilo = room:printCard("ex_nihilo", Card.Heart, 7)
  FkTest.setRoomBreakpoint(me, "PlayCard")
  FkTest.runInRoom(function()
    room:handleAddLoseSkills(me, juanlao.name)
    room:obtainCard(me, exnihilo)
    me:gainAnExtraTurn(false, "", { who = me, reason = "", phase_table = { Player.Play } })
  end)

  FkTest.setNextReplies(me, { json.encode { card = exnihilo.id } })
  FkTest.setRoomBreakpoint(me, "PlayCard")
  FkTest.resumeRoom()
  lu.assertEquals(me:getMark("@[:]n_juanlao-turn"), "ex_nihilo")
  FkTest.setNextReplies(me, { json.encode { card = { skill = juanlao.name } } })
  FkTest.resumeRoom()
  lu.assertEquals(#me:getCardIds('h'), 4)
end)

return juanlao
