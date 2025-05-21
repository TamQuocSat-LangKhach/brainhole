local yinghui = fk.CreateSkill{
  name = "n_yinghui",
}

Fk:loadTranslationTable{
  ["n_yinghui"] = "萦回",
  [":n_yinghui"] = "当有角色即将摸牌时，若不为两张，你可以弃置一张牌将摸牌数改成两张；若变化量超过1，你摸等同于超出数量的牌。",
  ["#n_yinghui-ask"] = "萦回: %dest 即将摸 %arg 张牌，是否弃一张牌令其改为摸两张？",
}

yinghui:addEffect(fk.BeforeDrawCard, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    if data.num == 2 then return end
    return player:hasSkill(self) and not player:isNude()
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local ids = room:askForDiscard(player, 1, 1, true, self.name, true,
      ".", "#n_yinghui-ask::" .. data.who.id .. ":" .. data.num, true)

    if #ids > 0 then
      event:setCostData(self, ids[1])
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:throwCard(event:getCostData(self), self.name, player, player)
    local num = data.num
    data.num = 2
    local x = math.abs(num - data.num) - 1
    if x > 0 then player:drawCards(x, self.name) end
  end,
})

return yinghui
