local n_huiwan = fk.CreateSkill {
  name = "n_huiwan",
}

Fk:loadTranslationTable{
  ["n_huiwan"] = "会玩",
  [":n_huiwan"] = "出牌阶段限一次，你可以弃置任意张牌并摸等量的牌。若你以此法弃置了所有的手牌，你多摸一张牌。",

  ["n_huiwan_dont_use"] = "我觉得自己已经很会玩了，不需要“会玩”",
  ["n_huiwan_ak"] = "将AK置顶，若有则再将若干张【杀】置顶",
  ["n_huiwan_exnihilo"] = "将尽可能多的无中生有置顶",
  ["n_huiwan_snatch"] = "将一张拆和尽可能多的顺手置顶",
  ["n_huiwan_aoe"] = "将尽可能多的AOE和决斗置顶",
  ["n_huiwan_delay"] = "将一兵一乐置顶，摸牌后再将一张黑桃牌置顶",
  ["n_huiwan_equips"] = "小会玩龟缩防守，简单置顶装备栏缺失的装备",
  ["n_huiwan_peach"] = "状态有点差，将最多等同于损失体力值的桃子置顶",

  ["$n_huiwan1"] = "不急，吾等必一击制敌。",
  ["$n_huiwan2"] = "纵横捭阖，自有制衡之道。",
}

n_huiwan:addEffect("active", {
  anim_type = "drawcard",
  min_card_num = 1,
  target_num = 0,
  interaction = function()
    local choices = {
      "n_huiwan_dont_use",
      "n_huiwan_ak",
      "n_huiwan_exnihilo",
      "n_huiwan_snatch",
      "n_huiwan_aoe",
      "n_huiwan_delay",
      "n_huiwan_equips",
      "n_huiwan_peach",
    }
    for _, id in ipairs(Fk:getAllCardIds()) do
      local card = Fk:getCardById(id)
      if not card.is_derived then
        table.insertIfNeed(choices, card.name)
      end
    end
    return UI.ComboBox {
      choices = choices,
    }
  end,
  can_use = function(self, player)
    return player:usedSkillTimes(n_huiwan.name, Player.HistoryPhase) == 0
  end,
  on_use = function(self, room, effect)
    local from = effect.from
    local hand = from:getCardIds(Player.Hand)
    local more = #hand > 0
    for _, id in ipairs(hand) do
      if not table.contains(effect.cards, id) then
        more = false
        break
      end
    end
    room:throwCard(effect.cards, n_huiwan.name, from, from)
    if from.dead then return end
    local total = #effect.cards + (more and 1 or 0)
    local choice = self.interaction.data
    local ids = {}
    if choice == "n_huiwan_dont_use" then
    elseif choice == "n_huiwan_exnihilo" then
      ids = room:getCardsFromPileByRule("ex_nihilo", total)
    elseif choice == "n_huiwan_peach" then
      ids = room:getCardsFromPileByRule("peach", math.min(total, from:getLostHp()))
    elseif choice == "n_huiwan_aoe" then
      ids = room:getCardsFromPileByRule("savage_assault,archery_attack,duel", total)
    elseif choice == "n_huiwan_delay" then
      local ak = room:getCardsFromPileByRule("indulgence", 1)[1]
      ids = room:getCardsFromPileByRule("supply_shortage", 1)
      table.insert(ids, ak)
    elseif choice == "n_huiwan_ak" then
      ids = room:getCardsFromPileByRule("crossbow", 1)
      if #ids > 0 then
        local ak = ids[1]
        ids = room:getCardsFromPileByRule("slash", total - 1)
        table.insert(ids, ak)
      end
    elseif choice == "n_huiwan_snatch" then
      ids = room:getCardsFromPileByRule("dismantlement", 1)
      local ak = ids[1]
      ids = room:getCardsFromPileByRule("snatch", ak and total - 1 or total)
      table.insert(ids, ak)
    elseif choice == "n_huiwan_equips" then
      local player = from
      if not player:getEquipment(Card.SubtypeWeapon) then
        table.insert(ids, room:getCardsFromPileByRule(".|.|.|.|.|weapon", 1)[1])
      end
      if not player:getEquipment(Card.SubtypeArmor) then
        table.insert(ids, room:getCardsFromPileByRule(".|.|.|.|.|armor", 1)[1])
      end
      if not player:getEquipment(Card.SubtypeDefensiveRide) then
        table.insert(ids, room:getCardsFromPileByRule(".|.|.|.|.|defensive_ride", 1)[1])
      end
      if not player:getEquipment(Card.SubtypeOffensiveRide) then
        table.insert(ids, room:getCardsFromPileByRule(".|.|.|.|.|offensive_ride", 1)[1])
      end
      if not player:getEquipment(Card.SubtypeTreasure) then
        table.insert(ids, room:getCardsFromPileByRule(".|.|.|.|.|treasure", 1)[1])
      end
    else
      ids = room:getCardsFromPileByRule(choice, 1)
    end
    for _, id in ipairs(ids) do
      table.removeOne(room.draw_pile, id)
    end
    for _, id in ipairs(ids) do
      table.insert(room.draw_pile, 1, id)
    end
    room:drawCards(from, total, n_huiwan.name)
    if choice == "n_huiwan_delay" then
      local spade
      for i, id in ipairs(room.draw_pile) do
        if Fk:getCardById(id).suit == Card.Spade then
          spade = id
          table.remove(room.draw_pile, i)
          break
        end
      end
      if spade then
        table.insert(room.draw_pile, 1, spade)
      end
    end
    if from:hasSkill("n_jiequanisbest") then
      if room:askToSkillInvoke(from, {
            skill_name = "n_jiequanisbest"
          }) then
        room:notifySkillInvoked(from, "n_jiequanisbest", "special")
        room:delay(2000)
        room:gameOver(from.role)
      end
    end
  end
})

return n_huiwan
