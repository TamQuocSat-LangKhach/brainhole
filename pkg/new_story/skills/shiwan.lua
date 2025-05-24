local shiwan = fk.CreateSkill {
  name = "n_shiwan",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["n_shiwan"] = "十万",
  [":n_shiwan"] = "锁定技，当你的牌被其他角色获得后，若你的体力上限为全场最高，你摸一张牌并减1点体力上限。",
}

shiwan:addEffect(fk.AfterCardsMove, {
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