local chunzhen = fk.CreateSkill {
  name = "n_chunzhen",
  tags = { Skill.Compulsory, },
}

Fk:loadTranslationTable{
  ["n_chunzhen"] = "纯真",
  [":n_chunzhen"] = "锁定技，当你使用普通锦囊牌指定多个目标时，你须为此牌减少一个目标，然后你获得1枚“纯真”标记；当你受到雷属性伤害时，"..
  "你弃置1枚“纯真”标记，令此伤害值-1。",

  ["#n_chunzhen-choose"] = "纯真: 必须为此牌减少一个目标",
  ["@n_chunzhen"] = "纯真",
}

chunzhen:addEffect(fk.AfterCardTargetDeclared, {
  can_trigger = function(self, event, target, player, data)
    if not (target == player and player:hasSkill(chunzhen.name)) then
      return false
    end
    return data.card:isCommonTrick() and #data.tos > 1
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 1,
      targets = data.tos,
      skill_name = chunzhen.name,
      prompt = "#n_chunzhen-choose",
      cancelable = false,
    })[1]
    data:removeTarget(to)
    room:addPlayerMark(player, "@n_chunzhen", 1)
  end,
})

chunzhen:addEffect(fk.DamageInflicted, {
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    if not (target == player and player:hasSkill(chunzhen.name)) then
      return false
    end
    return data.damageType == fk.ThunderDamage and player:getMark("@n_chunzhen") > 0
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:removePlayerMark(player, "@n_chunzhen", 1)
    data:changeDamage(-1)
  end,
})

return chunzhen
