local n_suijie = fk.CreateSkill {
  name = "n_suijie",
}

Fk:loadTranslationTable{
  ["n_suijie"] = "随杰",
  [":n_suijie"] = "当你成为其他角色使用【桃】【酒】【五谷丰登】【桃园结义】的目标后，你可以令其摸一张牌，然后你将手牌数摸至与其一致。",

  ["#n_suijie_ask"] = "随杰：你可以令 %src 摸一张牌，然后你将手牌摸至与其相等",
  ["$n_suijie1"] = "杰哥，那我跟我朋友今天就去住你家哦。",
  ["$n_suijie2"] = "谢谢杰哥~",
}

n_suijie:addEffect(fk.TargetConfirmed, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(n_suijie.name) and
      data.from ~= player and
      table.contains(
        { "peach", "analeptic", "amazing_grace", "god_salvation" },
        data.card.name)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    if room:askToSkillInvoke(player, {
      skill_name = n_suijie.name,
      prompt = "#n_suijie_ask:" .. data.from.id,
    }) then
      event:setCostData(self, {tos = {data.from}})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    data.from:drawCards(1, n_suijie.name)
    local n = data.from:getHandcardNum() - player:getHandcardNum()
    if n > 0 and player:isAlive() then
      player:drawCards(n, n_suijie.name)
    end
  end,
})

return n_suijie