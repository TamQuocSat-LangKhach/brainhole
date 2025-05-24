local n_lianbian = fk.CreateSkill {
  name = "n_lianbian",
  tags = { Skill.Limited, },
}

Fk:loadTranslationTable{
  ["n_lianbian"] = "连鞭",
  [":n_lianbian"] = "限定技，出牌阶段，你可以弃置所有手牌并连续进行五次判定，每当判定结果为♠时，你对一名角色造成一点雷电伤害。",

  ["#n_lianbian-damage"] = "连鞭：对一名角色造成一点雷电伤害",

  ["$n_lianbian1"] = "下面，我打一个连五鞭啊。",
  ["$n_lianbian2"] = "一鞭。",
  ["$n_lianbian3"] = "两鞭。",
  ["$n_lianbian4"] = "三鞭。",
  ["$n_lianbian5"] = "四鞭。",
  ["$n_lianbian6"] = "五鞭。",
  ["$n_lianbian7"] = "打了五鞭。这五鞭要连续打",
}

n_lianbian:addEffect("active", {
  anim_type = "offensive",
  card_num = 0,
  target_num = 0,
  mute = true,
  card_filter = function() return false end,
  can_use = function(self, player)
    return player:usedSkillTimes(n_lianbian.name, Player.HistoryGame) == 0
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    player:broadcastSkillInvoke(n_lianbian.name, 1)
    room:notifySkillInvoked(player, n_lianbian.name)
    player:throwAllCards("h", n_lianbian.name)
    if player.dead then return end
    for i = 1, 5 do
      player:broadcastSkillInvoke(n_lianbian.name, i + 1)
      if player.dead then return end
      local judge = {
        who = player,
        reason = n_lianbian.name,
        pattern = ".|.|spade",
      }
      room:judge(judge)
      if judge:matchPattern() then
        local to = room:askToChoosePlayers(player, {
          min_num = 1,
          max_num = 1,
          targets = room.alive_players,
          skill_name = n_lianbian.name,
          prompt = "#n_lianbian-damage",
          cancelable = false,
        })[1]
        room:damage {
          from = player,
          to = to,
          damage = 1,
          skillName = n_lianbian.name,
          damageType = fk.ThunderDamage,
        }
      end
    end
    player:broadcastSkillInvoke(n_lianbian.name, 7)
  end,
})

return n_lianbian