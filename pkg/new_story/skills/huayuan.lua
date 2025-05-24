local huayuan = fk.CreateSkill {
  name = "n_huayuan",
}

Fk:loadTranslationTable{
  ["n_huayuan"] = "化缘",
  [":n_huayuan"] = "摸牌阶段开始时，你可以获得上家的两张牌，然后交给其两张牌（均明置，不足则不给），若这四张牌的花色：各不相同，你摸两张牌；"..
  "都相同，你回复一点体力。",

  ["#n_huayuan-give"] = "化缘：请交给上家两张牌，根据四张牌的花色情况执行效果",
}

huayuan:addEffect(fk.EventPhaseStart, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(huayuan.name)
      and player.phase == Player.Draw and #player:getLastAlive():getCardIds("he") >= 2
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local prev = player:getLastAlive() --[[@as ServerPlayer]]
    local t = {}
    local cd=room:askToChooseCards(player,{
      target=prev ,
      min=2,
      max=2,
      flag="he",
      skill_name=huayuan.name,
    })
    table.insertTable(t, cd)
    local tmp = Fk:cloneCard 'slash'
    tmp:addSubcards(cd)
    room:obtainCard(player, tmp, true)
    if #player:getCardIds("he") < 2 then return end
    local cards=room:askToCards(player,{
      max_num=2,
      min_num=2,
      include_equip=true,
      skill_name=huayuan.name,
      cancelable=false,
      prompt="#n_huayuan-give",
    })
    table.insertTable(t, cards)
    tmp = Fk:cloneCard 'slash'
    tmp:addSubcards(cards)
    room:obtainCard(prev, tmp, true, fk.ReasonGive)
    if #t == 4 then
      local t2 = table.map(t, function(cid) return Fk:getCardById(cid).suit end)
      if t2[1] == t2[2] and t2[1] == t2[3] and t2[1] == t2[4] then
        if player:isWounded() then room:recover { num = 1, who = player } end
      elseif t2[1] ~= t2[2] and t2[1] ~= t2[3] and t2[1] ~= t2[4] and
        t2[2] ~= t2[3] and t2[2] ~= t2[4] and t2[3] ~= t2[4] then
        player:drawCards(2, huayuan.name)
      end
    end
  end,
})

return huayuan