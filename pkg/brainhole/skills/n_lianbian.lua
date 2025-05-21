local n_lianbian = fk.CreateSkill {
  name = "n_lianbian",
  tags = { Skill.Limited, },
}



n_lianbian:addEffect("active", {
  name = "n_lianbian",
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
    room:throwCard(player:getCardIds(Player.Hand), n_lianbian.name, player, player)
    for i = 1, 5 do
      player:broadcastSkillInvoke(n_lianbian.name, i + 1)
      if not player:isAlive() then return end
      local judge = {
        who = player,
        reason = n_lianbian.name,
        pattern = ".|.|spade",
      }
      room:judge(judge)
      if judge.card.suit == Card.Spade then
        local targets = table.map(room.alive_players, Util.IdMapper)
        local tos = room:askForChoosePlayers(player, targets, 1, 1, "#n_lianbian-damage", n_lianbian.name, false)
        room:damage {
          from = player, to = room:getPlayerById(tos[1]),
          damage = 1, skillName = n_lianbian.name, damageType = fk.ThunderDamage,
        }
      end
    end
    player:broadcastSkillInvoke(n_lianbian.name, 7)
  end,
})

return n_lianbian