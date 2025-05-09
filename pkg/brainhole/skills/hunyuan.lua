local hunyuan = fk.CreateSkill{
  name = "n_hunyuan",
}

Fk:loadTranslationTable{
  ["n_hunyuan"] = "浑元",
  ["@n_hunyuan"] = "浑元",
  [":n_hunyuan"] = "你造成或受到伤害时，可改变伤害属性。" ..
    "你造成或受到伤害后，记录你造成或受到的这种属性伤害的伤害值，" ..
    "然后若记录的普通伤害→雷属性伤害→火属性伤害这三种属性伤害值成等差数列，" ..
    "你可以摸一张牌并对一名角色造成一点伤害。",
  ["n_toFire"] = "转换成火属性伤害",
  ["n_toThunder"] = "转换成雷属性伤害",
  ["n_toNormal"] = "转换成无属性伤害",
  ["#n_hy-ask"] = "浑元：你可以对一名角色造成一点伤害",
  ["$n_hunyuan1"] = "一个左正蹬~（吭）",
  ["$n_hunyuan2"] = "一个右鞭腿！",
  ["$n_hunyuan3"] = "一个左刺拳。",
  ["$n_hunyuan4"] = "三维立体浑元劲，打出松果糖豆闪电鞭",
  ["$n_hunyuan5"] = "耗子尾汁。",
}

---@type TrigSkelSpec<DamageTrigFunc>
local dmg_tab = {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    if not (target == player and player:hasSkill(self)) then return end
    return player:getMark("n_hydmg1") - player:getMark("n_hydmg2") ==
      player:getMark("n_hydmg2") - player:getMark("n_hydmg3")
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local result = room:askForChoosePlayers(player, table.map(
      room:getAlivePlayers(),
      function(p)
        return p.id
      end
    ), 1, 1, "#n_hy-ask", self.name)
    if #result > 0 then
      self.cost_data = result[1]
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:notifySkillInvoked(player, self.name)
    player:broadcastSkillInvoke(self.name, table.random{4, 5})
    player:drawCards(1, self.name)
    room:damage{
      from = player,
      to = room:getPlayerById(self.cost_data),
      damage = 1
    }
  end,

  can_refresh = function(self, event, target, player, data)
    return target == player and player:hasSkill(self)
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    room:addPlayerMark(player, "n_hydmg" .. data.damageType, data.damage)
    room:setPlayerMark(player, "@" .. self.name, string.format("%d普%d雷%d火",
      player:getMark("n_hydmg1"),
      player:getMark("n_hydmg2"),
      player:getMark("n_hydmg3")
    ))
  end,
}

---@type TrigSkelSpec<DamageTrigFunc>
local dmg_tab2 = {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local clist = {"n_toNormal", "n_toThunder", "n_toFire", "cancel"}
    local clist2 = {"n_toNormal", "n_toThunder", "n_toFire", "cancel"}
    if data.damageType < 3 then
      table.remove(clist, data.damageType)
    end
    local choice = room:askForChoice(player, clist, self.name)
    if choice ~= "cancel" then
      self.cost_data = table.indexOf(clist2, choice)
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:notifySkillInvoked(player, self.name)
    player:broadcastSkillInvoke(self.name, self.cost_data)
    data.damageType = self.cost_data
  end,
}

hunyuan:addEffect(fk.Damage, dmg_tab)
hunyuan:addEffect(fk.Damaged, dmg_tab)
hunyuan:addEffect(fk.DamageCaused, dmg_tab2)
hunyuan:addEffect(fk.DamageInflicted, dmg_tab2)

return hunyuan
