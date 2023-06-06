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
  [":n_juanlao"] = "出牌阶段限一次，你可以视为使用了本回合你使用过的" ..
    "上一张非转化普通锦囊牌。",
  ["n_yegeng"] = "夜更",
  ["@n_yegeng"] = "夜更",
  [":n_yegeng"] = "锁定技，结束阶段，若你本回合使用普通锦囊牌数量不小于3，" ..
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
  ["$n_hunyuan1"] = "一个左正蹬~（吭）",
  ["$n_hunyuan2"] = "一个右鞭腿！",
  ["$n_hunyuan3"] = "一个左刺拳。",
  ["$n_hunyuan4"] = "三维立体浑元劲，打出松果糖豆闪电鞭",
  ["$n_hunyuan5"] = "耗子尾汁。",
  ["~n_mabaoguo"] = "这两个年轻人不讲武德，来，骗！来，偷袭！我六十九岁的老同志，这好吗这不好。",
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
  [":n_lingxiu"] = "锁定技，你获得手牌后，若你的手牌数不为场上最多，你摸一张牌。",
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
-- n_hospair.hidden = true
-- n_hospair.total_hidden = true
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
      use.tos and #use.tos == 1 and
      (not card:isVirtual()) and
      (card.type == Card.TypeBasic or
       (card.type == Card.TypeTrick and card.sub_type ~= Card.SubtypeDelayedTrick)
    )) then

      return
    end

    local room = player.room
    local target = use.tos[1][1] == player.id
      and room:getPlayerById(use.from)
      or room:getPlayerById(use.tos[1][1])

    -- if not table.find(player:getCardIds(Player.Hand), function(id)
    --   return Fk:getCardById(id).color == card.color
    -- end) then

    --   return
    -- end


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

    local ids = table.filter(player:getCardIds(Player.Hand), function(id)
      return Fk:getCardById(id).color == use.card.color
    end)

    local c = room:askForCard(player, 1, 1, false, self.name, true,
      tostring(Exppattern{ id = ids }),
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
      player:usedSkillTimes(self.name, Player.HistoryPhase) < 999 then
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
  ["$n_fudu"] = "加一",
  [":n_fudu"] = "其他角色的指定唯一目标的非转化的基本牌或者普通锦囊牌结算完成后: <br/>" ..
  "① 若你是唯一目标，你可以将颜色相同的一张手牌当做此牌对使用者使用。（无视距离）<br/>" ..
  "② 若你不是唯一目标，你可以将颜色相同的一张手牌当做此牌对那名唯一目标使用。（无视距离）",
  ["@n_fudu"] = "复读：你现在可以将一张手牌当做 %arg 对 %dest 使用",
  ["n_mingzhe"] = "明哲",
  [":n_mingzhe"] = "当你于回合外使用、打出或因弃置而失去一张红色牌时，你可以摸一张牌。",
}

local n_miaosha = General(extension, "n_miaosha", "wei", 4)
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
n_miaosha:addSkill(n_cizhi)
Fk:loadTranslationTable{
  ["n_miaosha"] = "郭修",
  ["n_cizhi"] = "刺智",
  [":n_cizhi"] = "当你造成伤害后，若你的体力值不大于伤害目标的体力值，" ..
    "则你可以对伤害目标造成一点伤害。",
}

local n_daotuwang = General(extension, "n_daotuwang", "qun", 3)
local n_daotu = fk.CreateTriggerSkill{
  name = "n_daotu",
  anim_type = "drawcard",
  events = {fk.CardUseFinished},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self.name) then
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
    room:obtainCard(target.id, card, false, fk.ReasonGive)

    local prev = player:getNextAlive()
    while prev:getNextAlive() ~= player do
      prev = prev:getNextAlive()
    end

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
    return target == player and player:hasSkill(self.name) and
      (data.to == player:getNextAlive() or data.to:getNextAlive() == player) and
      player:usedSkillTimes(self.name, Player.HistoryTurn) < 2
  end,
  on_use = function(self, event, _, player, data)
    local room = player.room
    local target = data.to

    local cids = target.player_cards[Player.Hand]
    room:fillAG(player, cids)

    local id = room:askForAG(player, cids, false, self.name)
    room:closeAG(player)

    if not id then return false end
    room:obtainCard(player, id, false)
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
    return target == player and player:hasSkill(self.name) and
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
    if not (target == player and player:hasSkill(self.name)) then return end
    if event == fk.TargetConfirmed then
      return data.from ~= player.id and data.card.is_damage_card
    else
      local e = player.room.logic:getCurrentEvent():findParent(GameEvent.UseCard)
      return (e.n_jujie_list or {})[player.id] ~= nil and data.from and
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

