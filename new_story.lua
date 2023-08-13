local extension = Package("brainhole_new_story")
extension.extensionName = "brainhole"

Fk:loadTranslationTable{
  ["brainhole_new_story"] = "脑洞-新的故事",
}

local n_guoxiu = General(extension, "n_guoxiu", "wei", 4)
local n_cizhi = fk.CreateTriggerSkill{
  name = "n_cizhi",
  anim_type = "offensive",
  events = {fk.Damage},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and
      data.to:isAlive() and player.hp <= data.to.hp
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:damage {
      from = player,
      to = data.to,
      damage = 1,
    }
  end,
}
n_guoxiu:addSkill(n_cizhi)
Fk:loadTranslationTable{
  ["n_guoxiu"] = "郭修",
  ["n_cizhi"] = "刺智",
  [":n_cizhi"] = "当你对一名角色造成伤害后，若你的体力值不大于其，" ..
    "则你可以对其造成一点伤害。",
}

local n_wanghou = General(extension, "n_wanghou", "wei", 3)
local n_jianliang = fk.CreateTriggerSkill{
  name = "n_jianliang",
  anim_type = "control",
  events = {fk.GamePrepared},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self.name) and #player.room:getCardsFromPileByRule("peach") > 0
  end,
  on_cost = function(self, event, target, player, data)
    return true
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local bigNumber = #room.draw_pile
    local peachs = Fk:cloneCard("peach")
    peachs:addSubcards(room:getCardsFromPileByRule("peach", bigNumber))
    player:addToPile("n_liang", peachs, true, self.name)
    for _, p in ipairs(room.players) do
      room:handleAddLoseSkills(p, "n_fenliang", nil, true, false)
    end
  end,
}
local n_fenliang = fk.CreateActiveSkill{
  name = "n_fenliang",
  anim_type = "support",
  card_num = 3,
  target_num = 1,
  card_filter = function(self, to_select, selected)
    return #selected < 3 and Fk:currentRoom():getCardArea(to_select) ~= Player.Equip
  end,
  target_filter = function(self, to_select, selected)
    return #selected == 0 and #Fk:currentRoom():getPlayerById(to_select):getPile("n_liang") > 0
  end,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name) == 0 and player:isWounded()
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    local supply = Fk:cloneCard("peach")
    supply:addSubcards(table.random(
      target:getPile("n_liang"),
      math.min(math.random(1, player:getLostHp()), #target:getPile("n_liang"))
    ))

    local tmp = Fk:cloneCard 'slash'
    tmp:addSubcards(effect.cards)
    room:obtainCard(target, tmp, false, fk.ReasonGive)
    room:obtainCard(player, supply, false)
  end,
}
local n_anjun = fk.CreateTriggerSkill{
  name = "n_anjun",
  anim_type = "negative",
  frequency = Skill.Compulsory,
  events = {fk.DamageCaused},
  can_trigger = function(self, event, target, player, data)
    return data.to == player and player:hasSkill(self.name) and #player:getPile("n_liang") == 0 and
    target and (table.contains({"caocao", "godcaocao"}, Fk.generals[target.general].trueName) or target.role == "lord")
  end,
  on_use = function(self, event, target, player, data)
    data.damage = data.damage + 1
  end,
}
n_wanghou:addSkill(n_jianliang)
n_wanghou:addRelatedSkill(n_fenliang)
n_wanghou:addSkill(n_anjun)
Fk:loadTranslationTable{
  ["n_wanghou"] = "王垕",
  ["n_jianliang"] = "监粮",
  [":n_jianliang"] = "游戏开始前，你将牌堆中所有【桃】置于武将牌上，称为“粮”；然后再令所有角色获得技能“分粮”。",
  ["n_fenliang"] = "分粮",
  [":n_fenliang"] = "出牌阶段限一次，若你已受伤，你可以交给有“粮”的角色三张手牌，从“粮”中获得随机的1~X张牌（X为你损失体力值）。",
  ["n_anjun"] = "安军",
  [":n_anjun"] = "锁定技，若你没有“粮”，曹操或者主公对你造成的伤害+1。",
  ["n_liang"] = "粮",
}

