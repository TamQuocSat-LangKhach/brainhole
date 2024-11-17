local extension = Package("brainhole")

Fk:loadTranslationTable{
  ["brainhole"] = "脑洞包",
}

local U = require "packages/utility/utility"

Fk:loadTranslationTable{
  ["n_pigeon"] = "鸽",
}

local n_zy = General(extension, "n_zy", "n_pigeon", 3)
local n_juanlaotrig = fk.CreateTriggerSkill{
  name = "#n_juanlaotrig",
  refresh_events = {fk.CardUseFinished, fk.EventPhaseStart},
  can_refresh = function(self, event, target, player, data)
    if not (target == player and player:hasSkill(self)) then return end
    if event == fk.CardUseFinished then
      return data.card.type == Card.TypeTrick and
        data.card.sub_type ~= Card.SubtypeDelayedTrick and
        (not data.card:isVirtual()) and
        player.phase ~= Player.NotActive --and
        -- player:usedSkillTimes("n_juanlao", Player.HistoryPhase) == 0
    else
      return player.phase == Player.Finish
    end
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    local mark_name = "@[:]n_juanlao"
    if event == fk.CardUseFinished then
      room:setPlayerMark(player, mark_name, data.card.name)
    else
      room:setPlayerMark(player, mark_name, 0)
    end
  end,
}
local n_juanlao = fk.CreateViewAsSkill{
  name = "n_juanlao",
  -- pattern = "nullification",
  enabled_at_play = function(self, player)
    if player:usedSkillTimes(self.name, Player.HistoryPhase) > 0 then return end
    local cname = player:getMark("@[:]n_juanlao")
    if cname == 0 then return end
    return player:canUse(Fk:cloneCard(cname))
  end,
  enabled_at_response = function(self, player)
    -- FIXME: should have some way to know current response pattern here
    -- return player:getMark("@[:]n_juanlao") == "nullification"
    return false
  end,

  card_filter = function() return false end,
  view_as = function(self, cards)
    local cname = Self:getMark("@[:]n_juanlao")
    if cname == 0 then return end
    local ret = Fk:cloneCard(cname)
    return ret
  end,
}
n_juanlao:addRelatedSkill(n_juanlaotrig)
n_zy:addSkill(n_juanlao)
local n_yegeng = fk.CreateTriggerSkill{
  name = "n_yegeng",
  anim_type = "drawcard",
  frequency = Skill.Compulsory,
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and
      player.phase == Player.Finish
  end,
  on_use = function(self, event, target, player, data)
    if self.cost_data then
      player:gainAnExtraTurn()
    else
      player:drawCards(1, self.name)
    end
  end,

  refresh_events = {fk.EventPhaseStart, fk.CardUseFinished},
  can_refresh = function(self, event, target, player, data)
    if not (target == player and player:hasSkill(self)) then return end
    if event == fk.EventPhaseStart then return player.phase == Player.Finish end
    if event == fk.CardUseFinished then
      return data.card.type == Card.TypeTrick and
        data.card.sub_type ~= Card.SubtypeDelayedTrick and
        player.phase ~= Player.NotActive
    end
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    local mark_name = "@n_yegeng"
    if event == fk.EventPhaseStart then
      self.cost_data = player:getMark(mark_name) >= 3 + player:usedSkillTimes(self.name, Player.HistoryRound)
      room:setPlayerMark(player, mark_name, 0)
    else
      room:addPlayerMark(player, mark_name, 1)
    end
  end
}
n_zy:addSkill(n_yegeng)
Fk:loadTranslationTable{
  ["n_zy"] = "ＺＹ",
  ["n_juanlao"] = "奆佬",
  ["@[:]n_juanlao"] = "奆佬",
  [":n_juanlao"] = "出牌阶段限一次，你可以视为使用了本回合你使用过的" ..
    "上一张非转化普通锦囊牌。",
  ["n_yegeng"] = "夜更",
  ["@n_yegeng"] = "夜更",
  [":n_yegeng"] = "锁定技，结束阶段，若你本回合使用普通锦囊牌数量不小于3+X，" ..
    "你进行一个额外的回合，否则你摸一张牌。（X为你本轮内发动过该技能的次数）",
}

local n_wch = General(extension, "n_wch", "n_pigeon", 3)
local n_didiao = fk.CreateTriggerSkill{
  name = "n_didiao",
  anim_type = "drawcard",
  events = {fk.CardUsing},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and data.card.type == Card.TypeTrick and
      not player:isNude()
  end,
  on_cost = function(self, event, target, player, data)
    local c = player.room:askForDiscard(player, 1, 1, true, self.name, true, ".", "#n_didiao-discard", true)
    if c[1] then
      self.cost_data = c[1]
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:throwCard(self.cost_data, self.name, player, player)
    room:addPlayerMark(player, "@n_jiao", 1)
  end,
}
n_wch:addSkill(n_didiao)
local n_shenjiao_buyi = fk.CreateTriggerSkill{
  name = "#n_shenjiao",
  mute = true,
  events = {fk.EnterDying},
  can_trigger = function(self, event, target, player, data)
    return player ~= target and player:hasSkill("n_shenjiao") and player:getMark("@n_jiao") > 0
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askForSkillInvoke(player, "n_shenjiao", data, "#n_shenjiao-invoke::"..target.id)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke("n_shenjiao")
    room:notifySkillInvoked(player, "n_shenjiao", "support")
    room:removePlayerMark(player, "@n_jiao", 1)
    room:doIndicate(player.id, { target.id })
    room:recover{
      who = target,
      num = 1,
      recoverBy = player,
      skillName = self.name
    }
  end,
}
local n_shenjiao = fk.CreateActiveSkill{
  name = "n_shenjiao",
  anim_type = "drawcard",
  can_use = function (self, player, card)
    return player:getMark("@n_jiao") > 0
  end,
  card_num = 0,
  target_num = 0,
  card_filter = function() return false end,
  on_use = function (self, room, effect)
    local from = room:getPlayerById(effect.from)
    room:removePlayerMark(from, "@n_jiao", 1)
    from:drawCards(2, self.name)
  end
}
n_shenjiao:addRelatedSkill(n_shenjiao_buyi)
n_wch:addSkill(n_shenjiao)
Fk:loadTranslationTable{
  ["n_wch"] = "饺神",
  ["designer:n_wch"] = "Notify",
  ["illustrator:n_wch"] = "来自网络",
  ["n_didiao"] = "低调",
  [":n_didiao"] = "每当你使用锦囊牌后，你可以弃置一张牌，获得一枚“饺”标记。",
  ["#n_didiao-discard"] = "低调：你可以弃置一张牌，获得一枚“饺”",
  ["@n_jiao"] = "饺",
  ["n_shenjiao"] = "神饺",
  ["#n_shenjiao-invoke"] = "神饺：你可以弃置一枚“饺”来为 %dest 回复一点体力",
  [":n_shenjiao"] = "出牌阶段，你可以弃置一枚“饺”标记并摸两张牌；一名其他角色进入濒死状态时，你可以弃置一枚“饺”标记，令其回复一点体力。",
}

local n_qunlingdao = General(extension, "n_qunlingdao", "n_pigeon", 3)
local n_lingxiu = fk.CreateTriggerSkill{
  name = "n_lingxiu",
  anim_type = "drawcard",
  frequency = Skill.Compulsory,
  events = {fk.AfterCardsMove},
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(self) then return end
    local room = player.room
    if #table.filter(room:getOtherPlayers(player), function(p)
      return #p:getCardIds(Player.Hand) > #player:getCardIds(Player.Hand)
    end) == 0 then return end

    for _, move in ipairs(data) do
      if move.to == player.id and move.toArea == Card.PlayerHand and move.skillName ~= self.name then
        return true
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    -- player.room:delay(240)
    local room = player.room
    local goal = 0
    for _, p in ipairs(room:getOtherPlayers(player)) do
      goal = math.max(goal, p:getHandcardNum())
    end
    player:drawCards(goal - player:getHandcardNum(), self.name)
  end,
}
n_qunlingdao:addSkill(n_lingxiu)
local n_qunzhi_choices = {
  "dismantlement", "snatch", "duel", "collateral",
  "ex_nihilo", "savage_assault", "archery_attack", "god_salvation",
  "amazing_grace", "iron_chain", "fire_attack",
}
local n_qunzhi = fk.CreateViewAsSkill{
  name = "n_qunzhi",
  interaction = function(self)
    local mark = Self:getMark("n_qunzhi_choices")
    if mark == 0 then mark = nil end
    return UI.ComboBox {
      choices = mark or n_qunzhi_choices
    }
  end,
  card_filter = function(self, to_select, selected)
    return Fk:currentRoom():getCardArea(to_select) ~= Player.Equip and
      #selected < math.ceil(Self:getHandcardNum() / 2)
  end,
  view_as = function(self, cards)
    if #cards ~= math.ceil(Self:getHandcardNum() / 2) then
      return nil
    end
    local c = Fk:cloneCard(self.interaction.data)
    c:addSubcards(cards)
    return c
  end,
  enabled_at_play = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0 and
      player.hp <= player:getHandcardNum()
  end,
  before_use = function(self, player, use)
    local room = player.room
    local card = use.card.name
    local markTab = player:getMark("n_qunzhi_choices")
    if markTab == 0 then markTab = table.clone(n_qunzhi_choices) end
    table.removeOne(markTab, card)
    if #markTab == 0 then markTab = table.clone(n_qunzhi_choices) end
    room:setPlayerMark(player, "n_qunzhi_choices", markTab)
  end,
}
n_qunlingdao:addSkill(n_qunzhi)
Fk:loadTranslationTable{
  ["n_qunlingdao"] = "群领导",
  ["n_lingxiu"] = "领袖",
  [":n_lingxiu"] = "锁定技，当你不以此法获得手牌后，将手牌摸至全场最多。",
  ["n_qunzhi"] = "群智",
  [":n_qunzhi"] = "出牌阶段限一次，若你的体力值不超过你的手牌数，" ..
    "你可以将一半的手牌当一张普通锦囊牌（无懈除外）使用。" ..
    "（每种限用一次，你因本技能使用过全部普通锦囊牌后技能状态刷新。）",
  ["~n_qunlingdao"] = "我还会继续看群的...",
  ["$n_lingxiu1"] = "我才是领导！",
  ["$n_lingxiu2"] = "都听我的！",
  ["$n_qunzhi1"] = "集思广益！",
  ["$n_qunzhi2"] = "群众的智慧是无穷的！",
}

