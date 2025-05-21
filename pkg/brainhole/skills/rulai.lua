local rulai = fk.CreateSkill {
  name = "n_rulai",
  tags = { Skill.Compulsory, },
}



rulai:addEffect(fk.CardUseFinished, {
  name = "n_rulai",
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(rulai.name) then return end
    if data.card.trueName ~= "slash" then return end
    local room = player.room
    if #data.tos == 0 or (data.nullifiedTargets and #data.nullifiedTargets > 0) then return true end
    local cur = room.logic:getCurrentEvent()
    if cur.interrupted then return true end
    local effects = cur:searchEvents(GameEvent.CardEffect, math.huge)
    for _, e in ipairs(effects) do
      if e.data.isCancellOut or (e.interrupted and not e.data.to.dead) then
        return true
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(1, rulai.name)
  end,
})

return rulai