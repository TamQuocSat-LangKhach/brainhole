local n_lingxiu = fk.CreateSkill {
  name = "n_lingxiu",
  tags = { Skill.Compulsory, },
}



n_lingxiu:addEffect(fk.AfterCardsMove, {
  name = "n_lingxiu",
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(n_lingxiu.name) then return end
    local room = player.room
    if #table.filter(room:getOtherPlayers(player, false), function(p)
      return #p:getCardIds(Player.Hand) > #player:getCardIds(Player.Hand)
    end) == 0 then return end
    for _, move in ipairs(data) do
      if move.to and move.to == player and move.toArea == Card.PlayerHand and move.skillName ~= n_lingxiu.name then
        return true
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    -- player.room:delay(240)
    local room = player.room
    local goal = 0
    for _, p in ipairs(room:getOtherPlayers(player, false)) do
      goal = math.max(goal, p:getHandcardNum())
    end
    player:drawCards(goal - player:getHandcardNum(), n_lingxiu.name)
  end,
})

return n_lingxiu