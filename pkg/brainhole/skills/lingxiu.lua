local lingxiu = fk.CreateSkill{
  name = "n_lingxiu",
}

Fk:loadTranslationTable{
  ["n_lingxiu"] = "领袖",
  [":n_lingxiu"] = "锁定技，当你不以此法获得手牌后，将手牌摸至全场最多。",
  ["$n_lingxiu1"] = "我才是领导！",
  ["$n_lingxiu2"] = "都听我的！",
}

lingxiu:addEffect(fk.AfterCardsMove, {
  anim_type = "drawcard",
  frequency = Skill.Compulsory,
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(lingxiu.name) then return end
    local room = player.room
    if #table.filter(room:getOtherPlayers(player, false), function(p)
      return #p:getCardIds(Player.Hand) > #player:getCardIds(Player.Hand)
    end) == 0 then return end

    for _, move in ipairs(data) do
      if move == player.id and move.toArea == Card.PlayerHand and move.skillName ~= lingxiu.name then
        return true
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local goal = 0
    for _, p in ipairs(room:getOtherPlayers(player, false)) do
      goal = math.max(goal, p:getHandcardNum())
    end
    player:drawCards(goal - player:getHandcardNum(), self.name)
  end,
})

return lingxiu
