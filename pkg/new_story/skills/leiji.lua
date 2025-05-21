local leiji = fk.CreateSkill {

  name = "n_leiji",

  tags = { Skill.Compulsory, },

}



leiji:addEffect(fk.FinishJudge, {
  name = 'n_leiji',
  mute = true,
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(leiji.name) then return end
    local room = player.room
    if target.dead then return end
    return data.card.suit ~= Card.Heart or room:getCardOwner(data.card) == nil
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if data.card.suit == Card.Spade then
      player:broadcastSkillInvoke(leiji.name, 3)
      room:notifySkillInvoked(player, leiji.name, "offensive")
      local pattern = ".|2~9|spade"
      local judge = {
        who = target,
        reason = "lightning",
        pattern = pattern,
      }
      room:judge(judge)
      if judge.card:matchPattern(pattern) then
        room:damage {
          to = target,
          damage = 3,
          damageType = fk.ThunderDamage,
          skillName = leiji.name,
        }
      end
    elseif data.card.suit == Card.Heart then
      player:broadcastSkillInvoke(leiji.name, 4)
      room:notifySkillInvoked(player, leiji.name, "drawcard")
      room:obtainCard(player, data.card, true, fk.ReasonJustMove, nil, leiji.name)
    elseif data.card.suit == Card.Club then
      player:broadcastSkillInvoke(leiji.name, 5)
      room:notifySkillInvoked(player, leiji.name, "offensive")
      room:damage {
        to = target,
        damage = 1,
        damageType = fk.ThunderDamage,
        skillName = leiji.name,
      }
    elseif data.card.suit == Card.Diamond then
      player:broadcastSkillInvoke(leiji.name, 6)
      room:notifySkillInvoked(player, leiji.name, "support")
      target:drawCards(1, leiji.name)
    end
  end,
})
leiji:addEffect(fk.Damaged, {
  name = 'n_leiji',
  mute = true,
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(leiji.name) then return end
    local room = player.room
    return target == player and data.from ~= nil
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke(leiji.name, math.random(1, 2))
    room:notifySkillInvoked(player, leiji.name, "offensive")
    room:judge {
      who = data.from,
      reason = leiji.name,
      pattern = ".",
    }
  end,
})
leiji:addEffect(fk.TargetSpecified, {
  name = 'n_leiji',
  mute = true,
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(leiji.name) then return end
    local room = player.room
    return target == player and data.card.color == Card.Black
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
     player:broadcastSkillInvoke(leiji.name, math.random(1, 2))
      room:notifySkillInvoked(player, leiji.name, "offensive")
      room:judge {
        who = data.to,
        reason = leiji.name,
        pattern = ".",
      }
  end,
})

return leiji
