local n_qunzhi = fk.CreateSkill {
  name = "n_qunzhi",
}
local n_qunzhi_choices = {
  "dismantlement", "snatch", "duel", "collateral",
  "ex_nihilo", "savage_assault", "archery_attack", "god_salvation",
  "amazing_grace", "iron_chain", "fire_attack",
}


n_qunzhi:addEffect("viewas", {
  name = "n_qunzhi",
  interaction =function (self, player)
    local mark = player:getMark("n_qunzhi_choices")
    if mark == 0 then mark = nil end
    return UI.ComboBox {
      choices = mark or n_qunzhi_choices
    }
  end,
  card_filter = function(self, player, to_select, selected)
    return Fk:currentRoom():getCardArea(to_select) ~= Player.Equip and
      #selected < math.ceil(player:getHandcardNum() / 2)
  end,
  view_as = function(self, player,cards)
    if #cards ~= math.ceil(player:getHandcardNum() / 2) then
      return nil
    end
    local c = Fk:cloneCard(self.interaction.data)
    c:addSubcards(cards)
    return c
  end,
  enabled_at_play = function(self, player)
    return player:usedSkillTimes(n_qunzhi.name, Player.HistoryPhase) == 0 and
      player.hp <= player:getHandcardNum()
  end,
  before_use = function(self, player, use)
    local room = player.room
    local card = use.card.name
    local markTab = player:getMark("n_qunzhi_choices")
    if markTab == 0 then markTab = table.clone(n_qunzhi_choices) end
    table.removeOne(markTab, card)
    if #markTab == 0 then markTab = table.clone(n_qunzhi_choices) end
    room:setPlayerMark(player, "n_qunzhi_choices", markTab)
  end,
})

return n_qunzhi