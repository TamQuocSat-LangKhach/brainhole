local n_hunyuan = fk.CreateSkill {
  name = "n_hunyuan",
}

local on_use= function(self, event, target, player, data)
    local room = player.room
    room:notifySkillInvoked(player, n_hunyuan.name)
    if not (event == fk.Damage or event == fk.Damaged) then
      player:broadcastSkillInvoke(n_hunyuan.name,event:getCostData(self))
      data.damageType = event:getCostData(self)
    else
      player:broadcastSkillInvoke(n_hunyuan.name, table.random{4, 5})
      player:drawCards(1, n_hunyuan.name)
      room:damage{
        from = player,
        to = room:getPlayerById(event:getCostData(self)),
        damage = 1
      }
    end
  end

n_hunyuan:addEffect(fk.DamageCaused, {
  name = "n_hunyuan",
  anim_type = "offensive",
  mute = true,
  can_trigger = function(self, event, target, player, data)
    if not (target == player and player:hasSkill(n_hunyuan.name)) then return end
       return true
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
        local result = room:askForChoosePlayers(player, table.map(
        room:getAlivePlayers(),
        function(p)
          return p.id
        end
      ), 1, 1, "#n_hy-ask", n_hunyuan.name)
      if #result > 0 then
        event:setCostData(self, result[1])
        return true
      end
  end,
  on_use =on_use
})
n_hunyuan:addEffect(fk.DamageInflicted, {
  name = "n_hunyuan",
  anim_type = "offensive",
  mute = true,
  can_trigger = function(self, event, target, player, data)
    if not (target == player and player:hasSkill(n_hunyuan.name)) then return end
    if event == fk.Damage or event == fk.Damaged then
      return player:getMark("n_hydmg1") - player:getMark("n_hydmg2") ==
        player:getMark("n_hydmg2") - player:getMark("n_hydmg3")
    else
      return true
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    if not (event == fk.Damage or event == fk.Damaged) then
      local clist = {"n_toNormal", "n_toThunder", "n_toFire", "cancel"}
      local clist2 = {"n_toNormal", "n_toThunder", "n_toFire", "cancel"}
      if data.damageType < 3 then
        table.remove(clist, data.damageType)
      end
      local choice = room:askForChoice(player, clist, n_hunyuan.name)
      if choice ~= "cancel" then
        event:setCostData(self, table.indexOf(clist2), choice)
        return true
      end
    else
      local result = room:askForChoosePlayers(player, table.map(
        room:getAlivePlayers(),
        function(p)
          return p.id
        end
      ), 1, 1, "#n_hy-ask", n_hunyuan.name)
      if #result > 0 then
        event:setCostData(self, result[1])
        return true
      end
    end
  end,
  on_use = on_use
})
n_hunyuan:addEffect(fk.Damage, {
  name = "n_hunyuan",
  anim_type = "offensive",
  mute = true,
  can_trigger = function(self, event, target, player, data)
    if not (target == player and player:hasSkill(n_hunyuan.name)) then return end
    if event == fk.Damage or event == fk.Damaged then
      return player:getMark("n_hydmg1") - player:getMark("n_hydmg2") ==
        player:getMark("n_hydmg2") - player:getMark("n_hydmg3")
    else
      return true
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    if not (event == fk.Damage or event == fk.Damaged) then
      local clist = {"n_toNormal", "n_toThunder", "n_toFire", "cancel"}
      local clist2 = {"n_toNormal", "n_toThunder", "n_toFire", "cancel"}
      if data.damageType < 3 then
        table.remove(clist, data.damageType)
      end
      local choice = room:askForChoice(player, clist, n_hunyuan.name)
      if choice ~= "cancel" then
        event:setCostData(self, table.indexOf(clist2), choice)
        return true
      end
    else
      local result = room:askForChoosePlayers(player, table.map(
        room:getAlivePlayers(),
        function(p)
          return p.id
        end
      ), 1, 1, "#n_hy-ask", n_hunyuan.name)
      if #result > 0 then
        event:setCostData(self, result[1])
        return true
      end
    end
  end,
  on_use = on_use
})
n_hunyuan:addEffect(fk.Damaged, {
  name = "n_hunyuan",
  anim_type = "offensive",
  mute = true,
  can_trigger = function(self, event, target, player, data)
    if not (target == player and player:hasSkill(n_hunyuan.name)) then return end
    if event == fk.Damage or event == fk.Damaged then
      return player:getMark("n_hydmg1") - player:getMark("n_hydmg2") ==
        player:getMark("n_hydmg2") - player:getMark("n_hydmg3")
    else
      return true
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    if not (event == fk.Damage or event == fk.Damaged) then
      local clist = {"n_toNormal", "n_toThunder", "n_toFire", "cancel"}
      local clist2 = {"n_toNormal", "n_toThunder", "n_toFire", "cancel"}
      if data.damageType < 3 then
        table.remove(clist, data.damageType)
      end
      local choice = room:askForChoice(player, clist, n_hunyuan.name)
      if choice ~= "cancel" then
        event:setCostData(self, table.indexOf(clist2), choice)
        return true
      end
    else
      local result = room:askForChoosePlayers(player, table.map(
        room:getAlivePlayers(),
        function(p)
          return p.id
        end
      ), 1, 1, "#n_hy-ask", n_hunyuan.name)
      if #result > 0 then
        event:setCostData(self, result[1])
        return true
      end
    end
  end,
  on_use = on_use
})
n_hunyuan:addEffect(fk.Damage, {
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
})
n_hunyuan:addEffect(fk.Damaged, {
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
})

return n_hunyuan