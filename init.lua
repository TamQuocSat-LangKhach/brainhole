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
      player.phase == Player.Finish and self.can_yegeng
  end,
  on_use = function(self, event, target, player, data)
    player:gainAnExtraTurn()
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
      self.can_yegeng = player:getMark(mark_name) >= 3
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
    "你进行一个额外的回合。",
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
    "你造成伤害后，若你造成过的三种属性伤害值都相等，" ..
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

return { extension }
