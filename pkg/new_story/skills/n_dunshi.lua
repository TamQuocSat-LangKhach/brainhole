local n_dunshi = fk.CreateSkill {
  name = "n_dunshi",
}

Fk:loadTranslationTable{
  ["n_dunshi"] = "炖世",
  [":n_dunshi"] = "每回合限一次，你可视为使用一张君子锦囊（拆顺无借懈笑瞒），然后当前回合角色本回合下次造成伤害时，你选择两项：<br>"..
  "1.防止此伤害，选择1个名字含有“典急孝乐崩赢”的同音字的技能令其获得；<br>"..
  "2.减1点体力上限并摸X张牌（X为你选择选项3的次数）；<br>"..
  "3.删除你本次视为使用的牌名。",

  ["@$n_dunshi"] = "炖世",
  ["n_dunshi1"] = "防止此伤害，选择1个“君子六艺”的技能令 %src 获得",
  ["n_dunshi2"] = "减1点体力上限并摸 %arg 张牌",
  ["n_dunshi3"] = "删除你本次视为使用的牌名：%arg",
  ["#n_dunshi-chooseskill"] = "炖世：选择令%dest获得的技能",

  ["$n_dunshi1"] = "天下皆黑，于我独白。",
  ["$n_dunshi2"] = "我不忿世，唯炖之而自觞。",
}

local U = require "packages/utility/utility"

local n_dunshi_names = { "dismantlement", "snatch", "ex_nihilo", "collateral", "nullification", "daggar_in_smile",
  "underhanding" }


n_dunshi:addEffect("viewas", {
  name = "n_dunshi",
  pattern = table.concat(n_dunshi_names, ","),
  interaction = function(self, player)
    local all_names, names = n_dunshi_names, {}
    for _, name in ipairs(player:getTableMark("@$n_dunshi")) do
      local to_use = Fk:cloneCard(name)
      if ((Fk.currentResponsePattern == nil and player:canUse(to_use) and not player:prohibitUse(to_use)) or
            (Fk.currentResponsePattern and Exppattern:Parse(Fk.currentResponsePattern):match(to_use))) then
        table.insert(names, name)
      end
    end
    if #names == 0 then return end
    return U.CardNameBox { choices = names }
  end,
  card_filter = Util.FalseFunc,
  view_as = function(self, cards)
    if not self.interaction.data then return nil end
    local card = Fk:cloneCard(self.interaction.data)
    card.skillName = n_dunshi.name
    return card
  end,
  before_use = function(self, player, use)
    player.room:setPlayerMark(player, "n_dunshi_name-turn", use.card.trueName)
  end,
  enabled_at_play = function(self, player)
    if player:usedSkillTimes(n_dunshi.name, Player.HistoryTurn) > 0 then return false end
    for _, name in ipairs(player:getTableMark("@$n_dunshi")) do
      local to_use = Fk:cloneCard(name)
      if player:canUse(to_use) and not player:prohibitUse(to_use) then
        return true
      end
    end
  end,
  enabled_at_response = function(self, player, response)
    if player:usedSkillTimes(n_dunshi.name, Player.HistoryTurn) > 0 then return false end
    for _, name in ipairs(player:getTableMark("@$n_dunshi")) do
      local to_use = Fk:cloneCard(name)
      if (Fk.currentResponsePattern and Exppattern:Parse(Fk.currentResponsePattern):match(to_use)) then
        return true
      end
    end
  end,
})
n_dunshi:addAcquireEffect(function (self, player, is_start)
  player.room:setPlayerMark(player, "@$n_dunshi", n_dunshi_names)
end)
n_dunshi:addLoseEffect(function (self, player, is_death)
  player.room:setPlayerMark(player, "@$n_dunshi", 0)
end)
n_dunshi:addEffect(fk.DamageCaused, {
  name = "#n_dunshi_record",
  anim_type = "special",
  can_trigger = function(self, event, target, player, data)
    if player:usedSkillTimes("n_dunshi", Player.HistoryTurn) > 0 and target and target.phase ~= Player.NotActive then
      return player:getMark("n_dunshi_name-turn") ~= 0
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local card_name = player:getMark("n_dunshi_name-turn")
    room:setPlayerMark(player, "n_dunshi_name-turn", 0)
    local tech = {
      "崩",
      "急",
      "典",
      "孝", "笑",
      "乐",
      "赢", "营",
    }
    local chosen = {}
    for i = 1, 2, 1 do
      local delete_num = #n_dunshi_names - #player:getTableMark("@$n_dunshi")
      local all_choices = { "n_dunshi1:" .. target.id, "n_dunshi2:::" .. delete_num, "n_dunshi3:::" .. card_name }
      local choices = table.filter(all_choices, function(c)
        return not table.find(chosen, function(index) return c:startsWith("n_dunshi" .. index) end)
      end)
      local choice = room:askToChoice(player, {
        choices = choices,
        skill_name = n_dunshi.name,
        all_choices = all_choices,
      })
      table.insert(chosen, table.indexOf(all_choices, choice))
      if choice:startsWith("n_dunshi1") then
        data:preventDamage()
        local skills = {}
        for _, general in ipairs(Fk:getAllGenerals()) do
          for _, skillName in ipairs(general:getSkillNameList()) do
            local skill = Fk.skills[skillName]
            local str = Fk:translate(skillName)
            if table.find(tech, function(s) return string.find(str, s) ~= nil end) then
              local name = skill.name
              if not target:hasSkill("n_yingma", true) and (target:hasSkill(skill) or string.find(name, "&")) then
                name = "n_yingma"
              end
              if not target:hasSkill(name, true) then
                table.insertIfNeed(skills, name)
              end
            end
          end
        end
        if #skills > 0 then
          local skill = room:askToChoice(player, {
            choices = table.random(skills, math.min(3, #skills)),
            skill_name = n_dunshi.name,
            detailed = true,
            prompt = "#n_dunshi-chooseskill::" .. target.id,
          })
          room:handleAddLoseSkills(target, skill, nil, true, false)
        end
      elseif choice:startsWith("n_dunshi2") then
        room:changeMaxHp(player, -1)
        if not player.dead and delete_num ~= 0 then
          player:drawCards(delete_num, "n_dunshi")
        end
      elseif choice:startsWith("n_dunshi3") then
        room:removeTableMark(player, "@$n_dunshi", card_name)
      end
    end
  end,
})

return n_dunshi
