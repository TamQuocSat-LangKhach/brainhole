local relxSkill = fk.CreateSkill {
  name = "#n_relx_skill",
  tags = { Skill.Compulsory, },
  attached_equip = "n_relx_v",
}



relxSkill:addEffect(fk.TargetSpecified, {
  name = "#n_relx_skill",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(relxSkill.name) and
      data.card.type ~= Card.TypeEquip and
      data.firstTarget and
      not table.find(player:getCardIds(Player.Hand), function(cid)
        local c = Fk:getCardById(cid)
        return c.type == Card.TypeBasic and c.color == Card.Red
      end) and
      #data.tos > 0
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local x = #data:getAllTargets()
    room:notifySkillInvoked(player, "n_relx_v", "drawcard")
    player:drawCards(x, relxSkill.name)
    if x > 1 and player:isAlive() then room:damage { from = player, to = player, damage = 1, damageType = fk.ThunderDamage } end
  end,
})

return relxSkill