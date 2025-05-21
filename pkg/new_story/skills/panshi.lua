local panshi = fk.CreateSkill {

  name = "n_panshi",

  tags = { Skill.Compulsory, },

}



panshi:addEffect(fk.DamageCaused, {
  name = "n_panshi",
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(panshi.name) and player == target then
      return data.to:getMark("@@n_yifu") > 0 and data.card.trueName =="slash" and not data.chain
    end
  end,
  on_use = function(self, event, target, player, data)
    local logic = player.room.logic
    data.damage = data.damage + 1
    if player.phase == Player.Play then
      local current = logic:getCurrentEvent()
      local use_event = current:findParent(GameEvent.UseCard)
      if not use_event then return end
      local phase_event = use_event:findParent(GameEvent.Phase)
      if not phase_event then return end
      use_event:addExitFunc(function()
        phase_event:shutdown()
      end)
    end
  end,
})

return panshi