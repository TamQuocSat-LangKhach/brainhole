local yinghui = fk.CreateSkill{
  name = "n_yinghui",
}

Fk:loadTranslationTable{
  ["n_yinghui"] = "萦回",
  [":n_yinghui"] = "当有角色即将摸牌时，若不为两张，你可以弃置一张牌将摸牌数改成两张；若变化量超过1，你摸等同于超出数量的牌。",

  ["#n_yinghui-ask"] = "萦回：%dest 即将摸 %arg 张牌，是否弃一张牌令其改为摸两张？",
}

yinghui:addEffect(fk.BeforeDrawCard, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and not player:isNude() and data.num ~= 2
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local card = room:askToDiscard(player, {
      min_num = 1,
      max_num = 1,
      include_equip = true,
      skill_name = yinghui.name,
      prompt = "#n_yinghui-ask::" .. data.who.id .. ":" .. data.num,
      cancelable = true,
      skip = true,
    })
    if #card > 0 then
      event:setCostData(self, {tos = {target}, cards = card})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:throwCard(event:getCostData(self).cards, yinghui.name, player, player)
    local num = data.num
    data.num = 2
    local x = math.abs(num - data.num) - 1
    if x > 0 then player:drawCards(x, yinghui.name) end
  end,
})

return yinghui