local n_hospair = General(extension, "n_hospair", "n_pigeon", 3)
n_hospair.gender = General.Female
-- n_hospair.hidden = true
-- n_hospair.total_hidden = true
local n_fudu = fk.CreateTriggerSkill{
  name = "n_fudu",
  anim_type = "offensive",
  events = {fk.CardUseFinished},
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(self) then return end
    if player:isKongcheng() then return end

    local use = data ---@type CardUseStruct
    local card = use.card
    if not (use.from ~= player.id and
      use.tos and
      (not card:isVirtual()) and
      (card.type == Card.TypeBasic or card:isCommonTrick()
    )) then

      return
    end
    local tos = TargetGroup:getRealTargets(data.tos)
    if #table.filter(player.room.alive_players, function(p) return table.contains(tos, p.id) end) ~= 1 then return end
    local room = player.room
    local target = use.tos[1][1] == player.id
      and room:getPlayerById(use.from)
      or room:getPlayerById(use.tos[1][1])
    if target.dead then
      return
    end
    return U.canUseCardTo(room, player, target, card, false, false)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local use = data ---@type CardUseStruct
    local target = use.tos[1][1] == player.id
      and room:getPlayerById(use.from)
      or room:getPlayerById(use.tos[1][1])

    local ids = table.filter(player:getCardIds(Player.Hand), function(id)
      return use.card:compareColorWith(Fk:getCardById(id))
    end)

    local c = room:askForCard(player, 1, 1, false, self.name, true,
      tostring(Exppattern{ id = ids }),
      "@n_fudu::" .. target.id .. ":" .. use.card.name .. ":" .. use.card:getColorString())[1]

    if c then
      self.cost_data = c
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local use = {}
    use.from = player.id
    use.tos = data.tos[1][1] == player.id
      and { { data.from } }
      or table.clone(data.tos)

    local card = Fk:cloneCard(data.card.name)
    card:addSubcard(self.cost_data)
    card.skillName = self.name
    use.card = card
    use.extraUse = true
    room:useCard(use)
  end,
}
n_hospair:addSkill(n_fudu)
local n_mingzhe = fk.CreateTriggerSkill{
  name = "n_mingzhe",
  anim_type = "defensive",
  events = {fk.CardUsing, fk.CardResponding, fk.AfterCardsMove},
  can_trigger = function(self, event, target, player, data)
    if not (player:hasSkill(self) and player.phase == Player.NotActive and player:usedSkillTimes(self.name, Player.HistoryTurn) < 2) then return end
    self.cost_data = 0
    if event == fk.AfterCardsMove then
      for _, move in ipairs(data) do
      if move.from == player.id and move.moveReason == fk.ReasonDiscard then
        for _, info in ipairs(move.moveInfo) do
          if (info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip) and
          Fk:getCardById(info.cardId).color == Card.Red then
            self.cost_data = self.cost_data + 1
          end
        end
      end
    end
    else
      if (player == target and data.card.color == Card.Red) then self.cost_data = self.cost_data + 1 end
    end
    return self.cost_data > 0
  end,
  on_trigger = function(self, event, target, player, data)
    local x = self.cost_data
    local ret
    for _ = 1, x do
      if self.cancel_cost or not player:hasSkill(self) or player:usedSkillTimes(self.name, Player.HistoryTurn) >= 2 then
        self.cancel_cost = false
        break
      end
      ret = self:doCost(event, target, player, data)
      if ret then return ret end
    end
  end,
  on_cost = function(self, event, target, player, data)
    if player.room:askForSkillInvoke(player, self.name, data) then
      return true
    end
    self.cancel_cost = true
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(1, self.name)
  end,
}
n_hospair:addSkill(n_mingzhe)
Fk:loadTranslationTable{
  ["n_hospair"] = "惑神",
  ["designer:n_hospair"] = "Notify",
  ["illustrator:n_hospair"] = "来自网络",
  ["n_fudu"] = "复读",
  ["$n_fudu"] = "加一",
  [":n_fudu"] = "其他角色的指定唯一目标的非转化的基本牌或者普通锦囊牌结算完成后: <br/>" ..
  "① 若你是唯一目标，你可以将颜色相同的一张手牌当做此牌对使用者使用。（无视距离）<br/>" ..
  "② 若你不是唯一目标，你可以将颜色相同的一张手牌当做此牌对目标角色使用。（无视距离）",
  ["@n_fudu"] = "复读：你可以将一张%arg2手牌当做【%arg】对 %dest 使用",
  ["n_mingzhe"] = "明哲",
  [":n_mingzhe"] = "每回合限两次，当你于回合外使用、打出或因弃置而失去一张红色牌时，你可以摸一张牌。",
}

local xxyheaven = General(extension, "n_xxyheaven", "n_pigeon", 3)
xxyheaven.gender = General.Female
local kaoda = fk.CreateActiveSkill{
  name = "n_kaoda",
  anim_type = "offensive",
  prompt = "#n_kaoda-active",
  max_card_num = 0,
  target_num = 1,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  card_filter = function() return false end,
  target_filter = function(self, to_select, selected, selected_cards)
    return #selected == 0 and to_select ~= Self.id
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    player:drawCards(1, self.name)
    room:addPlayerMark(target, "@@n_kaoda-turn")
    player:control(target)
  end,
}
local kaoda_delay = fk.CreateTriggerSkill{
  name = "#n_kaoda_delay",
  refresh_events = {fk.AfterTurnEnd, fk.EnterDying},
  mute = true,
  can_refresh = function(self, event, target, player, data)
    if event == fk.EnterDying then
      return true
    end
    return target == player
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    for _, p in ipairs(room.alive_players) do
      if p:getMark("@@n_kaoda-turn") > 0 then
        p:control(p)
      end
    end
  end,
}
kaoda:addRelatedSkill(kaoda_delay)
xxyheaven:addSkill(kaoda)
local chonggou = fk.CreateTriggerSkill{
  name = "n_chonggou",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.phase == Player.Finish
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    for _, p in ipairs(room.alive_players) do
      if p:getMark("@@n_kaoda-turn") > 0 then
        p:drawCards(3, self.name)
        room:askForDiscard(p, 3, 3, true, self.name, false)
      end
    end
    player:drawCards(3, self.name)
    room:askForDiscard(player, 3, 3, true, self.name, false)
  end,
}
xxyheaven:addSkill(chonggou)
local kuiping = fk.CreateTriggerSkill{
  name = 'n_kuiping',
  frequency = Skill.Compulsory,
  refresh_events = {fk.EventAcquireSkill, fk.EventLoseSkill},
  can_refresh = function(self, event, target, player, data)
    return target == player and data == self
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    local victim = table.find(room.players, function(p) return p.seat == 1 end)
    if not victim then return end
    if event == fk.EventAcquireSkill then
      player:addBuddy(victim)
    elseif event == fk.EventAcquireSkill then
      player:removeBuddy(victim)
    end
  end,
}
xxyheaven:addSkill(kuiping)
Fk:loadTranslationTable{
  ["n_xxyheaven"] = "心变",
  ["n_kaoda"] = "拷打",
  [":n_kaoda"] = "出牌阶段限一次，你可以摸一张牌并控制一名其他角色，直到回合结束或有角色进入濒死阶段。",
  ["n_chonggou"] = "重构",
  [":n_chonggou"] = "结束阶段，你可以摸三张牌并弃三张牌，若本回合有被拷打的角色，其先执行此效果。",
  ["n_kuiping"] = "窥屏",
  [":n_kuiping"] = "锁定技，一号位获得的牌对你可见。",

  ["#n_kaoda-active"] = "拷打：控制一名其他角色",
  ["@@n_kaoda-turn"] = "被拷打",
}

