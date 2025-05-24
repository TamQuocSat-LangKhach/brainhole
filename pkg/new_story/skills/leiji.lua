local leiji = fk.CreateSkill {
  name = "n_leiji",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["n_leiji"] = "雷祭",
  [":n_leiji"] = "锁定技，当一名角色的判定结果确定后：<br>"..
  "♠，其进行一次【闪电】的判定；<br>"..
  "<font color='red'>♥</font>，你获得判定牌；<br>"..
  "♣：其受到1点雷属性伤害；<br>"..
  "<font color='red'>♦</font>：其摸一张牌。<br>"..
  "你受到伤害后，令伤害来源判定；你使用黑色牌指定目标后，令所有目标进行判定。",

  ["$n_leiji1"] = "天非苍苍之天，岂照昏昏之路？",
  ["$n_leiji2"] = "承景灵之冥符，拟血积而荡秽。",
  ["$n_leiji3"] = "天雷无妄，天诛难免！",
  ["$n_leiji4"] = "阐道法、施符水，天地秀气当为人用。",
  ["$n_leiji5"] = "金蛇乱掣，电母生嗔！",
  ["$n_leiji6"] = "饥则食、冷则衣，小儿之理大人不知！",
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
