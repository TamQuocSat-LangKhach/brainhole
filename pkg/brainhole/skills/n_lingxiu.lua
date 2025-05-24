local n_lingxiu = fk.CreateSkill {
  name = "n_lingxiu",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["n_lingxiu"] = "领袖",
  [":n_lingxiu"] = "锁定技，当你不以此法获得手牌后，将手牌摸至全场最多。",

  ["$n_lingxiu1"] = "我才是领导！",
  ["$n_lingxiu2"] = "都听我的！",
}

n_lingxiu:addEffect(fk.AfterCardsMove, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(n_lingxiu.name) and
      table.find(player.room:getOtherPlayers(player, false), function(p)
        return p:getHandcardNum() > player:getHandcardNum()
      end) then
      for _, move in ipairs(data) do
        if move.to == player and move.toArea == Card.PlayerHand and move.skillName ~= n_lingxiu.name then
          return true
        end
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local goal = 0
    for _, p in ipairs(room:getOtherPlayers(player, false)) do
      goal = math.max(goal, p:getHandcardNum())
    end
    player:drawCards(goal - player:getHandcardNum(), n_lingxiu.name)
  end,
})

return n_lingxiu