local youmukon = General:new(extension, "n_youmukon", "n_pigeon", 3)
youmukon.gender = General.Female
youmukon.trueName = "th_youmu"
local yaodao = fk.CreateTriggerSkill{
  name = "n_yaodao",
  anim_type = "offensive",
  frequency = Skill.Compulsory,
  events = {fk.CardUseFinished, fk.CardRespondFinished},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and data.card and data.card.trueName == "slash" and not (data.card:isVirtual() and #data.card.subcards == 0)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local name = data.card.name
    local dat = U.askForUseVirtualCard(room, player, name, nil, self.name, "#n_yaodao-use:::"..name, false, true, false, true, nil, true)
    if dat then
      self.cost_data = dat
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local use = self.cost_data
    room:useCard(use)
  end,

  refresh_events = {fk.TargetSpecified, fk.CardUseFinished},
  can_refresh = function(self, event, target, player, data)
    if event == fk.TargetSpecified then
      return target == player and data.card and table.contains(data.card.skillNames, self.name)
    else
      return data.extra_data and data.extra_data.yaodaoNullified
    end
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    if event == fk.TargetSpecified then
      room:addPlayerMark(room:getPlayerById(data.to), fk.MarkArmorNullified)
      data.extra_data = data.extra_data or {}
      data.extra_data.yaodaoNullified = data.extra_data.yaodaoNullified or {}
      data.extra_data.yaodaoNullified[tostring(data.to)] = (data.extra_data.yaodaoNullified[tostring(data.to)] or 0) + 1
    else
      for key, num in pairs(data.extra_data.yaodaoNullified) do
        local p = room:getPlayerById(tonumber(key))
        if p:getMark(fk.MarkArmorNullified) > 0 then
          room:removePlayerMark(p, fk.MarkArmorNullified, num)
        end
      end
      data.yaodaoNullified = nil
    end
  end,
}
local huanmeng = fk.CreateTriggerSkill{
  name = "n_huanmeng",
  anim_type = "masochism",
  -- mute = true,
  events = {fk.Damaged},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and not table.find(player.room:getOtherPlayers(player), function(p)
      return p.hp < player.hp
    end)
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askForSkillInvoke(player, self.name, nil, "#n_huanmeng-invoke")
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    -- player:broadcastSkillInvoke(self.name)
    -- room:notifySkillInvoked(player, self.name)
    player:drawCards(1, self.name)
    room.logic:breakTurn()
  end,
}
youmukon:addSkill(yaodao)
youmukon:addSkill(huanmeng)

local youmukon_win = fk.CreateActiveSkill{ name = "n_youmukon_win_audio" }
youmukon_win.package = extension
Fk:addSkill(youmukon_win)
Fk:loadTranslationTable{
  ["n_youmukon"] = "妖梦厨",
  ["n_yaodao"] = "妖刀",
  [":n_yaodao"] = "锁定技，你使用或打出非虚拟【杀】后，视为使用一张无视防具的同类别【杀】。",
  ["n_huanmeng"] = "寰梦",
  [":n_huanmeng"] = "你受到伤害后，若你的体力值最低，可以摸一张牌并结束回合。",

  ["#n_yaodao-use"] = "妖刀：你视为使用一张无视防具的%arg。",
  ["#n_huanmeng-invoke"] = "寰梦：你可以摸一张牌并结束回合。",

  ["$n_yaodao"] = "（蓄力斩）",
  ["$n_huanmeng1"] = "（XP感叹号）",
  ["$n_huanmeng2"] = "（XP错误）",
  ["$n_huanmeng3"] = "（XP关键性终止）",
  ["~n_youmukon"] = "（Biu~）",
  ["$n_youmukon_win_audio"] = "（Spell Card Bonus!）",
}

local emoprincess = General(extension, "n_emoprincess", "n_pigeon", 3, 3, General.Female)
emoprincess.trueName = "emoprincess"
local n_leimu = fk.CreateTriggerSkill{
  name = "n_leimu",
  anim_type = "defensive",
  frequency = Skill.Compulsory,
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) and target == player and player.phase == Player.Start and player.maxHp < 7 then
      return table.every(player.room.alive_players, function (p)
        return p.hp >= player.hp
      end)
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:changeMaxHp(player, 1)
    if not player.dead and player:isWounded() then
      room:recover { num = 1, skillName = self.name, who = player, recoverBy = player}
    end
  end,
}
emoprincess:addSkill(n_leimu)
local n_xiaogeng = fk.CreateTriggerSkill{
  name = "n_xiaogeng",
  anim_type = "support",
  events = {fk.EventPhaseEnd},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and target == player and player.phase == Player.Play
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:drawCards(1, self.name)
    if player.dead or player:isNude() or #room:getOtherPlayers(player) == 0 then return end
    local move = room:askForYiji(player, player:getCardIds("he"), room:getOtherPlayers(player), self.name, 1, #player:getCardIds("he"), nil, nil, true)
    local cards = room:doYiji(move, player.id, self.name)
    if #cards > 1 and not player.dead then
      local names = {}
      for _, id in ipairs(cards) do
        local c = Fk:getCardById(id)
        if c.type == Card.TypeBasic or c:isCommonTrick() then
          table.insertIfNeed(names, Fk:getCardById(id).name)
        end
      end
      if #names > 0 then
        U.askForUseVirtualCard(room, player, names, nil, self.name, nil, true, true, false, true)
      end
    end
  end,
}
emoprincess:addSkill(n_xiaogeng)
local n_fencha = fk.CreateActiveSkill{
  name = "n_fencha",
  card_num = 0,
  target_num = 1,
  card_filter = Util.FalseFunc,
  target_filter = function (self, to_select, selected)
    return #selected == 0
  end,
  frequency = Skill.Limited,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryGame) == 0 and player:isWounded()
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local to = room:getPlayerById(effect.tos[1])
    local moves = {}
    local handcards = to:getCardIds("h")
    if #handcards > 0 then
      table.shuffle(handcards)
      table.insert(moves, {
        ids = handcards,
        from = to.id,
        toArea = Card.DrawPile,
        moveReason = fk.ReasonExchange,
        proposer = player.id,
      })
    end
    local n = #room.draw_pile % 10
    if n > 0 then
      table.insert(moves, {
        ids = room:getNCards(n),
        to = to.id,
        toArea = Card.PlayerHand,
        moveReason = fk.ReasonExchange,
        proposer = player.id,
      })
    end
    if #moves > 0 then
      room:moveCards(table.unpack(moves))
    end
  end,
}
emoprincess:addSkill(n_fencha)
Fk:loadTranslationTable{
  ["n_emoprincess"] = "emo",
  ["n_leimu"] = "泪目",
  [":n_leimu"] = "锁定技，准备阶段，若你的体力值为全场最少，且你的体力上限小于7，你增加一点体力上限并回复一点体力。",
  ["n_xiaogeng"] = "小更",
  [":n_xiaogeng"] = "出牌阶段结束时，你可以摸一张牌再将至少一张牌分配给其他角色，若至少给出两张牌，你可以视为使用分配的牌中一张基本牌或普通锦囊牌。",
  ["n_fencha"] = "分叉",
  [":n_fencha"] = "限定技，出牌阶段，若你已受伤，你可以将一名角色的所有手牌与牌堆顶X张牌交换（X为牌堆牌数的个位数）。",
}

local n_daotuwang = General(extension, "n_daotuwang", "n_pigeon", 3)
local n_daotu = fk.CreateTriggerSkill{
  name = "n_daotu",
  anim_type = "drawcard",
  events = {fk.CardUseFinished},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) then
      local card = data.card
      if card:isVirtual() then return false end
      if data.from == player.id then return end
      if player:usedSkillTimes(self.name, Player.HistoryTurn) > 0 then
        return false
      end
      local tab = player:getMark("@$n_daotu")
      if table.contains(type(tab) == "table" and tab or {}, card.name) then
        return false
      end
      if player.room:getCardArea(card.id) == Card.Processing then
        return true
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:obtainCard(player, data.card.id, true)
    local mark_tab = player:getMark("@$n_daotu")
    if type(mark_tab) ~= "table" then mark_tab = {} end
    table.insert(mark_tab, data.card.name)
    room:setPlayerMark(player, "@$n_daotu", mark_tab)
  end
}
n_daotuwang:addSkill(n_daotu)
Fk:loadTranslationTable{
  ["n_daotuwang"] = "盗图王",
  ["designer:n_daotuwang"] = "Notify",
  ["~n_daotuwang"] = "盗图王，你.....",
  ["illustrator:n_daotuwang"] = "网络",
  ["#n_daotuwang"] = "人畜无害",
  ["n_daotu"] = "盗图",
  ["@$n_daotu"] = "盗图",
  ["$n_daotu1"] = "此图，我怎么会错失。",
  ["$n_daotu2"] = "你的图，现在是我的了！",
  [":n_daotu"] = "每回合限一次，当其他角色使用的非转化且非虚拟的牌结算完成后，" ..
    "若你没有同名的手牌，则你可以获得之。每种牌名限获得一次。",
}

