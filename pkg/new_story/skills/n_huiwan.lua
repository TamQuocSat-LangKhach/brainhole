local n_huiwan = fk.CreateSkill {

  name = "n_huiwan",

  tags = {},

}



n_huiwan:addEffect("active", {
  name = "n_huiwan",
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
