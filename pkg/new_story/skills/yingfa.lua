local yingfa = fk.CreateSkill {
  name = "n_yingfa",
}

Fk:loadTranslationTable{
  ["n_yingfa"] = "赢伐",
  [":n_yingfa"] = "结束阶段，若张辽在场且存活，你升级“制衡”；出牌阶段限X次，你可以将一名不是张辽的其他角色的副将替换为随机张辽"..
  "直到你受到伤害或死亡。（X为你升级过“制衡”的次数+1）<br><font color=>※随机张辽：就是各种版本的张辽，包括神张辽，但不包括国战张辽。<br>"..
  "※升级“制衡”：若没有制衡则获得标准版制衡，否则替换成增强版制衡（标->界->经典->会玩）；若已拥有“会玩”则升级失败，摸一张牌。</font>",

  ["#n_yingfa-active"] = "赢伐：请召唤张辽！",
}

yingfa:addEffect("active", {
  anim_type = "control",
  prompt = "#n_yingfa-active",
  max_card_num = 0,
  target_num = 1,
  can_use = function(self, player)
    local x = player:getMark("n_yingfa_levelup") + 1
    return player:usedSkillTimes(yingfa.name, Player.HistoryPhase) < x
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected)
    if #selected > 0 or to_select == Self.id then return end
    local to = to_select
    return not string.find(to.general, "zhangliao") and not string.find(to.deputyGeneral, "zhangliao")
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    local dads = table.simpleClone(Fk.same_generals["zhangliao"])
    table.removeOne(dads, "hs__zhangliao")
    table.insert(dads, "godzhangliao")
    for _, p in ipairs(room.players) do
      table.removeOne(dads, p.general)
      if p.deputyGeneral ~= "" then table.removeOne(dads, p.deputyGeneral) end
    end
    if #dads == 0 then return end
    local dad = table.random(dads)
    local mark = player:getTableMark("n_yingfa_target")
    table.insertIfNeed(mark, {target.id, target.deputyGeneral})
    room:setPlayerMark(player, "n_yingfa_target", mark)
    room:changeHero(target, dad, false, true, true, false)
  end,
})

yingfa:addEffect(fk.EventPhaseStart, {
  can_trigger = function (self, event, target, player, data)
    if target == player and player:hasSkill("n_yingfa") and player.phase == Player.Finish then
      return table.find(player.room.alive_players, function (p)
        return string.find(p.general, "zhangliao")~=nil or string.find(p.deputyGeneral, "zhangliao")~=nil
      end)
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local skills = {"hs__zhiheng", "zhiheng", "ex__zhiheng", "tycl__zhiheng", "n_huiwan"}
    local index = -1
    for _, s in ipairs(player.player_skills) do
      index = math.max(index, table.indexOf(skills, s.name))
    end
    local skill = skills[index]
    if skill == nil then
      room:addPlayerMark(player, "n_yingfa_levelup")
      room:handleAddLoseSkills(player, "zhiheng")
    elseif skill == "n_huiwan" then
      player:drawCards(1, "n_yingfa")
    else
      room:addPlayerMark(player, "n_yingfa_levelup")
      room:handleAddLoseSkills(player, skills[index+1].."|-"..skill)
    end
  end,
})

yingfa:addEffect(fk.Death, {
  can_trigger = function (self, event, target, player, data)
    if target == player then
      return #player:getTableMark("n_yingfa_target") > 0
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local mark = player:getTableMark("n_yingfa_target")
    room:setPlayerMark(player, "n_yingfa_target", 0)
    for _, m in ipairs(mark) do
      local pid, dep = table.unpack(m)
      room:changeHero(room:getPlayerById(pid), dep, false, true, true, false)
    end
  end,
})
yingfa:addEffect(fk.Damaged, {
  mute = true,
  is_delay_effect = true,
  can_trigger = function (self, event, target, player, data)
    if target == player then
      return #player:getTableMark("n_yingfa_target") > 0
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local mark = player:getTableMark("n_yingfa_target")
    room:setPlayerMark(player, "n_yingfa_target", 0)
    for _, m in ipairs(mark) do
      local pid, dep = table.unpack(m)
      room:changeHero(room:getPlayerById(pid), dep, false, true, true, false)
    end
  end,
})

return yingfa