local H = require 'packages/hegemony/util'
local nyutan = General(extension, "n_nyutan", "n_pigeon", 3)
nyutan.gender = General.Female
nyutan:addCompanions{ "os__niujin", "niufu" }
local tuguo_choices = {
  -- 卡牌们
  "befriend_attacking", "known_both", "await_exhausted", "burning_camps", "lure_tiger",
  "fight_together", "alliance_feast", "threaten_emperor",
  -- 标记们
  "vanguard", "yinyangfish", "companion", "wild",
}
local tuguo = fk.CreateActiveSkill{
  name = "n_tuguo",
  anim_type = "drawcard",
  prompt = "#n_tuguo-active",
  max_card_num = 0,
  target_num = 0,
  interaction = function(self)
    local mark = Self:getMark("n_tuguo_choices")
    if mark == 0 then mark = Util.DummyTable end
    local c = table.simpleClone(tuguo_choices)
    for k, v in pairs(mark) do
      if v >= 2 then table.removeOne(c, k) end
    end
    return UI.ComboBox {
      choices = c,
      all_choices = tuguo_choices
    }
  end,
  can_use = function(self, nyunyu)
    return nyunyu:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = Util.FalseFunc,
  on_use = function(self, room, effect)
    local nyunyu = room:getPlayerById(effect.from)
    local name = self.interaction.data
    local mark = nyunyu:getMark("n_tuguo_choices")
    if mark == 0 then mark = {} end
    mark[name] = mark[name] and mark[name] + 1 or 1
    room:setPlayerMark(nyunyu, "n_tuguo_choices", mark)

    room:damage {
      from = nyunyu,
      to = nyunyu,
      damage = 1,
    }
    if nyunyu.dead then return end
    local cd = Fk.all_card_types[name]
    if not cd then
      H.addHegMark(room, nyunyu, name)
    else
      local c = room:printCard(name, math.random(1,4), math.random(1,13))
      room:obtainCard(nyunyu, c.id, true)
    end
  end,
}
local niuzhi = fk.CreateTriggerSkill {
  name = "n_niuzhi",
  anim_type = "defensive",
  events = {fk.Damaged},
  can_trigger = function(self, event, target, nyunyu, data)
    return target == nyunyu and nyunyu:hasSkill(self) and data.from and nyunyu:getMark("n_niuzhi-turn") == 0
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    if room:askForSkillInvoke(player, self.name, nil, "#n_niuzhi-ask:" .. data.from.id) then
      return true
    end
  end,
  on_use = function(self, event, target, nyunyu, data)
    local room = nyunyu.room
    if H.askCommandTo(nyunyu, data.from, self.name) then
      room:addPlayerMark(nyunyu, "n_niuzhi-turn", 1)
    else
      room:recover{
        who = nyunyu,
        num = 1,
        skillName = self.name,
      }
    end
  end,
}
nyutan:addSkill(niuzhi)
nyutan:addSkill(tuguo)
Fk:loadTranslationTable{
  ["n_nyutan"] = "Nyutan_",
  ["n_tuguo"] = "图国",
  [":n_tuguo"] = "出牌阶段限一次，你可以对自己造成1点伤害，然后获得一张国战锦囊或一枚国战标记（每种牌名/标记限两次，获得卡牌的花色点数随机）。<br/>" ..
  "<font color='grey'><small><b>国战锦囊</b>：<br/><b>远交近攻</b>：出牌阶段，选择势力与你不同的一名角色，其摸一张牌，你摸三张牌。<br/>" ..
  "<b>知己知彼</b>：出牌阶段，选择一名其他角色，观看其手牌<s>或一张暗置的武将牌</s>。<br/>" ..
  "<b>以逸待劳</b>：出牌阶段，你和与你势力相同的角色各摸两张牌，然后弃置两张牌。<br/>" ..
  "<b>火烧连营</b>：出牌阶段，对你的下家和与其同一<u>队列</u>（相邻、势力相同）的所有角色各造成1点火焰伤害。<br/>" ..
  "<b>调虎离山</b>：出牌阶段，选择一至两名其他角色，这些角色于此回合内不计入距离和座次的计算，且不能使用牌，且不是牌的合法目标，且体力值不会改变。<br/>" ..
  "<b>勠力同心</b>：出牌阶段，选择所有<u>大势力</u>（角色数最多的势力）角色或<u>小势力</u>（角色数不是最多的势力）角色，若这些角色处于/不处于连环状态，其摸一张牌/横置。<br/>" ..
  "<b>联军盛宴</b>：选择除你的势力外的一个势力的所有角色，对你和这些角色使用，你选择X（不大于Y），摸X张牌，回复Y-X点体力（Y为该势力的角色数）；这些角色各摸一张牌，重置。<br/>" ..
  "<b>挟天子以令诸侯</b>：出牌阶段，若你为<u>大势力</u>（角色数最多的势力）角色，对你使用，你结束出牌阶段，此回合弃牌阶段结束时，你可弃置一张手牌，然后获得一个额外回合。<br/>" ..
  "<b>国战标记</b>：<br/><b>先驱</b>：出牌阶段，你可弃一枚“先驱”，将手牌摸至4张<s>，观看一名其他角色的一张暗置武将牌</s>。<br/>" ..
  "<b>阴阳鱼</b>：①出牌阶段，你可弃一枚“阴阳鱼”，摸一张牌；②弃牌阶段开始时，你可弃一枚“阴阳鱼”，此回合手牌上限+2。<br/>" ..
  "<b>珠联璧合</b>：①出牌阶段，你可弃一枚“珠联璧合”，摸两张牌；②你可弃一枚“珠联璧合”，视为使用【桃】。<br/>" ..
  "<b>野心家</b>：你可将一枚“野心家”当以上三种中任意一种标记弃置并执行其效果。</small></font>",
  ["n_niuzhi"] = "牛智",
  [":n_niuzhi"] = "当你受到伤害后，你可以对伤害来源发起一次“军令”，若其不执行，你回复一点体力，否则你本阶段不能再发动此技能。<br/>" ..
  "<font color='grey'><small><b>军令</b>：<u>发起军令的角色</u>随机获得两张军令牌，然后选择其中一张。<u>执行军令的角色</u>选择是否执行该“军令”。。</small></font>",
  ["#n_tuguo-active"] = "图国: 你可以对自己造成1伤害，然后拿国战牌或标记",
  ["#n_niuzhi-ask"] = "牛智: 你可以对 %src 发起“军令”，若其不执行你回血",
}

local ralph = General(extension, "n_ralph", "n_pigeon", 3)
ralph.gender = General.Female
ralph.trueName = "th_kogasa"
local n_subian = fk.CreateActiveSkill{
  name = "n_subian",
  anim_type = "drawcard",
  card_num = 1,
  target_num = 0,
  prompt = function() return "#n_subian" end,
  card_filter = function(self, to_select, selected)
    return #selected == 0 and Fk:currentRoom():getCardArea(to_select) ~= Player.Equip
  end,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0 and not player:isKongcheng()
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local card = Fk:getCardById(effect.cards[1])
    local toGain = room:printCard(card.name, card.suit, card.number)
    room:obtainCard(player, toGain, true, fk.ReasonPrey)
    -- room:setCardMark(toGain, "@@n_subian", 1)
    local mark = player:getTableMark("n_subian-turn")
    table.insert(mark, toGain.id)
    room:setPlayerMark(player, "n_subian-turn", mark)
  end,
}
ralph:addSkill(n_subian)
local n_rigeng = fk.CreateTriggerSkill{
  name = "n_rigeng",
  anim_type = "offensive",
  events = {fk.EventPhaseEnd},
  frequency = Skill.Compulsory,
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) and player == target and player.phase == Player.Play then
      return #player.room.logic:getEventsOfScope(GameEvent.UseCard, 999, function (e)
        return e.data[1].from == player.id
      end, Player.HistoryPhase) >= (3 + 3 * player:usedSkillTimes(self.name, Player.HistoryTurn))
    end
  end,
  on_use = function(self, event, target, player, data)
    player:gainAnExtraPhase(Player.Play)
  end,

  refresh_events = {fk.EventPhaseStart, fk.AfterCardUseDeclared},
  can_refresh = function (self, event, target, player, data)
    return player:hasSkill(self, true) and player.phase == Player.Play
  end,
  on_refresh = function (self, event, target, player, data)
    local room = player.room
    local num = #room.logic:getEventsOfScope(GameEvent.UseCard, 999, function (e)
      return e.data[1].from == player.id
    end, Player.HistoryPhase)
    room:setPlayerMark(player, "@n_rigeng-phase", num.."/"..(3 + 3 * player:usedSkillTimes(self.name, Player.HistoryTurn)))
  end,
}
ralph:addSkill(n_rigeng)
local n_fanxiu = fk.CreateActiveSkill{
  name = "n_fanxiu",
  anim_type = "drawcard",
  card_num = 0,
  target_num = 0,
  card_filter = Util.FalseFunc,
  frequency = Skill.Limited,
  prompt = function() return "#n_fanxiu" end,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryGame) == 0
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local ids = player:getTableMark("n_subian-turn")
    for i = #ids , 1, -1 do
      local id = ids[i]
      if room:getCardArea(id) ~= Card.DiscardPile and room:getCardArea(id) ~= Card.DrawPile then
        table.remove(ids, i)
      end
    end
    if #ids > 0 then
      local dummy = Fk:cloneCard("dilu")
      dummy:addSubcards(ids)
      room:obtainCard(player, dummy, false, fk.ReasonPrey)
    end
  end,
}
ralph:addSkill(n_fanxiu)
Fk:loadTranslationTable{
  ["n_ralph"] = "Ｒ神",
  ["n_subian"] = "速编",
  [":n_subian"] = "出牌阶段限一次，你可以获得一张手牌的复制牌。",
  ["#n_subian"] = "速编：获得一张手牌的复制",
  ["n_rigeng"] = "日更",
  [":n_rigeng"] = "锁定技，出牌阶段结束后，若你本阶段使用过至少3*X张牌，你执行一个额外的出牌阶段（X为本回合已发动过本技能的次数+1）。",
  ["@n_rigeng-phase"] = "日更",
  ["n_fanxiu"] = "翻修",
  [":n_fanxiu"] = "限定技，出牌阶段，你可以获得本回合牌堆和弃牌堆中所有通过〖速编〗复制出来的卡牌。",
  ["#n_fanxiu"] = "翻修：获得本回合牌堆和弃牌堆中所有通过〖速编〗复制出来的卡牌",
}

