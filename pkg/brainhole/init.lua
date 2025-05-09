local extension = Package:new("brainhole")
--extension:addGameMode(require "packages.brainhole.pkg.brainhole.melee")
--extension:addGameMode(require "packages.brainhole.pkg.brainhole.samemode")

extension:loadSkillSkels(require "packages.brainhole.pkg.brainhole.skills")

Fk:loadTranslationTable{
  ["brainhole"] = "脑洞包",
}

Fk:loadTranslationTable{
  ["n_pigeon"] = "鸽",
}

General(extension, "n_zy", "n_pigeon", 3):addSkills { "n_juanlao", "n_yegeng" }
Fk:loadTranslationTable{
  ["n_zy"] = "ＺＹ",
  ["designer:n_zy"] = "notify",
}

General(extension, "n_wch", "n_pigeon", 3):addSkills { "n_didiao", "n_shenjiao" }
Fk:loadTranslationTable{
  ["n_wch"] = "饺神",
  ["designer:n_wch"] = "Notify",
  ["illustrator:n_wch"] = "来自网络",
}

General(extension, "n_qunlingdao", "n_pigeon", 3):addSkills { "n_lingxiu", "n_qunzhi" }
Fk:loadTranslationTable{
  ["n_qunlingdao"] = "群领导",
  ["~n_qunlingdao"] = "我还会继续看群的...",
  ["designer:n_qunlingdao"] = "notify",
}

General(extension, "n_hospair", "n_pigeon", 3, 3, General.Female):addSkills { "n_fudu", "n_mingzhe" }
Fk:loadTranslationTable{
  ["n_hospair"] = "惑神",
  ["designer:n_hospair"] = "Notify",
  ["illustrator:n_hospair"] = "来自网络",
}

General(extension, "n_xxyheaven", "n_pigeon", 3, 3, General.Female)
  :addSkills { "n_kaoda", "n_chonggou", "n_kuiping" }
Fk:loadTranslationTable{
  ["n_xxyheaven"] = "心变",
  ["designer:n_xxyheaven"] = "notify",
}

local youmukon = General:new(extension, "n_youmukon", "n_pigeon", 3, 3, General.Female)
youmukon.trueName = "th_youmu"
youmukon:addSkills { "n_yaodao", "n_huanmeng" }
Fk:loadTranslationTable{
  ["n_youmukon"] = "妖梦厨",
  ["designer:n_youmukon"] = "妖梦厨",
  ["~n_youmukon"] = "（Biu~）",
  ["$n_youmukon_win_audio"] = "（Spell Card Bonus!）",
}

local emoprincess = General(extension, "n_emoprincess", "n_pigeon", 3, 3, General.Female)
emoprincess.trueName = "emoprincess"
emoprincess:addSkills { "n_leimu", "n_xiaogeng", "n_fencha" }
Fk:loadTranslationTable{
  ["n_emoprincess"] = "emo",
  ["designer:n_emoprincess"] = "emo",
}

General(extension, "n_daotuwang", "n_pigeon", 3):addSkills { "n_daotu" }
Fk:loadTranslationTable{
  ["n_daotuwang"] = "盗图王",
  ["designer:n_daotuwang"] = "Notify",
  ["~n_daotuwang"] = "盗图王，你.....",
  ["illustrator:n_daotuwang"] = "网络",
  ["#n_daotuwang"] = "人畜无害",
}

local nyutan = General(extension, "n_nyutan", "n_pigeon", 3)
nyutan.gender = General.Female
nyutan:addCompanions{ "os__niujin", "niufu" }
nyutan:addSkills { "n_tuguo", "n_niuzhi" }
Fk:loadTranslationTable{
  ["n_nyutan"] = "Nyutan_",
  ["n_niuzhi"] = "牛智",
}

local ralph = General(extension, "n_ralph", "n_pigeon", 3)
ralph.gender = General.Female
ralph.trueName = "th_kogasa"
ralph:addSkills { "n_subian", "n_rigeng", "n_fanxiu" }
Fk:loadTranslationTable{
  ["n_ralph"] = "Ｒ神",
}

