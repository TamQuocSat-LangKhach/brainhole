local fuyi = fk.CreateSkill {
  name = "n_fuyi",
}

Fk:loadTranslationTable{
  ["n_fuyi"] = "抚夷",
  [":n_fuyi"] = "出牌阶段限一次，你可以摸X+1张牌，弃置等量的牌。（X为“度田”记录的数量）",

  ["#n_fuyi"] = "抚夷：你可以摸 %arg 张牌，再弃置 %arg 张牌",
}

fuyi:addEffect("active", {
  anim_type = "drawcard",
  can_use = function(self, player)
    return player:usedSkillTimes(fuyi.name) == 0
  end,
  target_num = 0,
  prompt = function(self,player)
    return "#n_fuyi:::" .. (player:getMark("@n_dutian") + 1)
  end,
  card_filter = Util.FalseFunc,
  on_use = function(self, room, effect)
    local from = effect.from
    local x = from:getMark("@n_dutian")
    from:drawCards(x + 1, fuyi.name)
    room:askToDiscard(from, {
      min_num = x + 1,
      max_num = x + 1,
      skill_name = fuyi.name,
      include_equip = true,
      cancelable = false,
    })
  end
})

return fuyi