local n_0t = General(extension, "n_0t", "n_pigeon", 3)
n_0t.gender = General.Female
local cejin = fk.CreateViewAsSkill{
  name = "n_cejin",
  anim_type = "drawcard",
  pattern = ".|.|.|.|.|normal_trick",
  interaction = function()
    local names, all_names = {} , {}
    for _, id in ipairs(Fk:getAllCardIds()) do
      local card = Fk:getCardById(id)
      if card:isCommonTrick() and not card.is_derived and not card.is_damage_card then
        table.insertIfNeed(all_names, card.name)
        if not Self:prohibitUse(card) and
        ((Fk.currentResponsePattern == nil and Self:canUse(card)) or
        (Fk.currentResponsePattern and Exppattern:Parse(Fk.currentResponsePattern):match(card))) then
          table.insertIfNeed(names, card.name)
        end
      end
    end
    return UI.ComboBox {choices = names, all_choices = all_names}
  end,
  card_filter = function(self, to_select, selected)
    if #selected == 1 then
      return table.contains(Self:getHandlyIds(true), to_select) and Fk:getCardById(to_select).color ~= Fk:getCardById(selected[1]).color
    elseif #selected == 2 then
      return false
    end
    return table.contains(Self:getHandlyIds(true), to_select)
  end,
  view_as = function(self, cards)
    if #cards ~= 2 then return nil end
    local card = Fk:cloneCard(self.interaction.data)
    card:addSubcards(cards)
    card.skillName = self.name
    return card
  end,
  after_use = function(self, player, _)
    if not player.dead then
      player:drawCards(1, self.name)
    end
  end,
  enabled_at_play = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryTurn) == 0 and
      #player:getCardIds("h") >= 2
  end,
  enabled_at_response = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryTurn) == 0 and
      #player:getCardIds("h") >= 2
  end,
}
local yinghui = fk.CreateTriggerSkill{
  name = "n_yinghui",
  anim_type = "control",
  events = {fk.BeforeDrawCard},
  can_trigger = function(self, event, target, player, data)
    if data.num == 2 then return end
    return player:hasSkill(self) and not player:isNude()
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local ids = room:askForDiscard(player, 1, 1, true, self.name, true,
      ".", "#n_yinghui-ask::" .. data.who.id .. ":" .. data.num, true)

    if #ids > 0 then
      self.cost_data = ids[1]
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:throwCard(self.cost_data, self.name, player, player)
    local num = data.num
    data.num = 2
    local x = math.abs(num - data.num) - 1
    if x > 0 then player:drawCards(x, self.name) end
  end,
}
n_0t:addSkill(cejin)
n_0t:addSkill(yinghui)
Fk:loadTranslationTable{
  ["n_0t"] = "聆听",
  ["n_cejin"] = "策进",
  [":n_cejin"] = "每回合限一次，你可以将两张颜色不同的手牌当一张非伤害普通锦囊牌使用，然后摸一张牌。",
  ["n_yinghui"] = "萦回",
  [":n_yinghui"] = "当有角色即将摸牌时，若不为两张，你可以弃置一张牌将摸牌数改成两张；若变化量超过1，你摸等同于超出数量的牌。",
  ["#n_yinghui-ask"] = "萦回: %dest 即将摸 %arg 张牌，是否弃一张牌令其改为摸两张？",
}

local notify = General(extension, "n_notify", "n_pigeon", 3)
local bianchengTrig = fk.CreateTriggerSkill{
  name = "#n_biancheng_trig",
  refresh_events = {fk.AfterCardsMove, fk.AfterDrawPileShuffle},
  can_refresh = function(self, event, target, player, data)
    if not player:hasSkill("n_biancheng", true) then return end
    if event == fk.AfterDrawPileShuffle then return true end
    for _, move in ipairs(data) do
      if move.toArea == Card.DrawPile then
        return true
      end
      for _, info in ipairs(move.moveInfo) do
        if info.fromArea == Card.DrawPile then
          return true
        end
      end
    end
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    room:setPlayerMark(player, "n_biancheng", room.draw_pile[1])
  end,
}
local biancheng = fk.CreateViewAsSkill{
  name = "n_biancheng",
  card_num = 0,
  pattern = ".",
  prompt = function(self)
    local card = Fk:getCardById(Self:getMark(self.name))
    if card then
      return "#n_biancheng:::"..card:toLogString()
    end
    return ""
  end,
  card_filter = Util.FalseFunc,
  view_as = function(self)
    local card = Fk:getCardById(Self:getMark(self.name))
    if not card then return nil end
    if Self:getMark("@@n_baogan") == 0 and card.suit == Card.Spade then return nil end
    return card
  end,
  before_use = function(self, player, use)
    use.card = Fk:getCardById(player.room.draw_pile[1])
  end,
  -- enabled_at_play = function(self, player)
  --   local card = Fk:getCardById(player:getMark(self.name))
  --   return card.suit ~= Card.Spade
  -- end,
  enabled_at_response = function(self, player)
    local card = Fk:getCardById(player:getMark(self.name))
    if not card then return end
    -- 服务器端判断无懈的时候这个pattern是nil。。
    local pat = Fk.currentResponsePattern or "nullification"
    return (player:getMark("@@n_baogan") == 1 or card.suit ~= Card.Spade) and
      Exppattern:Parse(pat):matchExp(card.name)
  end,
}
biancheng:addRelatedSkill(bianchengTrig)
notify:addSkill(biancheng)
local tiaoshi = fk.CreateActiveSkill{
  name = "n_tiaoshi",
  anim_type = "drawcard",
  -- can_use = function(self, player)
  --   return player:usedSkillTimes(self.name) == 0
  -- end,
  target_num = 0,
  prompt = function(self)
    return "#n_tiaoshi:::" .. Self:usedSkillTimes(self.name)
  end,
  card_num = function(self)
    return Self:usedSkillTimes(self.name, Player.HistoryPhase)
  end,
  card_filter = function(self, to_select, selected)
    return #selected < Self:usedSkillTimes(self.name) and
      not Self:prohibitDiscard(Fk:getCardById(to_select))
  end,
  on_use = function(self, room, effect)
    local from = room:getPlayerById(effect.from)
    if #effect.cards > 0 then
      room:throwCard(effect.cards, self.name, from)
    end
    from:drawCards(1, self.name)
  end
}
notify:addSkill(tiaoshi)
local baogan = fk.CreateActiveSkill{
  name = "n_baogan",
  card_num = 0,
  target_num = 0,
  frequency = Skill.Limited,
  prompt = "#n_baogan",
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryGame) == 0
  end,
  card_filter = Util.FalseFunc,
  on_use = function(self, room, effect)
    room:setPlayerMark(room:getPlayerById(effect.from), "@@n_baogan", 1)
  end,
}
local baogan_refresh = fk.CreateTriggerSkill{
  name = "#n_baogan_refresh",

  refresh_events = {fk.TurnStart},
  can_refresh = function(self, event, target, player, data)
    return target == player and player:getMark("@@n_baogan") > 0
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "@@n_baogan", 0)
  end,
}
baogan:addRelatedSkill(baogan_refresh)
notify:addSkill(baogan)
Fk:loadTranslationTable{
  ["n_notify"] = "Notify_",
  ["n_biancheng"] = "编程",
  [":n_biancheng"] = "你可以使用或打出牌堆顶的非黑桃牌。",
  ["#n_biancheng"] = "编程：你可以使用或打出牌堆顶的非黑桃牌%arg",
  ["n_tiaoshi"] = "调试",
  [":n_tiaoshi"] = "出牌阶段，你可以弃置X张牌并摸一张牌。（X为本阶段发动过该技能的次数）",
  ["#n_tiaoshi"] = "调试：弃置 %arg 张牌，然后摸 1 张牌",
  ["n_baogan"] = "爆肝",
  ["@@n_baogan"] = "爆肝",
  [":n_baogan"] = "限定技，出牌阶段，你可以令“编程”变得也可使用打出黑桃牌直到你下回合开始。",
  ["#n_baogan"] = "爆肝:令“编程”也可使用打出黑桃牌直到你下回合开始！",
}

