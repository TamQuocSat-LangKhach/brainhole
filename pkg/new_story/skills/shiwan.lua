local shiwan = fk.CreateSkill {

  name = "n_shiwan",

  tags = { Skill.Compulsory, },

}



shiwan:addEffect(fk.AfterCardsMove, {
  name = "n_shiwan",
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(shiwan.name) then return false end
    local room = player.room
    if table.find(room.alive_players, function(p)
      return p ~= player and p.maxHp > player.maxHp
    end) then return end
    for _, move in ipairs(data) do
      if move.from == player and move.to and move.to ~= player and move.moveReason == fk.ReasonPrey then
        for _, info in ipairs(move.moveInfo) do
          if info.fromArea == Card.PlayerEquip or info.fromArea == Card.PlayerHand then
            return true
          end
        end
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:drawCards(1, shiwan.name)
    room:changeMaxHp(player, -1)
  end,
})

return shiwan