local n_juanlao = fk.CreateSkill {
  name = "n_juanlao",
}



n_juanlao:addEffect("viewas", {
  name = "n_juanlao",
  -- pattern = "nullification",
  enabled_at_play = function(self, player)
    if player:usedSkillTimes(n_juanlao.name, Player.HistoryPhase) > 0 then return end
    local cname = player:getMark("@[:]n_juanlao")
    if cname == 0 then return end
    return player:canUse(Fk:cloneCard(cname))
  end,
  enabled_at_response = function(self, player)
    -- FIXME: should have some way to know current response pattern here
    -- return player:getMark("@[:]n_juanlao") == "nullification"
    return false
  end,
  card_filter = function() return false end,
  view_as = function(self, player,cards)
    local cname = Self:getMark("@[:]n_juanlao")
    if cname == 0 then return end
    local ret = Fk:cloneCard(cname)
    return ret
  end,
})

n_juanlao:addEffect(fk.CardUseFinished, {
  can_refresh = function(self, event, target, player, data)
    if not (target == player and player:hasSkill(n_juanlao.name)) then return end
     return data.card.type == Card.TypeTrick and
        data.card.sub_type ~= Card.SubtypeDelayedTrick and
        (not data.card:isVirtual()) and
        player.phase ~= Player.NotActive 
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    local mark_name = "@[:]n_juanlao"
    room:setPlayerMark(player, mark_name, data.card.name)
  end,
})
n_juanlao:addEffect(fk.EventPhaseStart, {
  can_refresh = function(self, event, target, player, data)
    if not (target == player and player:hasSkill(n_juanlao.name)) then return end
    return player.phase == Player.Finish
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    local mark_name = "@[:]n_juanlao"
    room:setPlayerMark(player, mark_name, 0)
  end,
})

return n_juanlao