local n_mabaoguo = General(extension, "n_mabaoguo", "qun", 4)
local n_hunyuan = fk.CreateTriggerSkill{
  name = "n_hunyuan",
  anim_type = "offensive",
  mute = true,
  events = {fk.DamageCaused, fk.DamageInflicted, fk.Damage, fk.Damaged},
  can_trigger = function(self, event, target, player, data)
    if not (target == player and player:hasSkill(self)) then return end
    if event == fk.Damage or event == fk.Damaged then
      return player:getMark("n_hydmg1") - player:getMark("n_hydmg2") ==
        player:getMark("n_hydmg2") - player:getMark("n_hydmg3")
    else
      return true
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    if not (event == fk.Damage or event == fk.Damaged) then
      local clist = {"n_toNormal", "n_toThunder", "n_toFire", "cancel"}
      local clist2 = {"n_toNormal", "n_toThunder", "n_toFire", "cancel"}
      if data.damageType < 3 then
        table.remove(clist, data.damageType)
      end
      local choice = room:askForChoice(player, clist, self.name)
      if choice ~= "cancel" then
        self.cost_data = table.indexOf(clist2, choice)
        return true
      end
    else
      local result = room:askForChoosePlayers(player, table.map(
        room:getAlivePlayers(),
        function(p)
          return p.id
        end
      ), 1, 1, "#n_hy-ask", self.name)
      if #result > 0 then
        self.cost_data = result[1]
        return true
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:notifySkillInvoked(player, self.name)
    if not (event == fk.Damage or event == fk.Damaged) then
      player:broadcastSkillInvoke(self.name, self.cost_data)
      data.damageType = self.cost_data
    else
      player:broadcastSkillInvoke(self.name, table.random{4, 5})
      player:drawCards(1, self.name)
      room:damage{
        from = player,
        to = room:getPlayerById(self.cost_data),
        damage = 1
      }
    end
  end,

  refresh_events = {fk.Damage, fk.Damaged},
  can_refresh = function(self, event, target, player, data)
    return target == player and player:hasSkill(self)
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    room:addPlayerMark(player, "n_hydmg" .. data.damageType, data.damage)
    room:setPlayerMark(player, "@" .. self.name, string.format("%d普%d雷%d火",
      player:getMark("n_hydmg1"),
      player:getMark("n_hydmg2"),
      player:getMark("n_hydmg3")
    ))
  end,
}
n_mabaoguo:addSkill(n_hunyuan)
local n_lianbian = fk.CreateActiveSkill{
  name = "n_lianbian",
  anim_type = "offensive",
  card_num = 0,
  target_num = 0,
  frequency = Skill.Limited,
  mute = true,
  card_filter = function() return false end,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryGame) == 0
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    player:broadcastSkillInvoke(self.name, 1)
    room:notifySkillInvoked(player, self.name)

    room:throwCard(player:getCardIds(Player.Hand), self.name, player, player)

    for i = 1, 5 do
      player:broadcastSkillInvoke(self.name, i + 1)
      if not player:isAlive() then return end
      local judge = {
        who = player,
        reason = self.name,
        pattern = ".|.|spade",
      }
      room:judge(judge)
      if judge.card.suit == Card.Spade then
        local targets = table.map(room.alive_players, Util.IdMapper)
        local tos = room:askForChoosePlayers(player, targets, 1, 1, "#n_lianbian-damage", self.name, false)
        room:damage {
          from = player, to = room:getPlayerById(tos[1]),
          damage = 1, skillName = self.name, damageType = fk.ThunderDamage,
        }
      end
    end
    player:broadcastSkillInvoke(self.name, 7)
  end,
}
n_mabaoguo:addSkill(n_lianbian)
Fk:loadTranslationTable{
  ["n_mabaoguo"] = "马保国",
  ["n_hunyuan"] = "浑元",
  ["@n_hunyuan"] = "浑元",
  [":n_hunyuan"] = "你造成或受到伤害时，可改变伤害属性。" ..
    "你造成或受到伤害后，记录你造成或受到的这种属性伤害的伤害值，" ..
    "然后若记录的普通伤害→雷属性伤害→火属性伤害这三种属性伤害值成等差数列，" ..
    "你可以摸一张牌并对一名角色造成一点伤害。",
  ["#n_hy-ask"] = "浑元：你可以对一名角色造成一点伤害",
  ["n_toFire"] = "转换成火属性伤害",
  ["n_toThunder"] = "转换成雷属性伤害",
  ["n_toNormal"] = "转换成无属性伤害",
  ["$n_hunyuan1"] = "一个左正蹬~（吭）",
  ["$n_hunyuan2"] = "一个右鞭腿！",
  ["$n_hunyuan3"] = "一个左刺拳。",
  ["$n_hunyuan4"] = "三维立体浑元劲，打出松果糖豆闪电鞭",
  ["$n_hunyuan5"] = "耗子尾汁。",
  ["n_lianbian"] = "连鞭",
  [":n_lianbian"] = "限定技，出牌阶段，你可以弃置所有手牌并连续进行五次判定，每当判定结果为♠时，你对一名角色造成一点雷电伤害。",
  ["#n_lianbian-damage"] = "连鞭：对一名角色造成一点雷电伤害",
  ["$n_lianbian1"] = "下面，我打一个连五鞭啊。",
  ["$n_lianbian2"] = "一鞭。",
  ["$n_lianbian3"] = "两鞭。",
  ["$n_lianbian4"] = "三鞭。",
  ["$n_lianbian5"] = "四鞭。",
  ["$n_lianbian6"] = "五鞭。",
  ["$n_lianbian7"] = "打了五鞭。这五鞭要连续打",
  ["~n_mabaoguo"] = "这两个年轻人不讲武德，来，骗！来，偷袭！我六十九岁的老同志，这好吗这不好。",
}

local n_xujiale = General(extension, "n_xujiale", "qun", 4)
local n_pengji_ac = fk.CreateActiveSkill{
  name = "n_pengji_ac",
  min_card_num = 1,
  card_filter = function(self, to_select, selected)
    return table.every(selected, function(id)
      return Fk:getCardById(id).type ~= Fk:getCardById(to_select).type
    end)
  end,
  target_filter = function() return false end,
}
Fk:addSkill(n_pengji_ac)
local n_pengji = fk.CreateTriggerSkill{
  name = "n_pengji",
  anim_type = "drawcard",
  events = {fk.AfterCardsMove},
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(self) then return end
    if player:getMark("n_songji-phase") > 0 then return end

    for _, move in ipairs(data) do
      if move.to == player.id and move.moveReason == fk.ReasonDraw
        and move.skillName ~= self.name then
        return true
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local result, dat = room:askForUseActiveSkill(player, "n_pengji_ac",
      "@n_pengji", true)

    if result then
      self.cost_data = dat.cards
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cards = self.cost_data
    room:setPlayerMark(player, "n_pengji_dis", cards)
    room:throwCard(cards, self.name, player)
    player:drawCards(#cards, self.name)
  end,
}
n_xujiale:addSkill(n_pengji)

local function songjiCheckMove(player, move)
  local cards = player:getMark("n_pengji_dis")
  local valid = {}
  for _, info in ipairs(move.moveInfo) do
    if table.find(cards, function(id)
      return Fk:getCardById(id).trueName == Fk:getCardById(info.cardId).trueName
    end) then table.insert(valid, info.cardId) end
  end
  return valid
end

local function songjiCanUse(player)
  local canSlash = not player:prohibitUse(Fk:cloneCard("slash"))
  local canPeach = not player:prohibitUse(Fk:cloneCard("peach"))

  canSlash = canSlash and table.find(player.room:getOtherPlayers(player), function(p)
    return player:inMyAttackRange(p) and
      not player:isProhibited(p, Fk:cloneCard("slash"))
  end)
  canPeach = canPeach and player:isWounded()
  return canSlash, canPeach
end

local n_songji = fk.CreateTriggerSkill{
  name = "n_songji",
  anim_type = "offensive",
  events = {fk.AfterCardsMove},
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(self) then return end
    if player:getMark("n_songji-phase") > 0 then return end

    for _, move in ipairs(data) do
      if move.skillName == "n_pengji" and move.to == player.id
        and move.moveReason == fk.ReasonDraw then

        local a, b = songjiCanUse(player)
        if #songjiCheckMove(player, move) > 0 and (a or b) then
          return true
        end
      end
    end
  end,

  on_cost = function(self, event, target, player, data)
    local ids
    for _, move in ipairs(data) do
      if move.skillName == "n_pengji" and move.to == player.id
        and move.moveReason == fk.ReasonDraw then

        ids = songjiCheckMove(player, move)
        break

      end
    end

    local room = player.room
    local c = room:askForCard(player, 1, 1, true, self.name, true,
      tostring(Exppattern{ id = ids }), "@n_songji")

    if #c == 0 then return end
    c = c[1]

    local choices = {}
    local s, p = songjiCanUse(player)
    if s then table.insert(choices, "slash") end
    if p then table.insert(choices, "peach") end
    -- table.insert(choices, "Cancel")
    local choice = room:askForChoice(player, choices, self.name)

    if choice == "peach" then
      self.cost_data = {
        card = c,
        cname = choice,
        target = player.id,
      }
      return true
    elseif choice == "slash" then
      local targets = table.filter(room:getOtherPlayers(player), function(p)
        return player:inMyAttackRange(p) and
          not player:isProhibited(p, Fk:cloneCard("slash"))
      end)
      targets = table.map(targets, Util.IdMapper)
      local p2 = room:askForChoosePlayers(player, targets, 1, 1, "@n_songji_slash",
        self.name, true)

      if #p2 ~= 0 then
        self.cost_data = {
          card = c,
          cname = choice,
          target = p2[1],
        }
        return true
      end
    end
  end,

  on_use = function(self, event, target, player, data)
    local room = player.room
    local use = {}
    local dat = self.cost_data

    use.from = player.id
    use.tos = { { dat.target } }
    local card = Fk:cloneCard(dat.cname)
    card:addSubcard(dat.card)
    card.skillName = self.name
    use.card = card
    use.extraUse = true
    room:useCard(use)

    room:addPlayerMark(player, "n_songji-phase", 1)
    player:drawCards(1, self.name)
  end,
}
n_xujiale:addSkill(n_songji)
Fk:loadTranslationTable{
  ["n_xujiale"] = "徐嘉乐",
  ["~n_xujiale"] = "最后一次啊，注意看啊",
  ["#n_xujiale"] = "厨邦大师",
  ["n_pengji"] = "烹鸡",
  ["n_pengji_ac"] = "烹鸡",
  ["designer:n_xujiale"] = "穈穈哒的招来",
  ["cv:n_xujiale"] = "徐嘉乐",
  ["illustrator:n_xujiale"] = "视频截图",
  ["@n_pengji"] = "烹鸡：你现在可以弃置任意张不同类型的牌，然后摸等量的牌",
  ["~n_pengji"] = "选择要弃置的牌->点击确定",
  [":n_pengji"] = "当你不因此法摸牌后，你可以弃置任意张类型不同的牌，然后摸等量的牌。",
  ["$n_pengji1"] = "先用油把这个鸡淋一下啊",
  ["$n_pengji2"] = "基本上很均匀了这个皮",
  ["n_songji"] = "颂鸡",
  [":n_songji"] = "当你因〖烹鸡〗而摸牌后，若摸的牌中有牌名和你弃置的牌中的一张相同，" ..
    "你可以将这些相同的牌中的一张当做【杀】（不计入次数）/【桃】使用，" ..
    "令你本阶段不能再使用〖烹鸡〗和〖颂鸡〗并摸一张牌。",
  ["$n_songji1"] = "这个烧鸡，皮酥脆，肉滑有汁，骨都带味",
  ["$n_songji2"] = "所以是数一数二的烧鸡！",
  ["@n_songji"] = "颂鸡：你可以将刚才摸到的牌中的一张当【杀】或者【桃】使用",
  ["@n_songji_slash"] = "颂鸡：你已经做出了数一数二的烧鸡，现在请选择【杀】的目标",
}

local jiege = General(extension, "n_jiege", "qun", 4)
local yaoyin = fk.CreateActiveSkill{
  name = "n_yaoyin",
  anim_type = "control",
  card_num = 1,
  target_num = 1,
  frequency = Skill.Limited,
  card_filter = function(self, to_select, selected)
    return #selected == 0 and Fk:currentRoom():getCardArea(to_select) ~= Card.PlayerEquip
  end,
  target_filter = function(self, to_select, selected)
    -- TODO: 客户端getNextAlive

    local t = Fk:currentRoom():getPlayerById(to_select)
    local ret = t.next
    while ret.dead do
      ret = ret.next
    end

    return #selected == 0 and to_select ~= Self.id and ret ~= Self
  end,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryGame) == 0
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    local card = effect.cards[1]

    room:loseHp(player, 1, self.name)

    if player.dead then return end

    room:obtainCard(target.id, card, false, fk.ReasonGive)

    local prev = player:getLastAlive()
    room:swapSeat(prev, target)

    local card = Fk:cloneCard("analeptic")
    card.skillName = self.name
    local use = {}
    use.from = player.id
    use.tos = { { player.id }, { target.id } }
    use.card = card
    use.extraUse = true
    room:useCard(use)
  end,
}
jiege:addSkill(yaoyin)
local kangkang = fk.CreateTriggerSkill{
  name = "n_kangkang",
  anim_type = "offensive",
  events = {fk.DamageCaused},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and not data.to:isKongcheng() and
      (data.to == player:getNextAlive() or data.to:getNextAlive() == player) and
      player:usedSkillTimes(self.name, Player.HistoryTurn) < 2
  end,
  on_use = function(self, event, _, player, data)
    local room = player.room
    local target = data.to
    local id = room:askForCardChosen(player, target, { card_data = { { "$Hand", target:getCardIds(Player.Hand) }  } }, self.name)
    room:obtainCard(player, id, false, fk.ReasonPrey)
  end,
}
jiege:addSkill(kangkang)

