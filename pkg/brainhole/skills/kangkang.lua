local kangkang = fk.CreateSkill {
  name = "n_kangkang",
}

Fk:loadTranslationTable{
  ["n_kangkang"] = "康康",
  [":n_kangkang"] = "每回合限两次，当你对你的上家或下家造成伤害时，你可以观看其手牌并获得其中一张。",

  ["$n_kangkang1"] = "哎呦，你脸红了？来，让我康康~",
  ["$n_kangkang2"] = "听话！让我康康！",
}

kangkang:addEffect(fk.DamageCaused, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(kangkang.name) and not data.to:isKongcheng() and
      (data.to == player:getNextAlive() or data.to:getNextAlive() == player) and
      player:usedSkillTimes(kangkang.name, Player.HistoryTurn) < 2
  end,
  on_use = function(self, event, _, player, data)
    local room = player.room
    local target = data.to
    local card = room:askToChooseCard(player, {
      target = target,
      flag = { card_data = {{ target.general, target:getCardIds("h") }} },
      skill_name = kangkang.name,
    })
    room:obtainCard(player, card, false, fk.ReasonPrey)
  end,
})

return kangkang