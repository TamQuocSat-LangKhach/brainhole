local qunzhi_choices = {
  "dismantlement", "snatch", "duel", "collateral",
  "ex_nihilo", "savage_assault", "archery_attack", "god_salvation",
  "amazing_grace", "iron_chain", "fire_attack",
}

local qunzhi = fk.CreateSkill{
  name = "n_qunzhi",
}

Fk:loadTranslationTable{
  ["n_qunzhi"] = "群智",
  [":n_qunzhi"] = "出牌阶段限一次，若你的体力值不超过你的手牌数，" ..
    "你可以将一半的手牌当一张普通锦囊牌（无懈除外）使用。" ..
    "（每种限用一次，你因本技能使用过全部普通锦囊牌后技能状态刷新。）",
  ["$n_qunzhi1"] = "集思广益！",
  ["$n_qunzhi2"] = "群众的智慧是无穷的！",
}

qunzhi:addEffect("viewas", {
  interaction = function(self, player)
    local mark = player:getMark("n_qunzhi_choices")
    if mark == 0 then mark = nil end
    return UI.ComboBox {
      choices = mark or qunzhi_choices
    }
  end,
  card_filter = function(self, player, to_select, selected)
    return Fk:currentRoom():getCardArea(to_select) ~= Player.Equip and
      #selected < math.ceil(player:getHandcardNum() / 2)
  end,
  view_as = function(self, player, cards)
    if #cards ~= math.ceil(player:getHandcardNum() / 2) then
      return nil
    end
    local c = Fk:cloneCard(self.interaction.data)
    c:addSubcards(cards)
    return c
  end,
  enabled_at_play = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0 and
      player.hp <= player:getHandcardNum()
  end,
  before_use = function(self, player, use)
    local room = player.room
    local card = use.card.name
    local markTab = player:getMark("n_qunzhi_choices")
    if markTab == 0 then markTab = table.clone(qunzhi_choices) end
    table.removeOne(markTab, card)
    if #markTab == 0 then markTab = table.clone(qunzhi_choices) end
    room:setPlayerMark(player, "n_qunzhi_choices", markTab)
  end,
})

return qunzhi
