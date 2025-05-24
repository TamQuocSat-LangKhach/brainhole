local n_qunzhi = fk.CreateSkill {
  name = "n_qunzhi",
}

Fk:loadTranslationTable{
  ["n_qunzhi"] = "群智",
  [":n_qunzhi"] = "出牌阶段限一次，若你的体力值不超过你的手牌数，你可以将一半的手牌当一张普通锦囊牌使用。"..
  "（每种限用一次，你因本技能使用过全部普通锦囊牌后技能状态刷新。）",

  ["$n_qunzhi1"] = "集思广益！",
  ["$n_qunzhi2"] = "群众的智慧是无穷的！",
}

n_qunzhi:addEffect("viewas", {
  name = "n_qunzhi",
  interaction = function (self, player)
    local all_choices = Fk:getAllCardNames("t")
    table.removeOne(all_choices, "nullification")
    local choices = player:getViewAsCardNames(n_qunzhi.name, all_choices, nil, player:getTableMark(n_qunzhi.name))
    if #choices == 0 then return end
    return UI.ComboBox { choices = choices, all_choices = all_choices }
  end,
  card_filter = function(self, player, to_select, selected)
    return Fk:currentRoom():getCardArea(to_select) ~= Player.Equip and
      #selected < math.ceil(player:getHandcardNum() / 2)
  end,
  view_as = function(self, player,cards)
    if #cards ~= player:getHandcardNum() // 2 then
      return nil
    end
    local c = Fk:cloneCard(self.interaction.data)
    c:addSubcards(cards)
    return c
  end,
  before_use = function(self, player, use)
    local room = player.room
    room:addTableMark(player, n_qunzhi.name, use.card.name)
    local all_choices = Fk:getAllCardNames("t")
    table.removeOne(all_choices, "nullification")
    if #player:getTableMark(n_qunzhi.name) == #all_choices then
      room:setPlayerMark(player, n_qunzhi.name, 0)
    end
  end,
  enabled_at_play = function(self, player)
    return player:usedSkillTimes(n_qunzhi.name, Player.HistoryPhase) == 0 and
      player.hp <= player:getHandcardNum() and not player:isKongcheng()
  end,
})

return n_qunzhi