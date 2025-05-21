local n_pengji = fk.CreateSkill {
  name = "n_pengji",
}



n_pengji:addEffect(fk.AfterCardsMove, {
  name = "n_pengji",
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(n_pengji.name) then return end
    if player:getMark("n_songji-phase") > 0 then return end
    for _, move in ipairs(data) do
      if move.to == player and move.moveReason == fk.ReasonDraw
        and move.skillName ~= n_pengji.name then
        return true
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local result, dat = room:askForUseActiveSkill(player, "n_pengji_ac",
      "@n_pengji", true)
    if result and dat then
      event:setCostData(self, dat.cards)
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cards = event:getCostData(self)
    room:setPlayerMark(player, "n_pengji_dis", cards)
    room:throwCard(cards, n_pengji.name, player)
    player:drawCards(#cards, n_pengji.name)
  end,
})

return n_pengji