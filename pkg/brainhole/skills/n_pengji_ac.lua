local n_pengji_active = fk.CreateSkill {
  name = "n_pengji_active",
}

Fk:loadTranslationTable{
  ["n_pengji_active"] = "烹鸡",
}

n_pengji_active:addEffect("active", {
  min_card_num = 1,
  target_num = 0,
  card_filter = function(self, player, to_select, selected)
    return table.every(selected, function(id)
      return Fk:getCardById(id).type ~= Fk:getCardById(to_select).type
    end)
  end,
})

return n_pengji_active