local description = [[
# 混战模式

所有玩家都需要为自己而战！既要谋略，亦要实力，不再受后置位坐牢之苦，好好发挥出你的真实水准吧。

规则如下：

- 胜利条件为击杀所有其他角色，成为唯一的生存者。
- 击杀后摸2。
- 出牌阶段被修改为进行“混战”。

混战中的相关概念：

- 回合外的角色也能像普通的出牌阶段那样选择使用牌或者使用技能。
- 所有角色的行动受到气力的约束。回合外行动减5气力，回合内减1气力。
- “混战”开始时，所有角色气力+5（当前回合角色的气力再+5）。
- “混战”过程中，气力不少于3的所有角色同时选择行动。手速较快的优先结算。
- 所有卡牌使用、技能使用的相关结算结束后，再结算气力值变动。

此外，若当前回合的角色死亡，则“混战”结束。

]]

local melee_getLogic = function()
  local melee_logic = GameLogic:subclass("melee_logic")

  function melee_logic:assignRoles()
    local room = self.room
    local n = #room.players

    for i = 1, n do
      local p = room.players[i]
      p.role = "hidden"
      room:setPlayerProperty(p, "role_shown", true)
      room:broadcastProperty(p, "role")
      --p.role = p._splayer:getScreenName() --结算显示更好，但身份图标疯狂报错
    end

    self.start_role = "hidden"
    -- for adjustSeats
    room.players[1].role = "lord"
  end

  function melee_logic:chooseGenerals()
    local room = self.room
    local generalNum = room.settings.generalNum
    local n = room.settings.enableDeputy and 2 or 1
    local lord = room:getLord()
    room:setCurrent(lord)
    lord.role = self.start_role

    local players = room.players
    local generals = room:getNGenerals(#players * generalNum)
    local req = Request:new(players, "AskForGeneral")
    table.shuffle(generals)
    for i, p in ipairs(players) do
      local arg = table.slice(generals, (i - 1) * generalNum + 1, i * generalNum + 1)
      req:setData(p, { arg, n })
      req:setDefaultReply(p, table.random(arg, n))
    end

    -- room:doBroadcastNotify("ShowToast", Fk:translate("chaos_intro"))

    req:ask()

    local selected = {}
    for _, p in ipairs(players) do
      local gs = req:getResult(p)
      local general = gs[1]
      local deputy = gs[2]
      room:setPlayerGeneral(p, general, true, true)
      room:setDeputyGeneral(p, deputy)
    end
    generals = table.filter(generals, function(g) return not table.contains(selected, g) end)
    room:returnToGeneralPile(generals)

    room:askForChooseKingdom(players)
  end

  return melee_logic
end

---@param p ServerPlayer
local function changeEnergy(p, n)
  local e = p:getMark("@melee_energy")
  e = e + n
  e = math.max(e, 0)
  e = math.min(e, 40)
  p.room:setPlayerMark(p, "@melee_energy", e)
end

local melee_rule = fk.CreateTriggerSkill{
  name = "#melee_rule",
  priority = 0.001,
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player.phase == Player.Play
  end,
  on_trigger = function(_, _, _, player, _)
    local room = player.room
    local logic = room.logic
    if player._phase_end then return end
    room:doBroadcastNotify("UpdateSkill", "", {player})
    for _, p in ipairs(room.alive_players) do changeEnergy(p, 5) end
    changeEnergy(player, 5)
    while not player.dead do
      if player._phase_end then break end
      local data = { timeout = room.timeout }
      logic:trigger(fk.StartPlayCard, player, data, true)

      local to_ask = table.filter(room.alive_players, function(p)
        return p:getMark("@melee_energy") >= 5
      end)
      if #to_ask == 0 then break end

      local req = Request:new(to_ask, "PlayCard", 1)
      req.timeout = data.timeout
      req:ask()

      local p = req.winners[1]
      if not p then break end
      local result = req:getResult(p)
      if result == "" then break end

      local delta
      if p == player then
        delta = -1
      else
        delta = -5
      end
      local useResult = room:handleUseCardReply(p, result)
      if type(useResult) == "table" then
        room:useCard(useResult)
      end
      changeEnergy(p, delta)
      for _, p2 in ipairs(room:getOtherPlayers(p)) do
        changeEnergy(p2, 1)
      end
    end
    return true
  end
}
Fk:addSkill(melee_rule)
local melee_mode = fk.CreateGameMode{
  name = "melee_mode",
  minPlayer = 2,
  maxPlayer = 8,
  rule = melee_rule,
  logic = melee_getLogic,
  surrender_func = function(self, playedTime)
    local surrenderJudge = { { text = "chaos: left two alive", passed = #table.filter(Fk:currentRoom().players, function(p) return p.rest > 0 or not p.dead end) == 2 } }
    return surrenderJudge
  end,
  reward_punish = function (self, victim, killer)
    if not killer or killer.dead then return end
    killer:drawCards(2, "kill")
  end,
  winner_getter = function(self, victim)
    if not victim.surrendered and victim.rest > 0 then
      return ""
    end
    local room = victim.room
    local alive = table.filter(room.players, function(p)
      return not p.surrendered and not (p.dead and p.rest == 0)
    end)
    if #alive > 1 then return "" end
    alive[1].role = "renegade" --生草
    if room.class.name == 'Room' then
      room:broadcastProperty(alive[1], 'role')
    end
    return "renegade"
  end,
}

Fk:loadTranslationTable{
  ["melee_mode"] = "混战模式",
  [":melee_mode"] = description,
  ["@melee_energy"] = "气力值",
}

return melee_mode
