local extension = Package("brainhole")

Fk:loadTranslationTable{
  ["brainhole"] = "脑洞包",
}

local n_zy = General(extension, "n_zy", "qun", 3)
local n_juanlaotrig = fk.CreateTriggerSkill{
  name = "#n_juanlaotrig",
  refresh_events = {fk.CardUseFinished, fk.EventPhaseStart},
  can_refresh = function(self, event, target, player, data)
    if not (target == player and player:hasSkill(self.name)) then return end
    if event == fk.CardUseFinished then
      return data.card.type == Card.TypeTrick and
        data.card.sub_type ~= Card.SubtypeDelayedTrick and
        (not data.card:isVirtual()) and
        player.phase ~= Player.NotActive and
        player:usedSkillTimes("n_juanlao", Player.HistoryPhase) == 0
    else
      return player.phase == Player.Finish
    end
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    local mark_name = "@n_juanlao"
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
    local cname = player:getMark("@n_juanlao")
    if cname == 0 then return end
    return Fk:cloneCard(cname).skill:canUse(player)
  end,
  enabled_at_response = function(self, player)
    -- FIXME: should have some way to know current response pattern here
    -- return player:getMark("@n_juanlao") == "nullification"
    return false
  end,

  card_filter = function() return false end,
  view_as = function(self, cards)
    local cname = Self:getMark("@n_juanlao")
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
    return target == player and player:hasSkill(self.name) and
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
    if not (target == player and player:hasSkill(self.name)) then return end
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
      self.cost_data = player:getMark(mark_name) >= 3
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
  ["@n_juanlao"] = "奆佬",
  [":n_juanlao"] = "阶段技。你可以视为使用了本回合你使用过的" ..
    "上一张非转化普通锦囊牌。",
  ["n_yegeng"] = "夜更",
  ["@n_yegeng"] = "夜更",
  [":n_yegeng"] = "锁定技。结束阶段，若你本回合使用普通锦囊牌数量不小于3，" ..
    "你进行一个额外的回合，否则你摸一张牌。",
}

local n_mabaoguo = General(extension, "n_mabaoguo", "qun", 4)
local n_hunyuan = fk.CreateTriggerSkill{
  name = "n_hunyuan",
  anim_type = "offensive",
  mute = true,
  events = {fk.DamageCaused, fk.Damage},
  can_trigger = function(self, event, target, player, data)
    if not (target == player and player:hasSkill(self.name)) then return end
    if event == fk.Damage then
      return player:getMark("n_hydmg1") == player:getMark("n_hydmg2") and
        player:getMark("n_hydmg2") == player:getMark("n_hydmg3")
    else
      return true
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    if event == fk.DamageCaused then
      local clist = {"n_toNormal", "n_toThunder", "n_toFire", "cancel"}
      local clist2 = {"n_toNormal", "n_toThunder", "n_toFire", "cancel"}
      table.remove(clist, data.damageType)
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
    if event == fk.DamageCaused then
      room:broadcastSkillInvoke(self.name, self.cost_data)
      data.damageType = self.cost_data
    else
      room:broadcastSkillInvoke(self.name, table.random{4, 5})
      room:damage{
        from = player,
        to = room:getPlayerById(self.cost_data),
        damage = 1
      }
    end
  end,

  refresh_events = {fk.Damage},
  can_refresh = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name)
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    room:addPlayerMark(player, "n_hydmg" .. data.damageType, data.damage)
    room:setPlayerMark(player, "@" .. self.name, string.format("%d-%d-%d",
      player:getMark("n_hydmg1"),
      player:getMark("n_hydmg2"),
      player:getMark("n_hydmg3")
    ))
  end,
}
n_mabaoguo:addSkill(n_hunyuan)
Fk:loadTranslationTable{
  ["n_mabaoguo"] = "马保国",
  ["n_hunyuan"] = "浑元",
  ["@n_hunyuan"] = "浑元",
  [":n_hunyuan"] = "你造成伤害时，可改变伤害属性。" ..
    "你造成伤害后，记录你造成的这种属性伤害的伤害值，" ..
    "然后若你造成过的普、火、雷这三种属性伤害值都相等，" ..
    "你可以对一名角色造成一点伤害。",
  ["#n_hy-ask"] = "浑元：你可以对一名角色造成一点伤害",
  ["n_toFire"] = "转换成火属性伤害",
  ["n_toThunder"] = "转换成雷属性伤害",
  ["n_toNormal"] = "转换成无属性伤害",
}

