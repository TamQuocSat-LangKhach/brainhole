local lianbian = fk.CreateSkill{
  name = "n_lianbian",
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

lianbian:addEffect('active', {
  anim_type = "offensive",
  card_num = 0,
  target_num = 0,
  frequency = Skill.Limited,
  mute = true,
  card_filter = Util.FalseFunc,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryGame) == 0
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    player:broadcastSkillInvoke(self.name, 1)
    room:notifySkillInvoked(player, self.name)

    room:throwCard(player:getCardIds(Player.Hand), self.name, player, player)

    for i = 1, 5 do
      player:broadcastSkillInvoke(self.name, i + 1)
      if not player:isAlive() then return end
      local judge = {
        who = player,
        reason = self.name,
        pattern = ".|.|spade",
      }
      room:judge(judge)
      if judge.card.suit == Card.Spade then
        local targets = table.map(room.alive_players, Util.IdMapper)
        local tos = room:askForChoosePlayers(player, targets, 1, 1, "#n_lianbian-damage", self.name, false)
        room:damage {
          from = player, to = room:getPlayerById(tos[1]),
          damage = 1, skillName = self.name, damageType = fk.ThunderDamage,
        }
      end
    end
    player:broadcastSkillInvoke(self.name, 7)
  end,
})

return lianbian
