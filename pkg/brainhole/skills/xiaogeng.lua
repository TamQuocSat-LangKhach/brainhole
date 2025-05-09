local xiaogeng = fk.CreateSkill{
  name = "n_xiaogeng",
}

Fk:loadTranslationTable{
  ["n_xiaogeng"] = "小更",
  [":n_xiaogeng"] = "出牌阶段结束时，你可以摸一张牌再将至少一张牌分配给其他角色，若至少给出两张牌，你可以视为使用分配的牌中一张基本牌或普通锦囊牌。",
}

local U = require "packages/utility/utility"

xiaogeng:addEffect(fk.EventPhaseEnd, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and target == player and player.phase == Player.Play
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:drawCards(1, self.name)
    if player.dead or player:isNude() or #room:getOtherPlayers(player, false) == 0 then return end
    local move = room:askForYiji(player, player:getCardIds("he"), room:getOtherPlayers(player, false), self.name, 1, #player:getCardIds("he"), nil, nil, true)
    local cards = room:doYiji(move, player.id, self.name)
    if #cards > 1 and not player.dead then
      local names = {}
      for _, id in ipairs(cards) do
        local c = Fk:getCardById(id)
        if c.type == Card.TypeBasic or c:isCommonTrick() then
          table.insertIfNeed(names, Fk:getCardById(id).name)
        end
      end
      if #names > 0 then
        U.askForUseVirtualCard(room, player, names, nil, self.name, nil, true, true, false, true)
      end
    end
  end,
})

return xiaogeng