local notify = General(extension, "n_notify", "qun", 3)
local bianchengTrig = fk.CreateTriggerSkill{
  name = "#n_biancheng_trig",
  refresh_events = {fk.AfterCardsMove},
  can_refresh = function(self, event, target, player, data)
    if not player:hasSkill("n_biancheng") then return end
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
  -- anim_type = "drawcard",
  pattern = ".",
  interaction = function(self)
    local card = Fk:getCardById(Self:getMark(self.name))
    return UI.ComboBox {
      choices = { Fk:translate(card.name) .. '['
        .. Fk:translate("log_" .. card:getSuitString())
        .. card.number .. ']'
      }
    }
  end,
  card_filter = function()
    return false
  end,
  view_as = function(self, cards)
    local card = Fk:getCardById(Self:getMark(self.name))
    -- if card.suit == Card.Spade then return nil end
    card = Fk:cloneCard(card.name)
    card.skillName = self.name
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
    -- 服务器端判断无懈的时候这个pattern是nil。。
    local pat = Fk.currentResponsePattern or "nullification"
    return -- card.suit ~= Card.Spade and
      Exppattern:Parse(pat):matchExp(card.name)
  end,
}
biancheng:addRelatedSkill(bianchengTrig)
notify:addSkill(biancheng)
local tiaoshi = fk.CreateActiveSkill{
  name = "n_tiaoshi",
  anim_type = "drawcard",
  can_use = function(self, player)
    return player:usedSkillTimes(self.name) == 0
  end,
  target_num = 0,
  card_num = 0,
  card_filter = function()
    return false
  end,
  on_use = function(self, room, effect)
    local from = room:getPlayerById(effect.from)
    from:drawCards(1, self.name)
  end
}
notify:addSkill(tiaoshi)
Fk:loadTranslationTable{
  ["n_notify"] = "Notify_",
  ["n_biancheng"] = "编程",
  [":n_biancheng"] = "你可以使用或打出牌堆顶的牌。",
  ["n_tiaoshi"] = "调试",
  [":n_tiaoshi"] = "出牌阶段限一次，你可以摸一张牌。",
}

local extension_card = Package("brainhole_cards", Package.CardPack)

local brickSkill = fk.CreateActiveSkill{
  name = "n_brick_skill",
  target_num = 1,
  target_filter = function(self, to_select, selected, _, card)
    if #selected < self:getMaxTargetNum(Self, card) then
      local player = Fk:currentRoom():getPlayerById(to_select)
      return Self ~= player and
        (self:getDistanceLimit(Self, card) -- for no distance limit for slash
        + Self:getAttackRange()
        >= Self:distanceTo(player))
    end
  end,
  on_effect = function(self, room, effect)
    local from = room:getPlayerById(effect.from)
    local to = room:getPlayerById(effect.to)

    room:obtainCard(to, effect.card, true, fk.ReasonGive)

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
}
extension_card:addCards{ brick }

Fk:loadTranslationTable{
  ["brainhole_cards"] = "脑洞包卡牌",
  ["n_brick"] = "砖",
  [":n_brick"] = "基本牌<br />" ..
    "<b>时机</b>：出牌阶段<br />" ..
    "<b>目标</b>：攻击范围内的一名其他角色<br />" ..
    "<b>效果</b>：交给其此牌，对目标角色造成1点伤害。",
}

return { extension, extension_card }
