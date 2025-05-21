local n_daotu = fk.CreateSkill {
  name = "n_daotu",
}



n_daotu:addEffect(fk.CardUseFinished, {
  name = "n_daotu",
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(n_daotu.name) then
      local card = data.card
      if card:isVirtual() then return false end
      if data.from == player then return end
      if player:usedSkillTimes(n_daotu.name, Player.HistoryTurn) > 0 then
        return false
      end
      local tab = player:getMark("@$n_daotu")
      if table.contains(type(tab) == "table" and tab or {}, card.name) then
        return false
      end
      if player.room:getCardArea(card.id) == Card.Processing then
        return true
      end
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

return n_daotu