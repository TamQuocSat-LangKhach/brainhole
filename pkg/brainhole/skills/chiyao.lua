local chiyao = fk.CreateSkill {
  name = "n_chiyao",
}

Fk:loadTranslationTable{
  ["n_chiyao"] = "斥谣",
  [":n_chiyao"] = "每回合限两次，其他角色使用非转化伤害牌时，你可以弃置一张<font color='red'>♥</font>牌令此牌无效，然后你弃置其一张牌。",

  ["#n_chiyao-discard"] = "斥谣: 你可以弃置一张<font color='red'>♥</font>牌令 %arg 无效",

  ["$n_chiyao1"] = "我说你为什么非得找这种事，你告诉我你居心何在！",
  ["$n_chiyao2"] = "你为什么非得引导我们年轻人，觉得我们很差、不好？",
}

chiyao:addEffect(fk.CardUsing, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return target ~= player and player:hasSkill(chiyao.name) and player:usedSkillTimes(chiyao.name, Player.HistoryTurn) < 2 and
      data.card.is_damage_card and not data.card:isVirtual() and not player:isNude()
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local card = room:askToDiscard(player, {
      min_num = 1,
      max_num = 1,
      include_equip = true,
      skill_name = chiyao.name,
      pattern = ".|.|heart",
      prompt = "#n_chiyao-discard:::" .. data.card:toLogString(),
      cancelable = true,
      skip = true,
    })
    if #card > 0 then
      event:setCostData(self, {tos = {target}, cards = card})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:throwCard(event:getCostData(self).cards, chiyao.name, player, player)
    if not player.dead and not target:isNude() then
      local card = room:askToChooseCard(player, {
        target = target,
        flag = "he",
        skill_name = chiyao.name,
      })
      room:throwCard(card, chiyao.name, target, player)
    end
    data.toCard = nil
    data:removeAllTargets()
  end,
})

return chiyao