local n_jiequan = General(extension, "n_jiequan", "wu", 4)
n_jiequan.hidden = true
local n_huiwan = fk.CreateActiveSkill{
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
    return player:usedSkillTimes(self.name) == 0
  end,
  on_use = function(self, room, effect)
    local from = room:getPlayerById(effect.from)
    local hand = from:getCardIds(Player.Hand)
    local more = #hand > 0
    for _, id in ipairs(hand) do
      if not table.contains(effect.cards, id) then
        more = false
        break
      end
    end
    room:throwCard(effect.cards, self.name, from, from)

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

    room:drawCards(from, total, self.name)

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
      if room:askForSkillInvoke(from, "n_jiequanisbest") then
        room:notifySkillInvoked(from, "n_jiequanisbest", "special")
        room:delay(2000)
        room:gameOver(from.role)
      end
    end
  end
}
n_jiequan:addSkill(n_huiwan)
--[[
local n_dayou = fk.CreateActiveSkill{
  name = "n_dayou",
  anim_type = "control",
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  card_filter = function(self, card)
    return false
  end,
  card_num = 0,
  target_num = 0,
  on_use = function(self, room, effect)
    local from = room:getPlayerById(effect.from)
    local c = Fk:cloneCard'slash'
    c:addSubcards(room.discard_pile)
    room:obtainCard(from, c)
  end,
}
--n_jiequan:addSkill(n_dayou)
local n_duibao = fk.CreateTriggerSkill{
  name = "n_duibao",
  anim_type = "defensive",
  events = {fk.TargetConfirming},
  can_trigger = function(self, event, target, player, data)
    local ret = target == player and player:hasSkill(self.name) and
      data.card.trueName == "slash"
    return ret
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = data.from
    room:doIndicate(player.id, { to })
    TargetGroup:removeTarget(data.targetGroup, player.id)
    room:damage{ from = player, to = room:getPlayerById(to), damage = 1, }
  end,
}
n_jiequan:addSkill(n_duibao)
--]]
local n_jiequanisbest = fk.CreateTriggerSkill{
  name = "n_jiequanisbest",
}
n_jiequan:addSkill(n_jiequanisbest)
Fk:loadTranslationTable{
  ["n_jiequan"] = "界权",
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

  ["n_dayou"] = "大优",
  [":n_dayou"] = "出牌阶段限一次，你可以将弃牌堆置入手中。若你以此法直接卡死，作者概不负责。",
  ["n_duibao"] = "对爆",
  [":n_duibao"] = "当你成为【杀】的目标后，你可以取消自己为目标，然后对使用者造成1点伤害。",
  ["n_jiequanisbest"] = "信界权得永生",
  [":n_jiequanisbest"] = "你发动“会玩”后，可以获胜。",

  ["$n_huiwan1"] = "不急，吾等必一击制敌。",
  ["$n_huiwan2"] = "纵横捭阖，自有制衡之道。",
  ["~n_jiequan"] = "父兄大计，权，实憾矣。",
}