local n_qunlingdao = General(extension, "n_qunlingdao", "qun", 3)
local n_lingxiu = fk.CreateTriggerSkill{
  name = "n_lingxiu",
  anim_type = "drawcard",
  frequency = Skill.Compulsory,
  events = {fk.AfterCardsMove},
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(self.name) then return end
    local room = player.room
    if #table.filter(room:getOtherPlayers(player), function(p)
      return #p:getCardIds(Player.Hand) > #player:getCardIds(Player.Hand)
    end) == 0 then return end

    for _, move in ipairs(data) do
      if move.to == player.id and move.toArea == Card.PlayerHand then
        return true
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    player.room:delay(240)
    player:drawCards(1)
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
  [":n_lingxiu"] = "锁定技。你获得手牌后，若你的手牌数不为场上最多，你摸一张牌。",
  ["n_qunzhi"] = "群智",
  [":n_qunzhi"] = "阶段技。若你的体力值不超过你的手牌数，" ..
    "你可以将一半的手牌当一张普通锦囊牌（无懈除外）使用。" ..
    "（每种限用一次，你因本技能使用过全部普通锦囊牌后技能状态刷新。）",
  ["~n_qunlingdao"] = "我还会继续看群的...",
  ["$n_lingxiu1"] = "我才是领导！",
  ["$n_lingxiu2"] = "都听我的！",
  ["$n_qunzhi1"] = "集思广益！",
  ["$n_qunzhi2"] = "群众的智慧是无穷的！",
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
    if not player:hasSkill(self.name) then return end
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
    if not player:hasSkill(self.name) then return end
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

local n_hospair = General(extension, "n_hospair", "qun", 3)
n_hospair.gender = General.Female
n_hospair.hidden = true
n_hospair.total_hidden = true
local n_fudu = fk.CreateTriggerSkill{
  name = "n_fudu",
  anim_type = "offensive",
  events = {fk.CardUseFinished},
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(self.name) then return end
    if player:isKongcheng() then return end

    local use = data ---@type CardUseStruct
    local card = use.card
    if not (use.from ~= player.id and
      #use.tos == 1 and
      (card.type == Card.TypeBasic or
       (card.type == Card.TypeTrick and card.sub_type ~= Card.SubtypeDelayedTrick)
    )) then

      return
    end

    local room = player.room
    local target = use.tos[1][1] == player.id
      and room:getPlayerById(use.from)
      or room:getPlayerById(use.tos[1][1])

    if target.dead or player:prohibitUse(use.card)
      or player:isProhibited(target, use.card) then

      return
    end

    -- TODO: fix this
    if card.name == "peach" then
      return target:isWounded()
    elseif card.name == "snatch" or card.name == "dismantlement" then
      return not target:isAllNude()
    elseif card.name == "fire_attack" then
      return not target:isKongcheng()
    elseif card.name == "collateral" then
      return target:getEquipment(Card.SubtypeWeapon) ~= nil
    end

    return true
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local use = data ---@type CardUseStruct
    local target = use.tos[1][1] == player.id
      and room:getPlayerById(use.from)
      or room:getPlayerById(use.tos[1][1])

    local c = room:askForCard(player, 1, 1, false, self.name, true, ".",
      "@n_fudu::" .. target.id .. ":" .. use.card.name)[1]

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
  events = {fk.AfterCardsMove},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self.name) and player.phase == Player.NotActive and
      player:usedSkillTimes(self.name, Player.HistoryPhase) < 2 then
      self.trigger_times = 0
      for _, move in ipairs(data) do
        if move.from == player.id and (move.moveReason == fk.ReasonUse or move.moveReason == fk.ReasonResonpse or move.moveReason == fk.ReasonDiscard) then
          for _, info in ipairs(move.moveInfo) do
            if Fk:getCardById(info.cardId).color == Card.Red then
              self.trigger_times = self.trigger_times + 1
            end
          end
        end
      end
      return self.trigger_times > 0
    end
  end,
  on_trigger = function(self, event, target, player, data)
    local ret
    for i = 1, self.trigger_times do
      ret = self:doCost(event, target, player, data)
      if ret then return ret end
    end
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
  ["$n_fudu"] = "+1",
  [":n_fudu"] = "其他角色的指定唯一目标的基本牌或者普通锦囊牌结算完成后: <br/>" ..
  "① 若你是唯一目标，你可以将一张手牌当做此牌对使用者使用。<br/>" ..
  "② 若你不是唯一目标，你可以将一张手牌当做此牌对那名唯一目标使用。",
  ["@n_fudu"] = "复读：你现在可以将一张手牌当做 %arg 对 %dest 使用",
  ["n_mingzhe"] = "明哲",
  [":n_mingzhe"] = "每回合限两次，当你于回合外使用、打出或因弃置而失去一张红色牌时，你可以摸一张牌。",
}

return { extension }
