local kuiping = fk.CreateSkill {
  name = "n_kuiping",
  tags = { Skill.Compulsory, },
}

Fk:loadTranslationTable {
  ["n_kuiping"] = "窥屏",
  [":n_kuiping"] = "锁定技，一号位获得的牌对你可见。",
}

kuiping:addEffect('visibility', {
  card_visible = function(self, player, card)
    if player:hasSkill(self) then
      local owner = Fk:currentRoom():getCardOwner(card.id)
      if owner and owner.seat == 1 then
        return true
      end
    end
  end,
})

return kuiping