Fk:loadTranslationTable{
  ["n_jiege"] = "杰哥",
  ["#n_jiege"] = "转大人指导",
  ["designer:n_jiege"] = "zyc12241252",
  ["illustrator:n_jiege"] = "网络",
  ["~n_jiege"] = "阿玮…你要干嘛…对不起…",
  ["n_yaoyin"] = "邀饮",
  [":n_yaoyin"] = "限定技，出牌阶段，你可以失去一点体力并交给一名其他角色一张手牌（不能是你的上家），令其与你的上家交换座位，然后你视为对你和你的上家使用了【酒】。",
  ["$n_yaoyin1"] = "我一个人住，我的房子还蛮大的，欢迎你们来我家玩。",
  ["$n_yaoyin2"] = "如果要来的话，我可以带你们去超商，买一些好吃的哦。",
  ["n_kangkang"] = "康康",
  [":n_kangkang"] = "每回合限两次，当你对你的上家或下家造成伤害时，你可以观看其手牌并获得其中一张。",
  ["$n_kangkang1"] = "哎呦，你脸红了？来，让我康康~",
  ["$n_kangkang2"] = "听话！让我康康！",
}

local n_awei = General(extension, "n_awei", "qun", 3)
local n_suijie = fk.CreateTriggerSkill{
  name = "n_suijie",
  anim_type = "drawcard",
  events = {fk.TargetConfirmed},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and
      data.from ~= player.id and
      table.contains(
        { "peach", "analeptic", "amazing_grace", "god_salvation" },
        data.card.name)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    if room:askForSkillInvoke(player, self.name, nil, "#n_suijie_ask:" .. data.from) then
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local from = room:getPlayerById(data.from)
    from:drawCards(1, self.name)
    local a, b = player:getHandcardNum(), from:getHandcardNum()
    if a < b  then
      player:drawCards(b - a, self.name)
    end
  end,
}
n_awei:addSkill(n_suijie)
local n_jujie = fk.CreateTriggerSkill{
  name = "n_jujie",
  anim_type = "defensive",
  events = {fk.TargetConfirmed, fk.Damaged},
  can_trigger = function(self, event, target, player, data)
    if not (target == player and player:hasSkill(self)) then return end
    if event == fk.TargetConfirmed then
      return data.from ~= player.id and data.card.is_damage_card
    else
      local e = player.room.logic:getCurrentEvent():findParent(GameEvent.UseCard)
      return (e and e.n_jujie_list or {})[player.id] ~= nil and data.from and
        data.from:getHandcardNum() > player:getHandcardNum()
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    if event == fk.TargetConfirmed then
      local ids = room:askForDiscard(player, 1, 1, true, self.name, true,
        ".", "#n_jujie_ask::" .. data.from .. ":" .. data.card.name, true)

      if #ids > 0 then
        self.cost_data = ids[1]
        return true
      end
    else
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if event == fk.TargetConfirmed then
      room:throwCard(self.cost_data, self.name, player, player)
      local e = room.logic:getCurrentEvent():findParent(GameEvent.UseCard)
      e.n_jujie_list = e.n_jujie_list or {}
      e.n_jujie_list[player.id] = true
    else
      local from = data.from
      local a, b = player:getHandcardNum(), from:getHandcardNum()
      if a < b then
        room:askForDiscard(from, b - a, b - a, false, self.name, false)
      end
    end
  end,
}
n_awei:addSkill(n_jujie)
Fk:loadTranslationTable{
  ["n_awei"] = "阿玮",
  ["#n_awei"] = "在杰难逃",
  ["designer:n_awei"] = "Notify",
  ["illustrator:n_awei"] = "网络",
  ["~n_awei"] = "透，死了啦，都是你害的啦，拜托！",
  ["n_suijie"] = "随杰",
  [":n_suijie"] = "当你成为其他角色使用【桃】、【酒】、【五谷丰登】、【桃园结义】的目标后，你可以令其摸一张牌，然后你将手牌数摸至与其一致。",
  ["#n_suijie_ask"] = "随杰：你可以令 %src 摸一张牌，然后你将手牌摸至与其相等",
  ["$n_suijie1"] = "杰哥，那我跟我朋友今天就去住你家哦。",
  ["$n_suijie2"] = "谢谢杰哥~",
  ["n_jujie"] = "拒杰",
  ["#n_jujie_ask"] = "拒杰：你可以弃置一张牌，之后你受到 %arg 的伤害后 %dest 须将手牌弃置至与你相等",
  [":n_jujie"] = "当你成为其他角色使用伤害类卡牌的目标后，你可以弃置一张牌，之后若此牌对你造成了伤害，伤害来源须将手牌数弃置至与你一致。",
  ["$n_jujie"] = "不要啦杰哥！你干嘛！",
}

