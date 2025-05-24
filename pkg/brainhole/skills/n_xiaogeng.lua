local n_xiaogeng = fk.CreateSkill {
  name = "n_xiaogeng",
}

Fk:loadTranslationTable{
  ["n_xiaogeng"] = "小更",
  [":n_xiaogeng"] = "出牌阶段结束时，你可以摸一张牌再将至少一张牌分配给其他角色，若至少给出两张牌，你可以视为使用分配的牌中一张基本牌或普通锦囊牌。",

  ["#n_xiaogeng-give"] = "小更：请交出至少一张牌",
  ["#n_xiaogeng-use"] = "小更：你可以视为使用其中一张牌",
}

n_xiaogeng:addEffect(fk.EventPhaseEnd, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(n_xiaogeng.name) and target == player and player.phase == Player.Play
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:drawCards(1, n_xiaogeng.name)
    if player.dead or player:isNude() or #room:getOtherPlayers(player, false) == 0 then return end
    local result = room:askToYiji(player, {
      cards = player:getCardIds("he"),
      targets = room:getOtherPlayers(player, false),
      skill_name = n_xiaogeng.name,
      min_num = 1,
      max_num = 999,
      prompt = "#n_xiaogeng-give",
    })
    local cards = {}
    for _, ids in pairs(result) do
      table.insertTable(cards, ids)
    end
    if #cards > 1 and not player.dead then
      local names = {}
      for _, id in ipairs(cards) do
        local c = Fk:getCardById(id)
        if c.type == Card.TypeBasic or c:isCommonTrick() then
          table.insertIfNeed(names, Fk:getCardById(id).name)
        end
      end
      if #names > 0 then
        room:askToUseVirtualCard(player,{
          name = names,
          skill_name = n_xiaogeng.name,
          cancelable = true,
          extra_data = {
            bypass_times = true,
            extraUse = true,
          },
          prompt = "#n_xiaogeng-use",
        })
      end
    end
  end,
})

return n_xiaogeng