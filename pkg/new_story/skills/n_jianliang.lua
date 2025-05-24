local n_jianliang = fk.CreateSkill {
  name = "n_jianliang",
}

Fk:loadTranslationTable{
  ["n_jianliang"] = "监粮",
  [":n_jianliang"] = "游戏开始前，你将牌堆中所有【桃】置于武将牌上，称为“粮”；然后再令所有角色获得技能“分粮”。",

  ["n_liang"] = "粮",
}

n_jianliang:addEffect(fk.GamePrepared, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(n_jianliang.name) and #player.room:getCardsFromPileByRule("peach") > 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local bigNumber = #room.draw_pile
    local peachs = Fk:cloneCard("peach")
    peachs:addSubcards(room:getCardsFromPileByRule("peach", bigNumber))
    player:addToPile("n_liang", peachs, true, n_jianliang.name)
    for _, p in ipairs(room:getAlivePlayers()) do
      room:handleAddLoseSkills(p, "n_fenliang", nil, false)
    end
  end,
})

return n_jianliang