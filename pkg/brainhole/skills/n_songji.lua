local n_songji = fk.CreateSkill {
  name = "n_songji",
}

Fk:loadTranslationTable{
  ["n_songji"] = "颂鸡",
  [":n_songji"] = "当你发动〖烹鸡〗后，若摸的牌和弃置的牌中有牌名相同，你可以将这些相同的牌中的一张当【杀】或【桃】使用，"..
  "然后你本阶段〖烹鸡〗和〖颂鸡〗失效并摸一张牌。",

  ["#n_songji-use"] = "颂鸡：你已经做出了数一数二的烧鸡，将其中一张牌当【杀】或【桃】使用",

  ["$n_songji1"] = "这个烧鸡，皮酥脆，肉滑有汁，骨都带味",
  ["$n_songji2"] = "所以是数一数二的烧鸡！",
}

n_songji:addEffect(fk.AfterSkillEffect, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(n_songji.name) and data.skill.name == "n_pengji" and not player:isKongcheng() then
      local skill_event = player.room.logic:getCurrentEvent():findParent(GameEvent.SkillEffect, true)
      if skill_event and skill_event.data.skill.name == "n_pengji" then
        local discard, draw = {}, {}
        skill_event:searchEvents(GameEvent.MoveCards, 1, function (e)
          for _, move in ipairs(e.data) do
            if move.from == player and move.moveReason == fk.ReasonDiscard and move.skillName == "n_pengji" then
              for _, info in ipairs(move.moveInfo) do
                table.insertIfNeed(discard, info.cardId)
              end
            end
            if move.to == player and move.moveReason == fk.ReasonDraw and move.skillName == "n_pengji" then
              for _, info in ipairs(move.moveInfo) do
                if table.contains(player:getCardIds("h"), info.cardId) then
                  table.insertIfNeed(draw, info.cardId)
                end
              end
            end
          end
        end)
        draw = table.filter(draw, function(id)
          return table.find(discard, function (id2)
            return Fk:getCardById(id).trueName == Fk:getCardById(id2).trueName
          end)
        end)
        if #draw > 0 then
          event:setCostData(self, {cards = draw})
          return true
        end
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local use = room:askToUseVirtualCard(player, {
      name = {"slash", "peach"},
      skill_name = n_songji.name,
      prompt = "#n_songji-use",
      cancelable = true,
      extra_data = {
        bypass_times = true,
        extraUse = true,
      },
      card_filter = {
        n = 1,
        cards = event:getCostData(self).cards,
      },
      skip = true,
    })
    if use then
      event:setCostData(self, {extra_data = use})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:useCard(event:getCostData(self).extra_data)
    if player.dead then return end
    room:invalidateSkill(player, "n_pengji", "-phase")
    room:invalidateSkill(player, n_songji.name, "-phase")
    player:drawCards(1, n_songji.name)
  end,
})

return n_songji