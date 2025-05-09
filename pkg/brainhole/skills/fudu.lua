local fudu = fk.CreateSkill{
  name = "n_fudu",
}

Fk:loadTranslationTable{
  ["n_fudu"] = "复读",
  ["$n_fudu"] = "加一",
  [":n_fudu"] = "其他角色的指定唯一目标的非转化的基本牌或者普通锦囊牌结算完成后: <br/>" ..
  "① 若你是唯一目标，你可以将颜色相同的一张手牌当做此牌对使用者使用。（无视距离）<br/>" ..
  "② 若你不是唯一目标，你可以将颜色相同的一张手牌当做此牌对目标角色使用。（无视距离）",
  ["@n_fudu"] = "复读：你可以将一张%arg2手牌当做【%arg】对 %dest 使用",
}

fudu:addEffect(fk.CardUseFinished, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(self) then return end
    if player:isKongcheng() then return end
    local room = player.room

    local use = data
    local card = use.card
    if not (use.from ~= player and (not card:isVirtual()) and
      (card.type == Card.TypeBasic or card:isCommonTrick()
    )) then
      return
    end
    local tos = use.tos
    if #table.filter(room.alive_players, function(p) return table.contains(tos, p) end) ~= 1 then return end
    local tgt = use.tos[1] == player and use.from or use.tos[1]
    if tgt.dead then
      return
    end
    return player:canUseTo(card, tgt, { bypass_times = true, bypass_distances = true })
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local use = data

    local tgt = use.tos[1] == player and use.from or use.tos[1]
    local ids = table.filter(player:getCardIds(Player.Hand), function(id)
      return use.card:compareColorWith(Fk:getCardById(id))
    end)

    local c = room:askForCard(player, 1, 1, false, self.name, true,
      tostring(Exppattern{ id = ids }),
      "@n_fudu::" .. target.id .. ":" .. use.card.name .. ":" .. use.card:getColorString())[1]

    if c then
      self.cost_data = c
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local use = {
      from = player,
      tos = data.tos[1] == player and { data.from } or { data.tos[1] }
    }

    local card = Fk:cloneCard(data.card.name)
    card:addSubcard(self.cost_data)
    card.skillName = self.name
    use.card = card
    use.extraUse = true
    room:useCard(use)
  end,
})

return fudu
