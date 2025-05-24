local n_fudu = fk.CreateSkill {
  name = "n_fudu",
}

Fk:loadTranslationTable{
  ["n_fudu"] = "复读",
  [":n_fudu"] = "其他角色的指定唯一目标的非转化的基本牌或者普通锦囊牌结算完成后：<br/>"..
  "若你是唯一目标，你可以将颜色相同的一张手牌当做此牌对使用者使用。<br/>"..
  "若你不是唯一目标，你可以将颜色相同的一张手牌当做此牌对目标角色使用。",

  ["@n_fudu"] = "复读：你可以将一张%arg2手牌当【%arg】对 %dest 使用",

  ["$n_fudu"] = "加一",
}

n_fudu:addEffect(fk.CardUseFinished, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(n_fudu.name) and
      #data.tos == 1 and not data.card:isVirtual() and
      (data.card.type == Card.TypeBasic or data.card:isCommonTrick()) and data.card.color ~= Card.NoColor and
      #player:getHandlyIds() > 0 then
      local to = data:isOnlyTarget(player) and target or data.tos[1]
      return to and not to.dead and player:canUseTo(Fk:cloneCard(data.card.name), to, { bypass_times = true, bypass_distances = true })
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local to = data:isOnlyTarget(player) and target or data.tos[1]
    local pattern = data.card.color == Card.Red and "heart,diamond" or "spade,club"
    local use = room:askToUseVirtualCard(target, {
      name = data.card.name,
      skill_name = n_fudu.name,
      prompt = "@n_fudu::" .. target.id .. ":" .. data.card.name .. ":" .. data.card:getColorString(),
      cancelable = true,
      extra_data = {
        bypass_distances = true,
        bypass_times = true,
        extraUse = true,
        exclusive_targets = { to.id },
      },
      card_filter = {
        n = 1,
        pattern = pattern,
        cards = player:getHandlyIds(),
      },
      skip = true,
    })
    if use then
      event:setCostData(self, {extra_data = use})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    player.room:useCard(event:getCostData(self).extra_data)
  end,
})

return n_fudu