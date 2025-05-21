local n_pengji_ac = fk.CreateSkill {
  name = "n_pengji_ac",
}



n_pengji_ac:addEffect("active", {
  name = "n_pengji_ac",
  min_card_num = 1,
  card_filter = function(self, player, to_select, selected)
    return table.every(selected, function(id)
      return Fk:getCardById(id).type ~= Fk:getCardById(to_select).type
    end)
  end,
  target_filter = function() return false end,
})

return n_pengji_ac