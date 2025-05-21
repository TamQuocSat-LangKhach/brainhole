local yingfa = fk.CreateSkill {

  name = "n_yingfa",

  tags = {  },

}



yingfa:addEffect("active", {
  name = "n_yingfa",
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
  name = "#n_yingfa_trig",
  events = {fk.EventPhaseStart},
  --yingfa,
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
  name = "#n_yingfa_delay",
  mute = true,
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
  name = "#n_yingfa_delay",
  mute = true,
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

return yingfa