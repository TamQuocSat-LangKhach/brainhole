local cejin = fk.CreateSkill{
  name = "n_cejin",
}

Fk:loadTranslationTable{
  ["n_cejin"] = "策进",
  [":n_cejin"] = "每回合限一次，你可以将两张颜色不同的手牌当一张非伤害普通锦囊牌使用，然后摸一张牌。",
}

cejin:addEffect('viewas', {
  anim_type = "drawcard",
  pattern = ".|.|.|.|.|normal_trick",
  interaction = function(self, player)
    local names, all_names = {} , {}
    for _, id in ipairs(Fk:getAllCardIds()) do
      local card = Fk:getCardById(id)
      if card:isCommonTrick() and not card.is_derived and not card.is_damage_card then
        table.insertIfNeed(all_names, card.name)
        if not player:prohibitUse(card) and
        ((Fk.currentResponsePattern == nil and player:canUse(card)) or
        (Fk.currentResponsePattern and Exppattern:Parse(Fk.currentResponsePattern):match(card))) then
          table.insertIfNeed(names, card.name)
        end
      end
    end
    return UI.ComboBox {choices = names, all_choices = all_names}
  end,
  card_filter = function(self, player, to_select, selected)
    if #selected == 1 then
      return table.contains(player:getHandlyIds(true), to_select) and Fk:getCardById(to_select).color ~= Fk:getCardById(selected[1]).color
    elseif #selected == 2 then
      return false
    end
    return table.contains(player:getHandlyIds(true), to_select)
  end,
  view_as = function(self, player, cards)
    if #cards ~= 2 then return nil end
    local card = Fk:cloneCard(self.interaction.data)
    card:addSubcards(cards)
    card.skillName = self.name
    return card
  end,
  after_use = function(self, player, _)
    if not player.dead then
      player:drawCards(1, self.name)
    end
  end,
  enabled_at_play = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryTurn) == 0 and
      #player:getCardIds("h") >= 2
  end,
  enabled_at_response = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryTurn) == 0 and
      #player:getCardIds("h") >= 2
  end,
})

return cejin
