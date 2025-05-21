local jianxiong = fk.CreateSkill {

  name = "n_jianxiong",

  tags = {  },

}



jianxiong:addEffect(fk.Damaged, {
  anim_type = "masochism",
  on_cost = function(self, event, target, player, data)
    local choices = {'n_jianxiong_draw'}
    if data.card and target.room:getCardArea(data.card) == Card.Processing then
      table.insert(choices, 'n_jianxiong_get')
    end
    table.insert(choices, 'Cancel')
    local choice = player.room:askToChoice(player,{
      choices=choices,
      skill_name=jianxiong.name,
    })
    if choice ~= "Cancel" then
      event:setCostData(self,choice)
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    if event:getCostData(self) == "n_jianxiong_draw" then
      player:drawCards(1, jianxiong.name)
    elseif event:getCostData(self) == "n_jianxiong_get" then
      player.room:obtainCard(player, data.card, true, fk.ReasonJustMove)
    end
  end,
})

return jianxiong