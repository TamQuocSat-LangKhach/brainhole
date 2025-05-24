local liusha = fk.CreateSkill {
  name = "n_liusha",
}

Fk:loadTranslationTable{
  ["n_liusha"] = "流沙",
  [":n_liusha"] = "当你成为普通锦囊牌的目标时，若使用者不是目标，你可以弃置一张<font color='red'>♦</font>牌并选择：1.将目标转移给使用者；"..
  "2.获得使用者一张牌。",

  ["#n_liusha"] = "流沙：你可以弃置一张<font color='red'>♦</font>牌，将此牌目标转移给使用者或者获得其一张牌",
  ["n_liusha_choice1"] = "将目标转移给使用者",
  ["n_liusha_choice2"] = "获得使用者一张牌",
}

liusha:addEffect(fk.TargetConfirming, {
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(liusha.name) and
      data.card:getSubtypeString() == "normal_trick" and
      not table.contains(data.use.tos, data.from) and
      not player:isNude()
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local card = room:askToDiscard(player, {
      min_num = 1,
      max_num = 1,
      include_equip = true,
      skill_name = liusha.name,
      pattern = ".|.|diamond",
      prompt = "#n_liusha",
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
    room:throwCard(event:getCostData(self).cards, liusha.name, player, player)
    if player.dead then return end
    local choices = { "n_liusha_choice1" }
    if not data.from:isNude() then table.insert(choices, "n_liusha_choice2") end
    local choice = room:askToChoice(player, {
      choices = choices,
      skill_name = liusha.name,
    })
    if choice == "n_liusha_choice1" then
      data:cancelTarget(player)
      data:addTarget(data.from)
    else
      local card = room:askToChooseCard(player, {
        target = data.from,
        flag = "he",
        skill_name = liusha.name,
      })
      room:obtainCard(player, card, false, fk.ReasonPrey, player)
    end
  end,
})

return liusha
