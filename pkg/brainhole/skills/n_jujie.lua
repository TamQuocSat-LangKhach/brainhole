local n_jujie = fk.CreateSkill {
  name = "n_jujie",
}

Fk:loadTranslationTable{
  ["n_jujie"] = "拒杰",
  [":n_jujie"] = "当你成为其他角色使用伤害类卡牌的目标后，你可以弃置一张牌，若此牌对你造成了伤害，其须将手牌数弃至与你一致。",

  ["#n_jujie-ask"] = "拒杰：你可以弃置一张牌，若受到%arg的伤害则 %dest 须将手牌弃置至与你相等",

  ["$n_jujie"] = "不要啦杰哥！你干嘛！",
}

n_jujie:addEffect(fk.TargetConfirmed, {
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(n_jujie.name) and
      data.from ~= player and data.card.is_damage_card and
      not player:isNude()
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local card = room:askToDiscard(player, {
      min_num = 1,
      max_num = 1,
      include_equip = true,
      skill_name = n_jujie.name,
      prompt = "#n_jujie-ask::" .. data.from.id .. ":" .. data.card.name,
      cancelable = true,
      skip = true,
    })
    if #card > 0 then
      event:setCostData(self, {cards = card})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    data.extra_data = data.extra_data or {}
    data.extra_data.n_jujie = {player.id, target.id}
    room:throwCard(event:getCostData(self).cards, n_jujie.name, player, player)
  end,
})

n_jujie:addEffect(fk.Damaged, {
  mute = true,
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    if target == player and data.card then
      local use_event = player.room.logic:getCurrentEvent():findParent(GameEvent.UseCard)
      if use_event then
        local use = use_event.data
        if use.extra_data and use.extra_data.n_jujie and use.extra_data.n_jujie[1] == player.id then
          local from = player.room:getPlayerById(use.extra_data.n_jujie[2])
          if from and from:getHandcardNum() > player:getHandcardNum() then
            event:setCostData(self, {tos = {from}})
            return true
          end
        end
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local from = event:getCostData(self).tos[1]
    local n = from:getHandcardNum() - player:getHandcardNum()
    room:askToDiscard(from, {
      min_num = n,
      max_num = n,
      include_equip = false,
      skill_name = n_jujie.name,
      cancelable = false,
    })
  end,
})

return n_jujie