General(extension, "n_0t", "n_pigeon", 3, 3, General.Female):addSkills { "n_cejin", "n_yinghui" }
Fk:loadTranslationTable{
  ["n_0t"] = "聆听",
}

General(extension, "n_notify", "n_pigeon", 3):addSkills { "n_biancheng", "n_tiaoshi", "n_baogan" }
Fk:loadTranslationTable{
  ["n_notify"] = "Notify_",
  ["designer:n_notify"] = "notify",
}

local n_mabaoguo = General(extension, "n_mabaoguo", "qun", 4)
Fk:loadTranslationTable{
  ["n_mabaoguo"] = "马保国",
  ["~n_mabaoguo"] = "这两个年轻人不讲武德，来，骗！来，偷袭！我六十九岁的老同志，这好吗这不好。",
}

--[[
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

---@param player ServerPlayer
---@param move CardsMoveStruct
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

---@param player ServerPlayer
local function songjiCanUse(player)
  local canSlash = not player:prohibitUse(Fk:cloneCard("slash"))
  local canPeach = not player:prohibitUse(Fk:cloneCard("peach"))

  canSlash = canSlash and table.find(player.room:getOtherPlayers(player, false), function(p)
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

    local choices = {}
    local s, p = songjiCanUse(player)
    if s then table.insert(choices, "slash") end
    if p then table.insert(choices, "peach") end
    -- table.insert(choices, "Cancel")
    local choice = room:askForChoice(player, choices, self.name)

    if choice == "peach" then
      self.cost_data = {
        cards = c,
        cname = choice,
        tos = {player.id},
      }
      return true
    elseif choice == "slash" then
      local targets = table.filter(room:getOtherPlayers(player, false), function(p)
        return player:inMyAttackRange(p) and
          not player:isProhibited(p, Fk:cloneCard("slash"))
      end)
      targets = table.map(targets, Util.IdMapper)
      local p2 = room:askForChoosePlayers(player, targets, 1, 1, "@n_songji_slash",
        self.name, true)

      if #p2 ~= 0 then
        self.cost_data = {
          cards = c,
          cname = choice,
          tos = p2,
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
    use.tos = { dat.tos }
    local card = Fk:cloneCard(dat.cname)
    card:addSubcard(dat.cards[1])
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
    return #selected == 0 and to_select ~= Self.id and Fk:currentRoom():getPlayerById(to_select):getNextAlive() ~= Self
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
      self.cost_data = {tos = { data.from } }
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local from = room:getPlayerById(data.from)
    from:drawCards(1, self.name)
    local a, b = player:getHandcardNum(), from:getHandcardNum()
    if a < b and player:isAlive() then
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
        self.cost_data = {cards = ids}
        return true
      end
    else
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if event == fk.TargetConfirmed then
      room:throwCard(self.cost_data.cards, self.name, player, player)
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
    player:broadcastSkillInvoke(self.name)
    if event == fk.AfterCardTargetDeclared then
      room:notifySkillInvoked(player, self.name, "special")
      local tos = room:askForChoosePlayers(player, TargetGroup:getRealTargets(data.tos), 1, 1,
        "#n_chunzhen-choose", self.name, false)
      TargetGroup:removeTarget(data.tos, tos[1])
      room:addPlayerMark(player, "@n_chunzhen", 1)
    else
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

local shaheshang = General:new(extension, "n_shaheshang", "god", 3)
local liusha = fk.CreateTriggerSkill{
  name = "n_liusha",
  anim_type = "defensive",
  events = {fk.TargetConfirming},
  ---@param data AimStruct
  can_trigger = function(self, event, target, player, data)
    local ret = target == player and player:hasSkill(self) and
      data.card:getSubtypeString() == "normal_trick" and
      not TargetGroup:includeRealTargets(data.tos, data.from)

    if ret then
      return not player:isAllNude()
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local prompt = "#n_liusha"
    local cards = room:askForDiscard(player, 1, 1, true, self.name, true, ".|.|diamond", prompt, true)
    if #cards > 0 then
      self.cost_data = cards
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local toId = data.from
    local to = room:getPlayerById(toId)
    room:throwCard(self.cost_data, self.name, player, player)
    if player.dead then return end
    local choices ={ "n_liusha_choice1" }
    if not to:isNude() then table.insert(choices, "n_liusha_choice2") end
    local choice = room:askForChoice(player, choices, self.name)
    if choice == "n_liusha_choice1" then
      AimGroup:cancelTarget(data, player.id)
      AimGroup:addTargets(room, data, toId)
    else
      local c = room:askForCardChosen(player, to, "he", self.name)
      room:obtainCard(player, c, false, fk.ReasonPrey, player.id)
    end
  end,
}
shaheshang:addSkill(liusha)
local equip_subtypes = {
  Card.SubtypeWeapon,
  Card.SubtypeArmor,
  Card.SubtypeDefensiveRide,
  Card.SubtypeOffensiveRide,
  Card.SubtypeTreasure
}
local kuli = fk.CreateTriggerSkill{
  name = "n_kuli",
  anim_type = "support",
  frequency = Skill.Compulsory,
  events = {fk.AfterCardsMove},
  ---@param data CardsMoveStruct[]
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(self) then return end
    for _, move in ipairs(data) do
      if move.to == player.id and move.toArea == Card.PlayerEquip then
        for _, st in ipairs(equip_subtypes) do
          if not player:hasEmptyEquipSlot(st) then
            return true
          end
        end
        return false
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    for _, st in ipairs(equip_subtypes) do
      if not player:hasEmptyEquipSlot(st) then
        room:addPlayerEquipSlots(player, Util.convertSubtypeAndEquipSlot(st))
        if player:isAlive() then player:drawCards(2, self.name) end
      end
    end
  end,
}
shaheshang:addSkill(kuli)
Fk:loadTranslationTable{
  ["n_shaheshang"] = "沙和尚",
  ["#n_shaheshang"] = "任劳任怨",
  ["designer:n_shaheshang"] = "西游杀",
  ["illustrator:n_shaheshang"] = "",
  ["n_liusha"] = "流沙",
  [":n_liusha"] = "当你成为普通锦囊牌的目标时，若使用者不是目标，你可以弃置一张方块牌并选择：1.将目标转移给使用者；2.获得使用者一张牌。",
  ["#n_liusha"] = "流沙：你可以弃置一张方块牌，将此牌目标转移给使用者或者获得其一张牌",
  ["n_liusha_choice1"] = "将目标转移给使用者",
  ["n_liusha_choice2"] = "获得使用者一张牌",
  ["n_kuli"] = "苦力",
  [":n_kuli"] = "锁定技，当牌进入你的装备区后，你每缺少某种类别的空置装备栏，便获得一个额外的对应类别的装备栏并摸两张牌。" ..
  "<br><font color='gray'>注：UI未适配多装备栏，需要等待游戏软件版本更新，请勿反馈显示问题。</font>",
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
  mod_target_filter = function(self, to_select, selected, from, card, distance_limited)
    local player = Fk:currentRoom():getPlayerById(to_select)
    return from ~= player and not (distance_limited and not self:withinDistanceLimit(from, true, card, player))
  end,
  target_filter = function(self, to_select, selected, _, card, extra_data, player)
    if Util.TargetFilter(self, to_select, selected, _, card, extra_data, player) then
      local target = Fk:currentRoom():getPlayerById(to_select)
      return self:modTargetFilter(to_select, selected, player, card, true) and
      (#selected > 0 or self:withinTimesLimit(player, Player.HistoryRound, card, "n_brick", target)
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
    if to.dead or from.dead then return false end
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
    if x > 1 and player:isAlive() then room:damage { from = player, to = player, damage = 1, damageType = fk.ThunderDamage } end
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
    "红色基本牌，你摸X张牌，然后若X>1，你对自己造成1点雷属性伤害（X为此牌指定的目标数）。<br />" ..
    '<font color="grey"><small>都什么年代了还在抽传统焉？</small></font>',
}
--]]

return extension
