local n_hunyuan = fk.CreateSkill {
  name = "n_hunyuan",
}

Fk:loadTranslationTable{
  ["n_hunyuan"] = "浑元",
  [":n_hunyuan"] = "你造成或受到伤害时，可改变伤害属性。你造成或受到伤害后，记录你造成或受到的这种属性伤害的伤害值，然后若记录的普通伤害→"..
  "雷属性伤害→火属性伤害这三种属性伤害值成等差数列，你可以摸一张牌并对一名角色造成一点伤害。",

  ["@n_hunyuan"] = "浑元",
  ["#n_hy-ask"] = "浑元：你可以对一名角色造成一点伤害",

  ["$n_hunyuan1"] = "一个左正蹬~（吭）",
  ["$n_hunyuan2"] = "一个右鞭腿！",
  ["$n_hunyuan3"] = "一个左刺拳。",
  ["$n_hunyuan4"] = "三维立体浑元劲，打出松果糖豆闪电鞭",
  ["$n_hunyuan5"] = "耗子尾汁。",
}

local spec1 = {
  anim_type = "offensive",
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(n_hunyuan.name) and
      player:getMark("n_hydmg1") - player:getMark("n_hydmg2") == player:getMark("n_hydmg2") - player:getMark("n_hydmg3")
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local to = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 1,
      targets = room.alive_players,
      skill_name = n_hunyuan.name,
      prompt = "#n_hy-ask",
      cancelable = true,
    })
    if #to > 0 then
      event:setCostData(self, {tos = to})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke(n_hunyuan.name, table.random{4, 5})
    player:drawCards(1, n_hunyuan.name)
    room:damage{
      from = player,
      to = event:getCostData(self).tos[1],
      damage = 1
    }
  end,

  can_refresh = function(self, event, target, player, data)
    return target == player and player:hasSkill(n_hunyuan.name)
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    room:addPlayerMark(player, "n_hydmg" .. data.damageType, data.damage)
    room:setPlayerMark(player, "@" .. n_hunyuan.name, string.format("%d普%d雷%d火",
      player:getMark("n_hydmg1"),
      player:getMark("n_hydmg2"),
      player:getMark("n_hydmg3")
    ))
  end,
}

n_hunyuan:addEffect(fk.Damage, spec1)
n_hunyuan:addEffect(fk.Damaged, spec1)

local spec2 = {
  anim_type = "offensive",
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(n_hunyuan.name)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local choices = { fk.NormalDamage, fk.ThunderDamage, fk.FireDamage, "Cancel" }
    table.removeOne(choices, data.damageType)
    local choice = room:askToChoice(player, {
      choices = choices,
      skill_name = n_hunyuan.name
    })
    if choice ~= "Cancel" then
      event:setCostData(self, {choice = choice})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local choice = event:getCostData(self).choice
    room:notifySkillInvoked(player, n_hunyuan.name)
    player:broadcastSkillInvoke(n_hunyuan.name, choice)
    data.damageType = choice
  end,
}

n_hunyuan:addEffect(fk.DamageCaused, spec2)
n_hunyuan:addEffect(fk.DamageInflicted, spec2)

return n_hunyuan