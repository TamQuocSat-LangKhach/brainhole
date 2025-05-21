local n_xiaogeng = fk.CreateSkill {
  name = "n_xiaogeng",
}

U = require "packages/utility/utility"

n_xiaogeng:addEffect(fk.EventPhaseEnd, {
  name = "n_xiaogeng",
  anim_type = "support",
  events = {fk.EventPhaseEnd},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(n_xiaogeng.name) and target == player and player.phase == Player.Play
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:drawCards(1, n_xiaogeng.name)
    if player.dead or player:isNude() or #room:getOtherPlayers(player, false) == 0 then return end
    local move = room:askForYiji(player, player:getCardIds("he"), room:getOtherPlayers(player, false), n_xiaogeng.name, 1, #player:getCardIds("he"), nil, nil, true)
    local cards = room:doYiji(move, player, n_xiaogeng.name)
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
          name=names,
          skill_name=n_xiaogeng.name,
          cancelable=true,
          extra_data={bypass_times=true,bypass_distances=false}
        })
      end
    end
  end,
})

return n_xiaogeng