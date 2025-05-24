local rulai = fk.CreateSkill {
  name = "n_rulai",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["n_rulai"] = "如来",
  [":n_rulai"] = "锁定技，当【杀】结算结束后，若其对某些目标无效或者被抵消，你摸一张牌。",

  ["$n_rulai1"] = "真来了吗？如~来。",
  ["$n_rulai2"] = "到底来没来？如~来。",
}

rulai:addEffect(fk.CardUseFinished, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(rulai.name) then return end
    if data.card.trueName ~= "slash" then return end
    local room = player.room
    if #data.tos == 0 or (data.nullifiedTargets and #data.nullifiedTargets > 0) then return true end
    local cur = room.logic:getCurrentEvent()
    if cur.interrupted then return true end
    local effects = cur:searchEvents(GameEvent.CardEffect, math.huge, Util.TrueFunc)
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