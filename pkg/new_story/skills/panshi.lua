local panshi = fk.CreateSkill {
  name = "n_panshi",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["n_panshi"] = "叛弑",
  [":n_panshi"] = "锁定技，你使用的【杀】对“义父”造成伤害时，此伤害+1；若此时是你的出牌阶段，则你于【杀】结算结束后结束出牌阶段。",

  ["$n_panshi1"] = "我堂堂大丈夫，安肯为汝之义子？",
  ["$n_panshi2"] = "老贼！我与你势不两立！",
}

panshi:addEffect(fk.DamageCaused, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(panshi.name) and player == target then
      return data.to:getMark("@@n_yifu") > 0 and data.card.trueName =="slash" and not data.chain
    end
  end,
  on_use = function(self, event, target, player, data)
    data:changeDamage(1)
    if player.phase == Player.Play then
      player:endPlayPhase()
    end
  end,
})

return panshi