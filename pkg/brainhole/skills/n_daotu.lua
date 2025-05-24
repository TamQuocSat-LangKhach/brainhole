local n_daotu = fk.CreateSkill {
  name = "n_daotu",
}

Fk:loadTranslationTable{
  ["n_daotu"] = "盗图",
  [":n_daotu"] = "每回合限一次，当其他角色使用的非转化且非虚拟的牌结算完成后，若你没有同名的手牌，则你可以获得之。每种牌名限获得一次。",

  ["@$n_daotu"] = "盗图",

  ["$n_daotu1"] = "此图，我怎么会错失。",
  ["$n_daotu2"] = "你的图，现在是我的了！",
}

n_daotu:addEffect(fk.CardUseFinished, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return target ~= player and player:hasSkill(n_daotu.name) and
      not table.find(player:getCardIds("h"), function (id)
        return Fk:getCardById(id).name == data.card.name
      end) and
      player.room:getCardArea(data.card) == Card.Processing and
      not data.card:isVirtual() and
      not table.contains(player:getTableMark("@$n_daotu"), data.card.name) and
      player:usedSkillTimes(n_daotu.name, Player.HistoryTurn) == 0
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:addTableMark(player, "@$n_daotu", data.card.name)
    room:obtainCard(player, data.card, true)
  end
})

n_daotu:addLoseEffect(function (self, player, is_death)
  player.room:setPlayerMark(player, "@$n_daotu", 0)
end)

return n_daotu