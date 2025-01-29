local desc = [[
# 同将模式

出自太阳神三国杀。所有人使用和主公一致的武将。
]]

local same_getLogic = function()
  local ret = GameLogic:subclass("same_logic")

  function ret:chooseGenerals()
    local room = self.room
    local generalNum = room.settings.generalNum
    local n = room.settings.enableDeputy and 2 or 1
    local lord = room:getLord()
    local lord_generals = {}
    local lord_general, deputy

    if lord ~= nil then
      room:setCurrent(lord)
      local generals = room:getNGenerals(generalNum)
      lord_generals = room:askForGeneral(lord, generals, n)
      if type(lord_generals) == "table" then
        deputy = lord_generals[2]
        lord_general = lord_generals[1]
      else
        lord_general = lord_generals
        lord_generals = {lord_general}
      end

      generals = table.filter(generals, function(g) return not table.contains(lord_generals, g) end)
      room:returnToGeneralPile(generals)

      room:prepareGeneral(lord, lord_general, deputy, true)
    end

    local nonlord = room:getOtherPlayers(lord, true)

    for _, p in ipairs(nonlord) do
      room:prepareGeneral(p, lord_general, deputy)
    end

    room:askForChooseKingdom(room.players)
  end

  return ret
end

local role_mode = Fk.game_modes['aaa_role_mode']

local same_mode = fk.CreateGameMode{
  name = "same_mode",
  minPlayer = 2,
  maxPlayer = 8,
  logic = same_getLogic,
  surrender_func = role_mode.surrenderFunc,
  reward_punish = role_mode.deathRewardAndPunish,
  winner_getter = role_mode.getWinner,
}

Fk:loadTranslationTable{
  ["same_mode"] = "同将模式",
  [":same_mode"] = desc,
}

return same_mode
