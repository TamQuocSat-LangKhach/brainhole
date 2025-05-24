local yaodao = fk.CreateSkill {
  name = "n_yaodao",
}

Fk:loadTranslationTable {
  ["n_yaodao"] = "妖刀",
  [":n_yaodao"] = "锁定技，你使用或打出非虚拟【杀】后，视为使用一张无视防具的同类别【杀】。",

  ["#n_yaodao-use"] = "妖刀：请视为使用一张无视防具的【%arg】",

  ["$n_yaodao"] = "（蓄力斩）",
}

local spec = {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(yaodao.name) and data.card and data.card.trueName == "slash" and
       #Card:getIdList(data.card) > 0
  end,
  on_use = function(self, event, target, player, data)
    player.room:askToUseVirtualCard(player, {
      name = data.card.name,
      skill_name = yaodao.name,
      prompt = "#n_yaodao-use:::"..data.card.name,
      cancelable = false,
      extra_data = {
        bypass_times = true,
        extraUse = true,
      },
    })
  end,
}
yaodao:addEffect(fk.CardUseFinished, spec)
yaodao:addEffect(fk.CardRespondFinished, spec)

yaodao:addEffect(fk.TargetSpecified, {
  can_refresh = function(self, event, target, player, data)
    return table.contains(data.card.skillNames, yaodao.name) and not data.to.dead
  end,
  on_refresh = function(self, event, target, player, data)
    data.to:addQinggangTag(data)
  end,
})

return yaodao
