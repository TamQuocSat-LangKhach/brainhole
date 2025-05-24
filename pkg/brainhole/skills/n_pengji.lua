local n_pengji = fk.CreateSkill {
  name = "n_pengji",
}

Fk:loadTranslationTable{
  ["n_pengji"] = "烹鸡",
  [":n_pengji"] = "当你不因此法摸牌后，你可以弃置任意张类型不同的牌，然后摸等量的牌。",

  ["#n_pengji-invoke"] = "烹鸡：你可以弃置任意张不同类型的牌，摸等量的牌",

  ["$n_pengji1"] = "先用油把这个鸡淋一下啊",
  ["$n_pengji2"] = "基本上很均匀了这个皮",
}

n_pengji:addEffect(fk.AfterCardsMove, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(n_pengji.name) or player:isNude() then return end
    for _, move in ipairs(data) do
      if move.to == player and move.moveReason == fk.ReasonDraw and move.skillName ~= n_pengji.name then
        return true
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local success, dat = room:askToUseActiveSkill(player, {
      skill_name = "n_pengji_active",
      prompt = "#n_pengji-invoke",
      cancelable = true,
    })
    if success and dat then
      event:setCostData(self, {cards = dat.cards})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cards = event:getCostData(self).cards
    room:throwCard(cards, n_pengji.name, player)
    if not player.dead then
      player:drawCards(#cards, n_pengji.name)
    end
  end,
})

return n_pengji