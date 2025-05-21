local jijiu = fk.CreateSkill {
  name = "n_jijiu",
}



jijiu:addEffect("viewas", {
  anim_type = "support",
  pattern = "peach",
  card_filter = function(self, player, to_select, selected)
    if #selected == 1 then return false end
    return Fk:getCardById(to_select).color == Card.Red
  end,
  view_as = function(self, cards)
    if #cards ~= 1 then
      return nil
    end
    local c = Fk:cloneCard("peach")
    c.skillName = jijiu.name
    c:addSubcard(cards[1])
    return c
  end,
  enabled_at_play = Util.FalseFunc,
  enabled_at_response = function(self, player, res)
    return player.phase == Player.NotActive and not res
  end,
})

jijiu:addEffect(fk.EnterDying, {
  name = "#n_jijiu_trigger",
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(jijiu.name) and target ~= player and
      not player:prohibitUse(Fk:cloneCard("peach")) and
      not player:isProhibited(target, Fk:cloneCard("peach"))
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    local peach_use = room:askToUseCard(player,{
      pattern="peach",
      prompt="#n_jijiu-use::" .. target.id,
      cancelable=true,
      extra_data={analepticRecover = true, must_targets = { target.id }, fix_targets = { target.id }},
      skill_name=jijiu.name,
    })
    if not peach_use then return end
    peach_use.tos = { target }
    event:setCostData(self,peach_use)
    return true
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:useCard(event:getCostData(self))
  end,
})

return jijiu