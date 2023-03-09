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
    -- FIXME: this is a bug of FK!! server side should set Self before calling view_as
    local p
    if RoomInstance then
      p = RoomInstance.current
    else
      p = Self
    end
    local cname = p:getMark("@n_juanlao")
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
    -- TODO: implement for player:gainAnExtraTurn
    local room = player.room
    local current = room.current
    room.current = player
    GameEvent(GameEvent.Turn):exec()
    room.current = current
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
      -- FIXME: this is bug of FK! unable to show mark num
      self.can_yegeng = tonumber(player:getMark(mark_name)) >= 3
      room:setPlayerMark(player, mark_name, 0)
    else
      room:setPlayerMark(player, mark_name, tostring(
        tonumber(player:getMark(mark_name)) + 1
      ))
    end
  end
}
n_zy:addSkill(n_yegeng)
Fk:loadTranslationTable{
  ["n_zy"] = "ＺＹ",
	["n_juanlao"] = "巨佬",
	["@n_juanlao"] = "巨佬",
	[":n_juanlao"] = "阶段技。你可以视为使用了本回合你使用过的上一张非转化普通锦囊牌。",
	["n_yegeng"] = "夜更",
	["@n_yegeng"] = "夜更",
	[":n_yegeng"] = "锁定技。结束阶段，若你本回合使用普通锦囊牌数量不小于3，你进行一个额外的回合。",
}

return { extension }
