local daotu = fk.CreateSkill{
  name = "n_daotu",
}

Fk:loadTranslationTable{
  ["n_daotu"] = "盗图",
  ["@$n_daotu"] = "盗图",
  ["$n_daotu1"] = "此图，我怎么会错失。",
  ["$n_daotu2"] = "你的图，现在是我的了！",
  [":n_daotu"] = "每回合限一次，当其他角色使用的非转化且非虚拟的牌结算完成后，" ..
    "若你没有同名的手牌，则你可以获得之。每种牌名限获得一次。",
}

daotu:addEffect(fk.CardUseFinished, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(self) then return end
    local card = data.card
    if card:isVirtual() then return false end
    if data.from == player then return end
    if player:usedSkillTimes(self.name, Player.HistoryTurn) > 0 then
      return false
    end
    local tab = player:getMark("@$n_daotu")
    if table.contains(type(tab) == "table" and tab or {}, card.name) then
      return false
    end
    if player.room:getCardArea(card.id) == Card.Processing then
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:obtainCard(player, data.card.id, true)
    local mark_tab = player:getMark("@$n_daotu")
    if type(mark_tab) ~= "table" then mark_tab = {} end
    table.insert(mark_tab, data.card.name)
    room:setPlayerMark(player, "@$n_daotu", mark_tab)
  end
})

return daotu
