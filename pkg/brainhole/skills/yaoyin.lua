local yaoyin = fk.CreateSkill {
  name = "n_yaoyin",
  tags = { Skill.Limited, },
}

Fk:loadTranslationTable{
  ["n_yaoyin"] = "邀饮",
  [":n_yaoyin"] = "限定技，出牌阶段，你可以失去1点体力并交给一名其他角色一张手牌（不能是你的上家），令其与你的上家交换座位，"..
  "然后你视为对你和你的上家使用一张【酒】。",

  ["$n_yaoyin1"] = "我一个人住，我的房子还蛮大的，欢迎你们来我家玩。",
  ["$n_yaoyin2"] = "如果要来的话，我可以带你们去超商，买一些好吃的哦。",
}

yaoyin:addEffect("active", {
  anim_type = "control",
  card_num = 1,
  target_num = 1,
  card_filter = function(self, player, to_select, selected)
    return #selected == 0 and Fk:currentRoom():getCardArea(to_select) ~= Card.PlayerEquip
  end,
  target_filter = function(self, player, to_select, selected)
    return #selected == 0 and to_select ~= player and to_select:getNextAlive() ~= player
  end,
  can_use = function(self, player)
    return player:usedSkillTimes(yaoyin.name, Player.HistoryGame) == 0
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    local card = effect.cards[1]
    room:loseHp(player, 1, yaoyin.name)
    if player.dead then return end
    room:obtainCard(target, card, false, fk.ReasonGive)
    local prev = player:getLastAlive() --[[ @as ServerPlayer ]]
    room:swapSeat(prev, target)
    room:useVirtualCard("analeptic", nil, player, {player, target}, yaoyin.name, true)
  end,
})

return yaoyin