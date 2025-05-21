local yaodao = fk.CreateSkill {
  name = "n_yaodao",
}

Fk:loadTranslationTable {
  ["n_yaodao"] = "妖刀",
  [":n_yaodao"] = "锁定技，你使用或打出非虚拟【杀】后，视为使用一张无视防具的同类别【杀】。",
  ["#n_yaodao-use"] = "妖刀：你视为使用一张无视防具的%arg。",
  ["#n_huanmeng-invoke"] = "寰梦：你可以摸一张牌并结束回合。",
  ["$n_yaodao"] = "（蓄力斩）",
}

local U = require "packages/utility/utility"

local effect_tab = {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and data.card and data.card.trueName == "slash" and
        not (data.card:isVirtual() and #data.card.subcards == 0)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local name = data.card.name
    local dat = room:askToUseVirtualCard(player, {
      name = name,
      skill_name = yaodao.name,
      prompt = "#n_yaodao-use:::" .. name,
      cancelable = false,
      extra_data = { bypass_times = true, bypass_distances = false },
      skip = true
    })
    if dat then
      event:setCostData(self, dat)
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local use = event:getCostData(self)
    room:useCard(use)
  end,
}

yaodao:addEffect(fk.CardUseFinished, {
  anim_type = "offensive",
  frequency = Skill.Compulsory,
  can_trigger = effect_tab.can_trigger,
  on_cost = effect_tab.on_cost,
  on_use = effect_tab.on_use,
})

yaodao:addEffect(fk.CardRespondFinished, {
  anim_type = "offensive",
  frequency = Skill.Compulsory,
  can_trigger = effect_tab.can_trigger,
  on_cost = effect_tab.on_cost,
  on_use = effect_tab.on_use,
})

yaodao:addEffect(fk.TargetSpecified, {
  can_refresh = function(self, event, target, player, data)
    return target == player and data.card and table.contains(data.card.skillNames, self.name)
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    room:addPlayerMark(data.to, MarkEnum.MarkArmorNullified)
    data.extra_data = data.extra_data or {}
    data.extra_data.yaodaoNullified = data.extra_data.yaodaoNullified or {}
    data.extra_data.yaodaoNullified[tostring(data.to.id)] =
        (data.extra_data.yaodaoNullified[tostring(data.to.id)] or 0) + 1
  end,
})

yaodao:addEffect(fk.CardUseFinished, {
  can_refresh = function(self, event, target, player, data)
    return data.extra_data and data.extra_data.yaodaoNullified
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    for key, num in pairs(data.extra_data.yaodaoNullified) do
      local p = room:getPlayerById(tonumber(key))
      if p:getMark(MarkEnum.MarkArmorNullified) > 0 then
        room:removePlayerMark(p, MarkEnum.MarkArmorNullified, num)
      end
    end
    data.extra_data.yaodaoNullified = nil
  end,
})

return yaodao
