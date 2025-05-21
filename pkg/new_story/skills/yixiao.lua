local yixiao = fk.CreateSkill {

  name = "n_yixiao",

  tags = {},

}



yixiao:addEffect(fk.EventPhaseStart, {
  name = "n_yixiao",
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(yixiao.name) and player.phase == Player.Start and
        table.find(player.room.alive_players, function(p) return p ~= player and p:getMark("@@n_yifu") == 0 end)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local yifu = table.find(room.alive_players, function(p) return p:getMark("@@n_yifu") > 0 end)
    if yifu then
      local use = room:askToUseCard(target, {
        pattern = "slash",
        prompt = "#n_yixiao-use",
        cancelable = true,
        extra_data = {
          must_targets = { yifu.id },
          bypass_distances = true,
        },
        skill_name = yixiao.name
      })
      if use then
        event:setCostData(self, use)
        return true
      end
    else
      local tos = room:askToChoosePlayers(player, {
        targets = room:getOtherPlayers(player, false),
        max_num = 1,
        min_num = 1,
        prompt = "#n_yixiao-choose",
        skill_name = yixiao.name,
        cancelable = false,
      })
      if #tos > 0 then
        event:setCostData(self, tos)
        return true
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to
    if event:getCostData(self)[1] then
      to = event:getCostData(self)[1].id
    else
      local tgt = room:getPlayerById(event:getCostData(self).tos[1][1])
      room:notifySkillInvoked(tgt, yixiao.name, "negative")
      tgt:broadcastSkillInvoke(yixiao.name, table.random { 5, 6 })
      room:useCard(event:getCostData(self))
      to = room:askToChoosePlayers(player, {
        targets = table.filter(room:getOtherPlayers(player, false), function(p)
          return p:getMark("@@n_yifu") == 0 and p ~= player
        end),
        max_num = 1,
        min_num = 1,
        prompt = "#n_yixiao-move",
        skill_name = yixiao.name,
        cancelable = false,
      })[1].id
      room:setPlayerMark(tgt, "@@n_yifu", 0)
    end
    room:notifySkillInvoked(player, yixiao.name, "support")
    player:broadcastSkillInvoke(yixiao.name, table.random { 1, 2 })
    room:setPlayerMark(room:getPlayerById(to), "@@n_yifu", 1)
  end,
})

yixiao:addEffect(fk.EventPhaseStart, {
  name = "#n_yixiao_trig",
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return target.phase == Player.Play and player:hasSkill("n_yixiao") and target:getMark("@@n_yifu") > 0
  end,
  on_cost = function() return true end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:drawCards(1, "n_yixiao")
    local duel = Fk:cloneCard 'duel'
    duel.skillName = "n_yixiao"
    if player:prohibitUse(duel) then return end
    local targets = table.filter(room.alive_players, function(p)
      return player ~= p and not player:isProhibited(p, duel)
    end)
    if #targets == 0 then return end
    local to = room:askToChoosePlayers(target, {
      targets = targets,
      min_num = 1,
      max_num = 1,
      prompt = "#n_yixiao-duel",
      skill_name = "n_yixiao",
      cancelable = false
    })
    room:notifySkillInvoked(player, "n_yixiao", "offensive")
    player:broadcastSkillInvoke("n_yixiao", table.random { 3, 4 })
    room:useCard {
      from = player,
      tos = to,
      card = duel,
    }
  end,
})

return yixiao
