local kuangle = fk.CreateSkill {
  name = "n_kuangle",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["n_kuangle"] = "狂乐",
  [":n_kuangle"] = "锁定技，当你使用牌结算完成后，若其花色未被记录，则你摸一张牌并记录此花色，否则你选择一项："..
  "1.摸一张牌，本回合使用此颜色牌不能再选择此项；2.你使用的下一张牌不可被响应。",

  ["@[suits]n_kuangle"] = "狂乐",
  ["@@n_kuangle"] = "下一张强中",
  ["n_kuangle-draw"] = "摸一张牌，本回合使用此颜色牌不能再选择此项",
  ["n_kuangle-recover"] = "回复1点体力",
  ["n_kuangle-disresponsive"] = "你使用的下一张牌不可被响应",
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