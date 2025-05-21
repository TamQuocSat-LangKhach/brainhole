local fuji = fk.CreateSkill {
  name = "n_fuji",
}



fuji:addEffect(fk.CardUseFinished, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    if not (target == player and player:hasSkill(fuji.name)) then return end
    local card = data.card
    local room = player.room
    if card:isVirtual() then return end
    local owner = room:getCardOwner(data.card.id)
    return owner == nil or owner == player
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local to=room:askToChoosePlayers(player,{
      targets=room.alive_players,
      min_num=1,
      max_num=1,
      prompt="#n_fuji-card:::"..data.card:toLogString(),
      skill_name=fuji.name,
      cancelable=true,
    })
    if #to > 0 then
      event:setCostData(self,to[1])
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cards = Card:getIdList(data.card)
    local to = event:getCostData(self)
    room:moveCardTo(cards, Card.PlayerHand, to, fk.ReasonGive, fuji.name, nil, true, player)
    room:askToDiscard(to,{
      min_num=1,
      max_num=1,
      skill_name=fuji.name,
      include_equip=true,
      cancelable=false,
    })
    if to == player then room:invalidateSkill(player, fuji.name, "-turn") end
  end,
})

return fuji