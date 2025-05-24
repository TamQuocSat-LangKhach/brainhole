local luoyi = fk.CreateSkill {
  name = "n_luoyi",
}

Fk:loadTranslationTable{
  ["n_luoyi"] = "裸衣",
  [":n_luoyi"] = "摸牌阶段，你可以少摸一张牌，若如此做，直到你的下回合开始，你使用的【杀】或【决斗】造成的伤害+1；"..
  "若你装备区里没有牌，你的普通【杀】造成的伤害+1。",

  ["@@n_luoyi"] = "裸衣",

  ["$n_luoyi1"] = "哈哈哈哈哈哈，来送死的吧！",
  ["$n_luoyi2"] = "这一招如何！",
}

luoyi:addEffect(fk.DrawNCards, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(luoyi.name) and data.n > 0
  end,
  on_use = function(self, event, target, player, data)
    data.n = data.n - 1
    player.room:addPlayerMark(player, "@@n_luoyi", 1)
  end,
})
luoyi:addEffect(fk.TurnStart, {
  can_refresh = function(self, event, target, player, data)
    return target == player
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "@@n_luoyi", 0)
  end,
})
luoyi:addEffect(fk.DamageCaused, {
  anim_type = "offensive",
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and not data.chain and data.card and
      ((player:getMark("@@n_luoyi") > 0 and (data.card.trueName == "slash" or data.card.name == "duel")) or
      (player:hasSkill(luoyi.name) and #player:getCardIds("e") == 0 and data.card.name == "slash"))
  end,
  on_use = function(self, event, target, player, data)
    if player:getMark("@@n_luoyi") > 0 and (data.card.trueName == "slash" or data.card.name == "duel") then
      data:changeDamage(1)
    end
    if player:hasSkill(luoyi.name) and #player:getCardIds("e") == 0 and data.card.name == "slash" then
      data:changeDamage(1)
    end
  end,
})

return luoyi