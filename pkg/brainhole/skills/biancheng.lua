local biancheng = fk.CreateSkill{
  name = "n_biancheng",
}

Fk:loadTranslationTable{
  ["n_biancheng"] = "编程",
  [":n_biancheng"] = "你可以使用或打出牌堆顶的非黑桃牌。",
  ["#n_biancheng"] = "编程：你可以使用或打出牌堆顶的非黑桃牌%arg",
}

biancheng:addEffect('viewas', {
  card_num = 0,
  pattern = ".",
  prompt = function(self, player)
    local card = Fk:getCardById(Fk:currentRoom().draw_pile[1])
    if card then
      return "#n_biancheng:::"..card:toLogString()
    end
    return ""
  end,
  card_filter = Util.FalseFunc,
  view_as = function(self, player)
    local card = Fk:getCardById(Fk:currentRoom().draw_pile[1])
    if not card then return nil end
    if Self:getMark("@@n_baogan") == 0 and card.suit == Card.Spade then return nil end
    return card
  end,
  before_use = function(self, player, use)
    use.card = Fk:getCardById(player.room.draw_pile[1])
  end,
  enabled_at_response = function(self, player)
    local card = Fk:getCardById(Fk:currentRoom().draw_pile[1])
    if not card then return end
    -- 服务器端判断无懈的时候这个pattern是nil。。
    local pat = Fk.currentResponsePattern or "nullification"
    return (player:getMark("@@n_baogan") == 1 or card.suit ~= Card.Spade) and
      Exppattern:Parse(pat):matchExp(card.name)
  end,
})

return biancheng