local guanning = General(extension, "n_guanning", "qun", 3, 7)
local n_dunshi_names = {"dismantlement", "snatch", "ex_nihilo", "collateral", "nullification", "daggar_in_smile", "underhanding"}
local n_dunshi = fk.CreateViewAsSkill{
  name = "n_dunshi",
  pattern = table.concat(n_dunshi_names, ","),
  interaction = function()
    local all_names, names = n_dunshi_names, {}
    local mark = Self:getMark("n_dunshi")
    for _, name in ipairs(all_names) do
      if type(mark) ~= "table" or not table.contains(mark, name) then
        local to_use = Fk:cloneCard(name)
        if ((Fk.currentResponsePattern == nil and Self:canUse(to_use) and not Self:prohibitUse(to_use)) or
            (Fk.currentResponsePattern and Exppattern:Parse(Fk.currentResponsePattern):match(to_use))) then
          table.insertIfNeed(names, name)
        end
      end
    end
    if #names == 0 then return end
    return UI.ComboBox {choices = names}
  end,
  card_filter = function()
    return false
  end,
  view_as = function(self, cards)
    if not self.interaction.data then return nil end
    local card = Fk:cloneCard(self.interaction.data)
    card.skillName = self.name
    return card
  end,
  before_use = function(self, player, use)
    player.room:setPlayerMark(player, "n_dunshi_name-turn", use.card.trueName)
  end,
  enabled_at_play = function(self, player)
    if player:usedSkillTimes(self.name, Player.HistoryTurn) > 0 then return false end
    local names = n_dunshi_names
    local mark = Self:getMark("n_dunshi")
    for _, name in ipairs(names) do
      if type(mark) ~= "table" or not table.contains(mark, name) then
        local to_use = Fk:cloneCard(name)
        if Self:canUse(to_use) and not Self:prohibitUse(to_use) then
          return true
        end
      end
    end
  end,
  enabled_at_response = function(self, player, response)
    if player:usedSkillTimes(self.name, Player.HistoryTurn) > 0 then return false end
    local names = n_dunshi_names
    local mark = Self:getMark("n_dunshi")
    for _, name in ipairs(names) do
      if type(mark) ~= "table" or not table.contains(mark, name) then
        local to_use = Fk:cloneCard(name)
        if (Fk.currentResponsePattern and Exppattern:Parse(Fk.currentResponsePattern):match(to_use)) then
          return true
        end
      end
    end
  end,
}
local n_dunshi_record = fk.CreateTriggerSkill{
  name = "#n_dunshi_record",
  anim_type = "special",
  events = {fk.DamageCaused},
  can_trigger = function(self, event, target, player, data)
    if player:usedSkillTimes("n_dunshi", Player.HistoryTurn) > 0 and target and target.phase ~= Player.NotActive then
      if target:getMark("n_dunshi-turn") == 0 then
        player.room:addPlayerMark(target, "n_dunshi-turn", 1)
        return true
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    return true
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local choices = {"n_dunshi1", "n_dunshi2", "n_dunshi3"}
    local tech = {
      "崩", "急", "典", "孝", "乐", "赢",
                        "笑",       "营",
    }
    for i = 1, 2, 1 do
      local choice = room:askForChoice(player, choices, self.name)
      table.removeOne(choices, choice)
      if choice == "n_dunshi1" then
        local skills = {}
        for _, general in ipairs(Fk:getAllGenerals()) do
          for _, skill in ipairs(general.skills) do
            local str = Fk:translate(skill.name)
            if table.find(tech, function(s) return string.find(str, s) end) then
              local name = skill.name
              if not target:hasSkill("n_yingma") and (target:hasSkill(skill) or string.find(name, "&")) then
                name = "n_yingma"
              end
              if not target:hasSkill(name, true) then
                table.insertIfNeed(skills, name)
              end
            end
          end
        end
        if #skills > 0 then
          local skill = room:askForChoice(player, table.random(skills, math.min(3, #skills)), self.name, "#n_dunshi-chooseskill::"..target.id, true)
          room:handleAddLoseSkills(target, skill, nil, true, false)
        end
      elseif choice == "n_dunshi2" then
        room:changeMaxHp(player, -1)
        if not player.dead and player:getMark("n_dunshi") ~= 0 then
          player:drawCards(#player:getMark("n_dunshi"), "n_dunshi")
        end
      elseif choice == "n_dunshi3" then
        local mark = player:getMark("n_dunshi")
        if mark == 0 then
          mark = {}
        end
        table.insert(mark, player:getMark("n_dunshi_name-turn"))
        room:setPlayerMark(player, "n_dunshi", mark)

        local UImark = player:getMark("@$n_dunshi")
        if type(UImark) == "table" then
          table.removeOne(UImark, player:getMark("n_dunshi_name-turn"))
          room:setPlayerMark(player, "@$n_dunshi", UImark)
        end
      end
    end
    if not table.contains(choices, "n_dunshi1") then
      return true
    end
  end,

  refresh_events = {fk.EventLoseSkill, fk.EventAcquireSkill},
  can_refresh = function(self, event, target, player, data)
    return player == target and data == self
  end,
  on_refresh = function(self, event, target, player, data)
    if event == fk.EventAcquireSkill then
      player.room:setPlayerMark(player, "@$n_dunshi", n_dunshi_names)
    else
      player.room:setPlayerMark(player, n_dunshi.name, 0)
      player.room:setPlayerMark(player, "@$n_dunshi", 0)
    end
  end,
}

local n_yingma = fk.CreateTriggerSkill{
  name = "n_yingma",
  --mute = true,
  frequency = Skill.Compulsory,
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and player.phase == Player.Start
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    --[[
    if player:isWounded() then
      room:recover({
        who = player,
        num = 1,
        recoverBy = player,
        skillName = self.name
      })
    end
    ]]--
    if player.maxHp < 7 then
      room:changeMaxHp(player, 1)
    end
  end,
}
Fk:addSkill(n_yingma)
n_dunshi:addRelatedSkill(n_dunshi_record)
guanning:addSkill(n_dunshi)
guanning:addRelatedSkill("n_yingma")
Fk:loadTranslationTable{
  ["n_guanning"] = "菅宁",
  ["n_dunshi"] = "炖世",
  [":n_dunshi"] = "每回合限一次，你可视为使用一张君子锦囊（拆顺无借懈笑瞒），然后当前回合角色本回合下次造成伤害时，你选择两项：<br>"..
  "1.防止此伤害，选择1个名字含有“典急孝乐崩赢”的同音字的技能令其获得；<br>"..
  "2.减1点体力上限并摸X张牌（X为你选择3的次数）；<br>"..
  "3.删除你本次视为使用的牌名。",
  ["#n_dunshi_record"] = "炖世",
  ["@$n_dunshi"] = "炖世",
  ["n_dunshi1"] = "防止此伤害，选择1个“君子六艺”的技能令其获得",
  ["n_dunshi2"] = "减1点体力上限并摸X张牌",
  ["n_dunshi3"] = "删除你本次视为使用的牌名",
  ["#n_dunshi-chooseskill"] = "炖世：选择令%dest获得的技能",

  ["n_yingma"] = "赢麻",
  -- [":n_yingma"] = "这个神秘技能不会出现在你的技能框里，但是你赢麻了。",
  [":n_yingma"] = "锁定技，准备阶段，若你体力上限小于7，加一点上限。",

  ["$n_dunshi1"] = "天下皆黑，于我独白。",
  ["$n_dunshi2"] = "我不忿世，唯炖之而自觞。",
  ["~n_guanning"] = "近城远山，皆是人间。",
}

local caocao = General(extension, "n_jz__caocao", "wei", 4)
local jianxiong = fk.CreateTriggerSkill{
  name = "n_jianxiong",
  anim_type = "masochism",
  events = {fk.Damaged},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) 
  end,
  on_cost = function(self, event, target, player, data)
    local choices = {'n_jianxiong_draw'}
    if data.card and target.room:getCardArea(data.card) == Card.Processing then
      table.insert(choices, 'n_jianxiong_get')
    end
    table.insert(choices, 'Cancel')
    local choice = player.room:askForChoice(player, choices, self.name)
    if choice ~= "Cancel" then
      self.cost_data = choice
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    if self.cost_data == "n_jianxiong_draw" then
      player:drawCards(1, self.name)
    elseif self.cost_data == "n_jianxiong_get" then
      player.room:obtainCard(player.id, data.card, true, fk.ReasonJustMove)
    end
  end,
}
caocao:addSkill(jianxiong)
local dianlun = fk.CreateTriggerSkill{
  name = "n_dianlun",
  frequency = Skill.Compulsory,
  events = {fk.AfterCardsMove},
  mute = true,
  can_trigger = function(self, event, target, player, data)
    if player.phase == Player.Draw or not player:hasSkill(self.name) then return end
    if player:usedSkillTimes(self.name, Player.HistoryTurn) > 0 then return end
    local room = player.room
    for _, move in ipairs(data) do
      if move.to == player.id and move.toArea == Card.PlayerHand then
        for _, info in ipairs(move.moveInfo) do
          local id = info.cardId
          if room:getCardArea(id) == Card.PlayerHand and room:getCardOwner(id) == player then
            return true
          end
        end
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if player:isAllNude() then return end
    room:askForDiscard(player, 1, 1, true, self.name, false, nil, "#n_dianlun_start")
    local classic = {
      'n_cc_lunying',
      'n_cc_gexu',
      'n_cc_duoqi',
      'n_cc_sanxiao',
      'n_cc_jiamei',
      'n_cc_gongzhen',
    }
    if not table.find(room.alive_players, function(p) return p.gender == General.Female end) then
      table.removeOne(classic, 'n_cc_gongzhen')
      if not table.find(room.players, function(p) return p.dead == true end) then
        table.removeOne(classic, 'n_cc_duoqi')
      end
    end

    if player:getMark('n_cc_duoqi') ~= 0 then
      table.removeOne(classic, 'n_cc_duoqi')
    end

    if #player:getCardIds('e') == 0 or not player:isWounded() then
      table.removeOne(classic, 'n_cc_gexu')
    end

    room:notifySkillInvoked(player, self.name, 'special')

    local choices = table.random(classic, 2)
    local choice = room:askForChoice(player, choices, self.name, nil, true)

    if choice == 'n_cc_lunying' then
      local to = room:askForChoosePlayers(player,
        table.map(room:getOtherPlayers(player), Util.IdMapper), 1, 1,
        '#n_cc_lunying', self.name, false)[1]
      local tgt = room:getPlayerById(to)

      room:broadcastSkillInvoke(self.name, 1)
      room:notifySkillInvoked(player, 'n_cc_lunying', 'special')

      while true do
        if player.dead then break end
        if tgt.dead then break end

        local judge = {
          who = player,
          reason = self.name,
          pattern = ".|2~9|spade",
        }
        room:judge(judge)
        local result = judge.card
        if result.suit == Card.Spade and result.number >= 2 and result.number <= 9 then
          room:damage{
            to = judge.who,
            damage = 3,
            damageType = fk.ThunderDamage,
            skillName = self.name,
          }
          break
        end

        if room:askForSkillInvoke(tgt, 'n_cc_lunying', nil, '#n_cc_lunying_cancel') then
          room:damage { from = tgt, to = tgt, damage = 1, damageType = fk.ThunderDamage }
          break
        end

        judge = {
          who = tgt,
          reason = self.name,
          pattern = ".|2~9|spade",
        }
        room:judge(judge)
        result = judge.card
        if result.suit == Card.Spade and result.number >= 2 and result.number <= 9 then
          room:damage{
            to = judge.who,
            damage = 3,
            damageType = fk.ThunderDamage,
            skillName = self.name,
          }
          break
        end
      end
    elseif choice == 'n_cc_gexu' then
      room:askForDiscard(player, 1, 1, true, self.name, false, '.|.|.|equip', '#n_cc_gexu')

      room:broadcastSkillInvoke(self.name, 2)
      room:notifySkillInvoked(player, 'n_cc_gexu', 'support')

      room:recover { num = 1, skillName = self.name, who = player }
    elseif choice == 'n_cc_duoqi' then
      local female = table.filter(room:getOtherPlayers(player), function(p) return p.gender == General.Female end)
      local to = room:askForChoosePlayers(player, table.map(female, Util.IdMapper), 1, 1, '#n_cc_duoqi',
        self.name, false)[1]
      local tgt = room:getPlayerById(to)

      room:broadcastSkillInvoke(self.name, 3)
      room:notifySkillInvoked(player, 'n_cc_duoqi', 'control')

      local skills = table.map(Fk.generals[tgt.general].skills, Util.NameMapper)
      local c = room:askForChoice(player, skills, self.name, "#n_cc_duoqi-choice::"..tgt.id, true)
      if not player:hasSkill(c) then
        room:handleAddLoseSkills(player, c, nil, true, true)
        player:setMark('n_cc_duoqi', 1)
      end
    elseif choice == 'n_cc_sanxiao' then
      local to = room:askForChoosePlayers(player,
        table.map(room:getOtherPlayers(player), Util.IdMapper), 1, 1,
        '#n_cc_sanxiao', self.name, false)[1]
      local tgt = room:getPlayerById(to)

      room:broadcastSkillInvoke(self.name, 4)
      room:notifySkillInvoked(player, 'n_cc_sanxiao', 'masochism')

      local use = room:askForUseCard(tgt, "slash", nil, "#n_cc_sanxiao-use", false, {
        must_targets = { player.id },
        bypass_distances = true,
      })
      if use then room:useCard(use) end
      if (not use) or not use.damageDealt[player.id] then
        room:addPlayerMark(tgt, MarkEnum.UncompulsoryInvalidity .. "-turn")
      end
    elseif choice == 'n_cc_jiamei' then
      local to = room:askForChoosePlayers(player,
        table.map(room:getOtherPlayers(player), Util.IdMapper), 1, 1,
        '#n_cc_jiamei', self.name, false)[1]
      local tgt = room:getPlayerById(to)

      room:broadcastSkillInvoke(self.name, 5)
      room:notifySkillInvoked(player, 'n_cc_jiamei', 'offensive')

      tgt:drawCards(1, self.name)
      room:useVirtualCard('slash', nil, player, tgt, self.name, true)
    elseif choice == 'n_cc_gongzhen' then
      local female = table.filter(room:getOtherPlayers(player), function(p) return p.gender == General.Female end)
      local to = room:askForChoosePlayers(player, table.map(female, Util.IdMapper), 1, 1, '#n_cc_gongzhen',
        self.name, false)[1]
      local tgt = room:getPlayerById(to)

      room:broadcastSkillInvoke(self.name, 6)
      room:notifySkillInvoked(player, 'n_cc_gongzhen', 'control')

      player:drawCards(1, self.name)
      tgt:drawCards(1, self.name)
      player:turnOver()
      tgt:turnOver()
    end
  end,
}
caocao:addSkill(dianlun)
Fk:loadTranslationTable{
  ['n_jz__caocao'] = '典曹操',
  ['n_jianxiong'] = '奸雄',
  [':n_jianxiong'] = '当你受到伤害后，你可以选择： 1. 获得伤害牌；2. 摸一张牌。',
  ['n_jianxiong_draw'] = '摸一张牌',
  ['n_jianxiong_get'] = '获得伤害牌',
  ['n_dianlun'] = '典论',
  [':n_dianlun'] = '锁定技，每回合限一次，你在摸牌阶段外获得牌后，你须弃置一张牌并从随机2个典中爆一次典。' ..
    '<br/><font color="blue">*论英：令你和一名其他角色依次进行闪电判定，直到有一方受到伤害为止，' ..
    '其在开始判定之前可以对自己造成1点雷电伤害中止此流程。' ..
    '<br/>*割须：弃置装备区的1张牌并回复1点体力。' ..
    '<br/>*夺妻：整局游戏限一次，获得一名其他女性角色武将牌上的一个技能。' ..
    '<br/>*三笑：指定一名角色，令其对你用一张无视距离的【杀】，若此杀未造成伤害，其本回合非锁定技失效。' ..
    '<br/>*假寐：你令一名其他角色摸1张牌，再视为对其使用一张【杀】。' ..
    '<br/>*共枕：指定一名女性角色，和你各摸1张牌并翻面。</font>',
  ['#n_dianlun_start'] = '典论: 请弃置一张牌并爆典',
  ['n_cc_lunying'] = '论英',
  [':n_cc_lunying'] = '令你和一名其他角色依次进行闪电判定，直到有一方受到伤害为止，其在开始判定之前可以对自己造成1点雷电伤害中止此流程。',
  ['#n_cc_lunying'] = '论英: 选择一名其他角色，和他谈论当世英雄！',
  ['#n_cc_lunying_cancel'] = '论英: 你现在可以对自己造成一点雷电伤害并中止“论英”',
  ['n_cc_gexu'] = '割须',
  [':n_cc_gexu'] = '弃置装备区的1张牌并回复1点体力。',
  ['#n_cc_gexu'] = '割须: 请弃置一张装备牌，回复1点体力',
  ['n_cc_duoqi'] = '夺妻',
  [':n_cc_duoqi'] = '获得一名其他女性角色武将牌上的一个技能。',
  ['#n_cc_duoqi'] = '夺妻: 选择一名女性角色，永久获得她的一个技能',
  ['#n_cc_duoqi-choice'] = '夺妻: 获得 %dest 的一个技能',
  ['n_cc_sanxiao'] = '三笑',
  [':n_cc_sanxiao'] = '指定一名角色，令其对你用一张无视距离的【杀】，若此杀未造成伤害，其本回合非锁定技失效。',
  ['#n_cc_sanxiao'] = '三笑: 令一名其他角色【杀】你，若没杀中则其本回合非锁定技失效',
  ['#n_cc_sanxiao-use'] = '三笑: 请对曹操出杀，不杀或未杀中则本回合非锁定技失效',
  ['n_cc_jiamei'] = '假寐',
  [':n_cc_jiamei'] = '你令一名其他角色摸1张牌，再视为对其使用一张【杀】。',
  ['#n_cc_jiamei'] = '假寐: 令一名其他角色摸一张牌并视为对其出【杀】',
  ['n_cc_gongzhen'] = '共枕',
  [':n_cc_gongzhen'] = '指定一名其他女性角色，和你各摸1张牌并翻面。',
  ['#n_cc_gongzhen'] = '共枕: 与一名女性角色各摸一张并翻面',
}

local xuchu = General(extension, "n_jz__xuchu", "wei", 4)
local luoyi = fk.CreateTriggerSkill{
  name = 'n_luoyi',
  anim_type = "offensive",
  events = {fk.DrawNCards},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and data.n > 0
  end,
  on_use = function(self, event, target, player, data)
    data.n = data.n - 1
    player.room:addPlayerMark(player, "@@n_luoyi", 1)
  end,

  refresh_events = {fk.EventPhaseStart},
  can_refresh = function(self, event, target, player, data)
    return target == player and player.phase == Player.RoundStart
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "@@n_luoyi", 0)
  end,
}
local luoyi_trigger = fk.CreateTriggerSkill{
  name = "#n_luoyi_trigger",
  mute = true,
  events = {fk.DamageCaused},
  can_trigger = function(self, event, target, player, data)
    return target == player and not data.chain and data.card and
      ((player:getMark("@@n_luoyi") > 0 and (data.card.trueName == "slash" or data.card.name == "duel")) or
      (player:hasSkill(luoyi.name) and #player:getCardIds("e") == 0 and data.card.name == "slash"))
  end,
  on_cost = function(self, event, target, player, data)
    return true
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:broadcastSkillInvoke("n_luoyi")
    room:notifySkillInvoked(player, "n_luoyi")
    if player:getMark("@@n_luoyi") > 0 and (data.card.trueName == "slash" or data.card.name == "duel") then
      data.damage = data.damage + 1
    end
    if player:hasSkill(luoyi.name) and #player:getCardIds("e") == 0 and data.card.name == "slash" then
      data.damage = data.damage + 1
    end
  end,
}
luoyi:addRelatedSkill(luoyi_trigger)
xuchu:addSkill(luoyi)
local nuzhan = fk.CreateTriggerSkill{
  name = "n_jizhan",
  anim_type = "offensive",
  events = {fk.AfterSkillEffect},
  can_trigger = function(self, _, target, player, data)
    return player:hasSkill(self.name) and player.phase == Player.NotActive and
      target and target ~= player and
      target:hasSkill(data) and data.visible and
      target:getMark("@n_jizhan-turn") > 0 and
      target:getMark("@n_jizhan-turn") % 6 == 0
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askForSkillInvoke(player, self.name, data, "#n_jizhan-invoke::"..target.id)
  end,
  on_use = function(self, _, target, player, data)
    local room = player.room
    local slash = Fk:cloneCard 'slash'
    slash.skillName = self.name
    room:useCard {
      from = player.id,
      tos = { { target.id } },
      card = slash,
      additionalDamage = target:isWounded() and 0 or 1,
      disresponsiveList = table.map(room.alive_players, Util.IdMapper),
    }
  end,

  refresh_events = {fk.AfterSkillEffect},
  can_refresh = function(self, _, target, player, data)
    return player:hasSkill(self.name) and player.phase == Player.NotActive and
      target and target ~= player and
      target:hasSkill(data) and data.visible
  end,
  on_refresh = function(self, _, target, _, _)
    local room = target.room
    room:addPlayerMark(target, "@n_jizhan-turn", 1)
  end,
}
xuchu:addSkill(nuzhan)
Fk:loadTranslationTable{
  ["n_jz__xuchu"] = "急许褚",
  ["n_luoyi"] = '裸衣',
  ["@@n_luoyi"] = '裸衣',
  [':n_luoyi'] = '摸牌阶段，你可以少摸一张牌，若如此做，直到你的下回合开始，' ..
    '你使用的【杀】或【决斗】造成的伤害+1；若你装备区里没有牌，你的普通【杀】' ..
    '造成的伤害+1。',
  ["#n_luoyi_trigger"] = '裸衣',
  ["n_jizhan"] = "急斩",
  ["@n_jizhan-turn"] = "急斩",
  ["#n_jizhan-invoke"] = "急斩: 现在你可以视为对 %dest 使用一张强中的【杀】，可能有加伤",
  [":n_jizhan"] = "你的回合外，当其他角色于一回合内每发动六次技能后，" ..
    "你可以视为对其使用了一张不可响应的【杀】；若其未受伤，此【杀】伤害基数+1。" ..
    '<br /><font color="red">（注：由于判断发动技能的相关机制尚不完善，请不要汇报关于技能发动次数统计的bug）</font>',
}

local lvbu = General(extension, "n_jz__lvbu", "qun", 4)
lvbu:addSkill("wushuang")
local yixiaoTrig = fk.CreateTriggerSkill{
  name = "#n_yixiao_trig",
  mute = true,
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target.phase == Player.Play and player:hasSkill("n_yixiao") and target:getMark("@@n_yifu") > 0
  end,
  on_cost = function() return true end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:drawCards(1, "n_yixiao")
    local duel = Fk:cloneCard 'duel'
    duel.skillName = "n_yixiao"
    if player:prohibitUse(duel) then return end
    local targets = table.filter(room.alive_players, function(p)
      return player ~= p and not player:isProhibited(p, duel)
    end)
    if #targets == 0 then return end
    local to = room:askForChoosePlayers(target, table.map(targets, Util.IdMapper),
      1, 1, "#n_yixiao-duel", "n_yixiao", false)[1]

    room:notifySkillInvoked(player, "n_yixiao", "offensive")
    room:broadcastSkillInvoke("n_yixiao", table.random{ 3, 4 })
    room:useCard {
      from = player.id,
      tos = { { to } },
      card = duel,
    }
  end,
}
local yixiao = fk.CreateTriggerSkill{
  name = "n_yixiao",
  events = {fk.EventPhaseStart},
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and player.phase == Player.Start and
    table.find(player.room.alive_players, function (p) return p ~= player and p:getMark("@@n_yifu") == 0 end)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local yifu = table.find(room.alive_players, function (p) return p:getMark("@@n_yifu") > 0 end)
    if yifu then
      local use = room:askForUseCard(target, "slash", nil, "#n_yixiao-use", true, {
        must_targets = { yifu.id },
        bypass_distances = true,
      })
      if use then
        self.cost_data = use
        return true
      end
    else
      local tos = room:askForChoosePlayers(player, table.map(room:getOtherPlayers(player), Util.IdMapper), 1, 1, "#n_yixiao-choose", self.name, false)
      if #tos > 0 then
        self.cost_data = tos
        return true
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to
    if self.cost_data[1] then
      to = self.cost_data[1]
    else
      local tgt = room:getPlayerById(self.cost_data.tos[1][1])
      room:notifySkillInvoked(tgt, self.name, "negative")
      room:broadcastSkillInvoke(self.name, table.random{ 5, 6 })
      room:useCard(self.cost_data)
      to = room:askForChoosePlayers(player, table.map(
        table.filter(room:getOtherPlayers(player), function(p)
          return p:getMark("@@n_yifu") == 0 and p ~= player
        end)
      ,Util.IdMapper), 1, 1, "#n_yixiao-move", self.name, false)[1]

      room:setPlayerMark(tgt, "@@n_yifu", 0)
    end

    room:notifySkillInvoked(player, self.name, "support")
    room:broadcastSkillInvoke(self.name, table.random{ 1, 2 })
    room:setPlayerMark(room:getPlayerById(to), "@@n_yifu", 1)
  end,
}
yixiao:addRelatedSkill(yixiaoTrig)
lvbu:addSkill(yixiao)
local panshi = fk.CreateTriggerSkill{
  name = "n_panshi",
  anim_type = "offensive",
  events = {fk.DamageCaused},
  frequency = Skill.Compulsory,
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self.name) and player == target then
      return data.to:getMark("@@n_yifu") > 0 and data.card.trueName =="slash" and not data.chain
    end
  end,
  on_use = function(self, event, target, player, data)
    local logic = player.room.logic
    data.damage = data.damage + 1
    if player.phase == Player.Play then
      local current = logic:getCurrentEvent()
      local use_event = current:findParent(GameEvent.UseCard)
      if not use_event then return end
      local phase_event = use_event:findParent(GameEvent.Phase)
      if not phase_event then return end
      use_event:addExitFunc(function()
        phase_event:shutdown()
      end)
    end
  end,
}
lvbu:addSkill(panshi)
Fk:loadTranslationTable{
  ["n_jz"] = "互联网六艺",

  ["n_jz__lvbu"] = "孝吕布",
  ["n_yixiao"] = "义孝",
  [":n_yixiao"] = "准备阶段，若场上没有“义父”，你须令一名其他角色获得“义父”标记；" ..
    "若有，你可以对其使用一张无视距离的【杀】，然后移动“义父”标记。" ..
    "“义父”的出牌阶段开始时，你摸一张牌并视为对其指定的除你以外的角色使用【决斗】。",
  ["@@n_yifu"] = "义父",
  ["#n_yixiao-choose"] = "义孝: 你必须选择一名其他角色获得“义父”标记",
  ["#n_yixiao-use"] = "义孝: 你可以对“义父”使用【杀】，之后移动“义父”标记",
  ["#n_yixiao-move"] = "义孝: 请移动“义父”标记到另一名其他角色",
  ["#n_yixiao-duel"] = "义孝: 指定一名角色，令吕布和他决斗",
  ["n_panshi"] = "叛弑",
  [":n_panshi"] = "锁定技，你使用的【杀】对“义父”造成伤害时，此伤害+1；" ..
    "若此时是你的出牌阶段，则你于【杀】结算结束后结束出牌阶段。",

  ["$n_yixiao1"] = "公若不弃，布愿拜为义父。",
  ["$n_yixiao2"] = "飘零半生，只恨未逢明主。",
  ["$n_yixiao3"] = "赴汤蹈火，在所不辞。",
  ["$n_yixiao4"] = "相助义父，共图大业。",
  ["$n_yixiao5"] = "奉先我儿！为何如此啊！",
  ["$n_yixiao6"] = "奉先，何故变心？",
  ["$n_panshi1"] = "我堂堂大丈夫，安肯为汝之义子？",
  ["$n_panshi2"] = "老贼！我与你势不两立！",
  ["~n_jz__lvbu"] = "刘备！奸贼！汝乃天下最无信义之人！",
}

return extension
