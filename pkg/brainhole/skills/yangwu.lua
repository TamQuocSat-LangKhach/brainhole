local yangwu = fk.CreateSkill {
  name = "n_yangwu",
  tags = { Skill.Compulsory, },
}

Fk:loadTranslationTable{
  ["n_yangwu"] = "扬雾",
  [":n_yangwu"] = "锁定技，游戏开始时，将1张【悦刻五】加入牌堆；游戏开始时或准备阶段，若你的装备区没有【悦刻五】，你从任意区域获得并使用之；"..
  "若有，你选择是否重铸任意张手牌。你以此法从其他玩家处获得【悦刻五】后，对其造成1点伤害。",

  ["#n_yangwu-recast"] = "扬雾: 请重铸任意张手牌，或者点取消不重铸",
}

local U = require "packages/utility/utility"

local relx = { {"n_relx_v", Card.Spade, 12} }

local spec = {
  on_use = function(self, event, target, player, data)
    local room = player.room
    local treasure = player:getEquipment(Card.SubtypeTreasure)
    if not treasure or Fk:getCardById(treasure).name ~= "n_relx_v" then
      local id = U.prepareDeriveCards(player.room, relx, "yangwu_derivedcards")[1]
      local owner = room:getCardOwner(id) --[[ @as ServerPlayer ]]
      room:obtainCard(player, id, false, fk.ReasonPrey)
      if owner and owner ~= player and not owner.dead then
        room:damage { from = player, to = owner, damage = 1 }
      end
      if not player.dead then
        room:useCard({
          from = player,
          tos = { player},
          card = Fk:getCardById(id, true),
        })
      end
    elseif Fk:getCardById(treasure).name == "n_relx_v" then
      if not player:isKongcheng() then
        local cards = room:askToCards(player, {
          min_num = 1,
          max_num = 999,
          include_equip = false,
          skill_name = yangwu.name,
          prompt = "#n_yangwu-recast",
          cancelable = true,
        })
        if #cards > 0 then room:recastCard(cards, player, yangwu.name) end
      end
    end
  end,
}

yangwu:addEffect(fk.GameStart, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(yangwu.name)
  end,
  on_use = spec.on_use,

  can_refresh = function (self, event, target, player, data)
    return player:hasSkill(yangwu.name)
  end,
  on_refresh = function (self, event, target, player, data)
    local room = player.room
    local name = "n_relx_v"
    local cards = {
      {name, Card.Spade, 12},
    }
    for _, id in ipairs(U.prepareDeriveCards(room, cards, yangwu.name)) do
      if room:getCardArea(id) == Card.Void then
        table.removeOne(room.void, id)
        table.insert(room.draw_pile, math.random(1, #room.draw_pile), id)
        room:setCardArea(id, Card.DrawPile, nil)
      end
    end
    room:syncDrawPile()
    room:doBroadcastNotify("UpdateDrawPile", tostring(#room.draw_pile))
  end
})

yangwu:addEffect(fk.EventPhaseStart, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(yangwu.name) and player.phase == Player.Start
  end,
  on_use = spec.on_use,
})

return yangwu