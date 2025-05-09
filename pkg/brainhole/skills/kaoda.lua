local kaoda = fk.CreateSkill{
  name = "n_kaoda",
}

Fk:loadTranslationTable{
  ["n_kaoda"] = "拷打",
  [":n_kaoda"] = "出牌阶段限一次，你可以摸一张牌并控制一名其他角色，直到回合结束或有角色进入濒死阶段。",
  ["@@n_kaoda-turn"] = "被拷打",
  ["#n_kaoda-active"] = "拷打：控制一名其他角色",
}

kaoda:addEffect('active', {
  anim_type = "offensive",
  prompt = "#n_kaoda-active",
  max_card_num = 0,
  target_num = 1,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected, selected_cards)
    return #selected == 0 and to_select ~= player
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    player:drawCards(1, self.name)
    room:addPlayerMark(target, "@@n_kaoda-turn")
    player:control(target)
  end,
})

local refresh_fn = function(self, event, target, player, data)
  local room = player.room
  for _, p in ipairs(room.alive_players) do
    if p:getMark("@@n_kaoda-turn") > 0 then
      p:control(p)
    end
  end
end

kaoda:addEffect(fk.EnterDying, {
  can_refresh = Util.TrueFunc,
  on_refresh = refresh_fn,
})

kaoda:addEffect(fk.AfterTurnEnd, {
  can_refresh = function(self, event, target, player, data)
    return target == player
  end,
  on_refresh = refresh_fn,
})

return kaoda