local dj = General(extension, "n_dingzhen", "qun", 4)
local relx = { {"n_relx_v", Card.Spade, 12} }
local yangwu = fk.CreateTriggerSkill{
  name = "n_yangwu",
  anim_type = "offensive",
  frequency = Skill.Compulsory,
  events = {fk.GamePrepared, fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) then
      return event == fk.GamePrepared or
        (target == player and player.phase == Player.Start)
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local treasure = player:getEquipment(Card.SubtypeTreasure)
    if not treasure or Fk:getCardById(treasure).name ~= "n_relx_v" then
      local id = U.prepareDeriveCards(player.room, relx, "yangwu_derivedcards")[1]
      local owner = room:getCardOwner(id)
      room:obtainCard(player.id, id, false, fk.ReasonPrey)
      if owner and owner ~= player and not owner.dead then
        room:damage { from = player, to = owner, damage = 1 }
      end
      if not player.dead then
        room:useCard({
          from = player.id,
          tos = { {player.id} },
          card = Fk:getCardById(id, true),
        })
      end
    elseif Fk:getCardById(treasure).name == "n_relx_v" then
      if not player:isKongcheng() then
        local c = room:askForCard(player, 1, 999, false, self.name, true, ".|.|.|hand", "#n_yangwu-recast")
        if #c > 0 then room:recastCard(c, player, self.name) end
      end
    end
  end,
}
dj:addSkill(yangwu)
local chunzhen = fk.CreateTriggerSkill{
  name = "n_chunzhen",
  frequency = Skill.Compulsory,
  events = {fk.AfterCardTargetDeclared, fk.DamageInflicted},
  mute = true,
  can_trigger = function(self, event, target, player, data)
    if not (target == player and player:hasSkill(self)) then
      return false
    end
    if event == fk.AfterCardTargetDeclared then
      return data.card:getSubtypeString() == "normal_trick" and data.tos and #data.tos > 1
    else
      return data.damageType == fk.ThunderDamage and player:getMark("@n_chunzhen") > 0
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room

    if event == fk.AfterCardTargetDeclared then
      player:broadcastSkillInvoke(self.name)
      room:notifySkillInvoked(player, self.name, "special")
      local tos = room:askForChoosePlayers(player, TargetGroup:getRealTargets(data.tos), 1, 1,
        "#n_chunzhen-choose", self.name, false)
      TargetGroup:removeTarget(data.tos, tos[1])
      room:addPlayerMark(player, "@n_chunzhen", 1)
    else
      player:broadcastSkillInvoke(self.name)
      room:notifySkillInvoked(player, self.name, "defensive")
      room:removePlayerMark(player, "@n_chunzhen", 1)
      data.damage = data.damage - 1
    end
  end,
}
dj:addSkill(chunzhen)
Fk:loadTranslationTable{
  ["n_dingzhen"] = "丁真",
  ["n_yangwu"] = "扬雾",
  [":n_yangwu"] = "锁定技，游戏开始时，将1张【悦刻五】加入牌堆；" ..
    "游戏开始时或准备阶段，若你的装备区没有【悦刻五】，" ..
    "你从任意区域获得并使用之；若有，你选择是否重铸任意张手牌。你以此法从其他玩家处" ..
    "获得【悦刻五】后，对其造成1点伤害。",
  ["#n_yangwu-recast"] = "扬雾: 请重铸任意张手牌，或者点取消不重铸",
  ["n_chunzhen"] = "纯真",
  [":n_chunzhen"] = "锁定技，当你使用普通锦囊牌指定多个目标时，你" ..
    "须为此牌减少一个目标，然后你获得1枚“纯真”标记；" ..
    "当你受到雷属性伤害时，你弃置1枚“纯真”标记，令此伤害值-1。",
  ["#n_chunzhen-choose"] = "纯真: 必须为此牌减少一个目标",
  ["@n_chunzhen"] = "纯真",
}

local guojicheng = General(extension, "n_guojicheng", "qun", 3)
local chiyao = fk.CreateTriggerSkill{
  name = "n_chiyao",
  anim_type = "control",
  events = {fk.CardUsing},
  can_trigger = function(self, event, target, player, data)
    return target ~= player and player:hasSkill(self) and player:usedSkillTimes(self.name, Player.HistoryTurn) < 2 and
      data.card.is_damage_card and not data.card:isVirtual() and not player:isNude()
  end,
  on_cost = function(self, event, target, player, data)
    local c = player.room:askForDiscard(player, 1, 1, true, self.name, true,
      ".|.|heart", "#n_chiyao-discard:::" .. data.card:toLogString(), true)

    if c[1] then
      self.cost_data = {tos = {target.id}, cards = c}
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:throwCard(self.cost_data.cards, self.name, player, player)
    if not player.dead and not target:isNude() then
      local card = room:askForCardChosen(player, target, "he", self.name)
      room:throwCard({card}, self.name, target, player)
    end
    if data.toCard then
      data.toCard = nil
    else
      data.tos = {}
    end
    --room.logic:getCurrentEvent().parent:shutdown()
  end,
}
guojicheng:addSkill(chiyao)
local rulai = fk.CreateTriggerSkill{
  name = "n_rulai",
  anim_type = "drawcard",
  frequency = Skill.Compulsory,
  events = {fk.CardUseFinished},
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(self) then return end
    if data.card.trueName ~= "slash" then return end
    local room = player.room
    if #TargetGroup:getRealTargets(data.tos) == 0 or (data.nullifiedTargets and #data.nullifiedTargets > 0) then return true end
    local cur = room.logic:getCurrentEvent()
    if cur.interrupted then return true end
    local effects = cur:searchEvents(GameEvent.CardEffect, math.huge)
    for _, e in ipairs(effects) do
      if e.data[1].isCancellOut or (e.interrupted and not room:getPlayerById(e.data[1].to).dead) then
        return true
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(1, self.name)
  end,
}
guojicheng:addSkill(rulai)
Fk:loadTranslationTable{
  ["n_guojicheng"] = "郭继承",
  ["n_chiyao"] = "斥谣",
  [":n_chiyao"] = "每回合限两次，其他角色使用非转化伤害牌时，你可以弃置一张红桃牌" ..
    "令此牌无效，然后你弃置其一张牌。",
  ["#n_chiyao-discard"] = "斥谣: 你可以弃置一张红桃牌令 %arg 无效",
  ["n_rulai"] = "如来",
  [":n_rulai"] = "锁定技，当【杀】结算结束后，若其对某些目标无效或者被抵消，你摸一张牌。",

  ["$n_chiyao1"] = "我说你为什么非得找这种事，你告诉我你居心何在！",
  ["$n_chiyao2"] = "你为什么非得引导我们年轻人，觉得我们很差、不好？",
  ["$n_rulai1"] = "真来了吗？如~来。",
  ["$n_rulai2"] = "到底来没来？如~来。",
  ["~n_guojicheng"] = "你怎么可以骂老师…",
}

local extension_card = Package("brainhole_cards", Package.CardPack)

local brickSkill = fk.CreateActiveSkill{
  name = "n_brick_skill",
  max_round_use_time = 1,
  can_use = function(self, player, card, extra_data)
    return (extra_data and extra_data.bypass_times) or table.find(Fk:currentRoom().alive_players, function(p)
      return self:withinTimesLimit(player, Player.HistoryRound, card, "n_brick", p)
    end)
  end,
  target_num = 1,
  mod_target_filter = function(self, to_select, selected, user, card, distance_limited)
    local player = Fk:currentRoom():getPlayerById(to_select)
    local from = Fk:currentRoom():getPlayerById(user)
    return from ~= player and not (distance_limited and not self:withinDistanceLimit(from, true, card, player))
  end,
  target_filter = function(self, to_select, selected, _, card, extra_data)
    if #selected < self:getMaxTargetNum(Self, card) then
      local player = Fk:currentRoom():getPlayerById(to_select)
      return self:modTargetFilter(to_select, selected, Self.id, card, true) and
      (#selected > 0 or self:withinTimesLimit(Self, Player.HistoryRound, card, "n_brick", player)
      or (extra_data and extra_data.bypass_times))
    end
  end,
  on_effect = function(self, room, effect)
    local from = room:getPlayerById(effect.from)
    local to = room:getPlayerById(effect.to)
    local cards = room:getSubcardsByRule(effect.card, { Card.Processing })
    if #cards > 0 and not to.dead then
      room:obtainCard(to, effect.card, true, fk.ReasonGive, from.id)
    end
    if to.dead then return false end
    room:damage({
      from = from,
      to = to,
      card = effect.card,
      damage = 1,
      damageType = fk.NormalDamage,
      skillName = self.name
    })
  end
}
local brick = fk.CreateBasicCard{
  name = "n_brick",
  number = 6,
  suit = Card.Heart,
  is_damage_card = true,
  skill = brickSkill,
  special_skills = { "recast" },
}
extension_card:addCards{ brick }

local relxSkill = fk.CreateTriggerSkill{
  name = "#n_relx_skill",
  attached_equip = "n_relx_v",
  frequency = Skill.Compulsory,
  events = {fk.TargetSpecified},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and
      data.card.type ~= Card.TypeEquip and
      data.firstTarget and
      not table.find(player:getCardIds(Player.Hand), function(cid)
        local c = Fk:getCardById(cid)
        return c.type == Card.TypeBasic and c.color == Card.Red
      end) and
      #AimGroup:getAllTargets(data.tos) > 0
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local x = #AimGroup:getAllTargets(data.tos)
    room:notifySkillInvoked(player, "n_relx_v", "drawcard")
    player:drawCards(x, self.name)
    if x > 1 then room:damage { from = player, to = player, damage = 1, damageType = fk.ThunderDamage } end
  end,
}
Fk:addSkill(relxSkill)
local n_relx_v = fk.CreateTreasure{
  name = "&n_relx_v",
  suit = Card.Spade,
  number = 12,
  equip_skill = relxSkill,
}
extension_card:addCards{ n_relx_v }

Fk:loadTranslationTable{
  ["brainhole_cards"] = "脑洞包卡牌",
  ["n_brick"] = "砖",
  [":n_brick"] = "基本牌<br />" ..
    "<b>时机</b>：出牌阶段<br />" ..
    "<b>目标</b>：攻击范围内的一名其他角色<br />" ..
    "<b>效果</b>：交给其此牌，对目标角色造成1点伤害，然后本轮不能再使用【砖】。",

  ["n_relx_v"] = "悦刻五",
  [":n_relx_v"] = "装备牌·宝物<br />" ..
    "<b>宝物技能</b>：锁定技，当你使用非装备牌指定目标后，若你没有" ..
    "红色基本牌，你摸X张牌，然后若X>1，你对自己造成一点雷属性伤害（X为此牌指定的目标数）。<br />" ..
    '<font color="grey"><small>都什么年代了还在抽传统焉？</small></font>',
}

return {
  extension,
  require 'packages.brainhole.new_story',
  extension_card,
}
