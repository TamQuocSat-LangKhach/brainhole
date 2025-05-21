local kuangle = fk.CreateSkill {

  name = "n_kuangle",

  tags = { Skill.Compulsory, },

}



kuangle:addEffect(fk.CardUseFinished, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(kuangle.name) and
      data.card.suit ~= Card.NoSuit
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local mark = player:getMark("@[suits]n_kuangle")
    if mark == 0 then mark = {} end
    local suit = data.card.suit
    if not table.contains(mark, suit) then
      table.insert(mark, suit)
      room:setPlayerMark(player, "@[suits]n_kuangle", mark)
      player:drawCards(1, kuangle.name)
    else
      local choices_all = { "n_kuangle-draw",'n_kuangle-disresponsive' }
      local choices = { 'n_kuangle-disresponsive' }
      local used = player:getMark("n_kuangle-turn")
      if used==0 then
        choices=choices_all
      end
      local choice = room:askToChoice(player,{
        choices=choices,
        skill_name=kuangle.name,
        all_choices=choices_all
      })
      if choice == "n_kuangle-draw" then
        if used == 0 then used = {} end
        table.insert(used, data.card.color)
        room:setPlayerMark(player, "n_kuangle-turn", used)
        player:drawCards(1, kuangle.name)
      else
        room:setPlayerMark(player, "@@n_kuangle", 1)
      end
    end
  end,
})

kuangle:addEffect(fk.CardUsing, {
  name = "#n_kuangle_dr",
  --kuangle,
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:getMark("@@n_kuangle") > 0
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:notifySkillInvoked(player, "n_kuangle", "offensive")
    player:broadcastSkillInvoke("n_kuangle")
    data.disresponsiveList = table.map(room.alive_players, Util.IdMapper)
    room:setPlayerMark(player, "@@n_kuangle", 0)
  end,
})

return kuangle