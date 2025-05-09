local tuguo = fk.CreateSkill{
  name = "n_tuguo",
}

Fk:loadTranslationTable{
  ["n_tuguo"] = "图国",
  [":n_tuguo"] = "出牌阶段限一次，你可以对自己造成1点伤害，然后获得一张<a href='heg_trick'>国战锦囊</a>或一枚<a href='heg_mark'>国战标记</a>（每种牌名/标记限两次，获得卡牌的花色点数随机）。",
  ["#n_tuguo-active"] = "图国: 你可以对自己造成1伤害，然后拿国战牌或标记",
  ["heg_trick"] = "<b>国战锦囊</b>：<br/><b>远交近攻</b>：出牌阶段，选择势力与你不同的一名角色，其摸一张牌，你摸三张牌。<br/>" ..
  "<b>知己知彼</b>：出牌阶段，选择一名其他角色，观看其手牌<s>或一张暗置的武将牌</s>。<br/>" ..
  "<b>以逸待劳</b>：出牌阶段，你和与你势力相同的角色各摸两张牌，然后弃置两张牌。<br/>" ..
  "<b>火烧连营</b>：出牌阶段，对你的下家和与其同一<u>队列</u>（相邻、势力相同）的所有角色各造成1点火焰伤害。<br/>" ..
  "<b>调虎离山</b>：出牌阶段，选择一至两名其他角色，这些角色于此回合内不计入距离和座次的计算，且不能使用牌，且不是牌的合法目标，且体力值不会改变。<br/>" ..
  "<b>勠力同心</b>：出牌阶段，选择所有<u>大势力</u>（角色数最多的势力）角色或<u>小势力</u>（角色数不是最多的势力）角色，若这些角色处于/不处于连环状态，其摸一张牌/横置。<br/>" ..
  "<b>联军盛宴</b>：选择除你的势力外的一个势力的所有角色，对你和这些角色使用，你选择X（不大于Y），摸X张牌，回复Y-X点体力（Y为该势力的角色数）；这些角色各摸一张牌，重置。<br/>" ..
  "<b>挟天子以令诸侯</b>：出牌阶段，若你为<u>大势力</u>（角色数最多的势力）角色，对你使用，你结束出牌阶段，此回合弃牌阶段结束时，你可弃置一张手牌，然后获得一个额外回合。<br/>",
  ["heg_mark"] = "<b>国战标记</b>：<br/><b>先驱</b>：出牌阶段，你可弃一枚“先驱”，将手牌摸至4张<s>，观看一名其他角色的一张暗置武将牌</s>。<br/>" ..
  "<b>阴阳鱼</b>：①出牌阶段，你可弃一枚“阴阳鱼”，摸一张牌；②弃牌阶段开始时，你可弃一枚“阴阳鱼”，此回合手牌上限+2。<br/>" ..
  "<b>珠联璧合</b>：①出牌阶段，你可弃一枚“珠联璧合”，摸两张牌；②你可弃一枚“珠联璧合”，视为使用【桃】。<br/>" ..
  "<b>野心家</b>：你可将一枚“野心家”当以上三种中任意一种标记弃置并执行其效果。",
}

local tuguo_choices = {
  -- 卡牌们
  "befriend_attacking", "known_both", "await_exhausted", "burning_camps", "lure_tiger",
  "fight_together", "alliance_feast", "threaten_emperor",
  -- 标记们
  "vanguard", "yinyangfish", "companion", "wild",
}

local H = require 'packages/hegemony/util'

tuguo:addEffect("active", {
  anim_type = "drawcard",
  prompt = "#n_tuguo-active",
  max_card_num = 0,
  target_num = 0,
  interaction = function(self, nyunyu)
    local mark = nyunyu:getMark("n_tuguo_choices")
    if mark == 0 then mark = Util.DummyTable end
    local c = table.simpleClone(tuguo_choices)
    for k, v in pairs(mark) do
      if v >= 2 then table.removeOne(c, k) end
    end
    return UI.ComboBox {
      choices = c,
      all_choices = tuguo_choices
    }
  end,
  can_use = function(self, nyunyu)
    return nyunyu:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = Util.FalseFunc,
  on_use = function(self, room, effect)
    local nyunyu = effect.from
    local name = self.interaction.data
    local mark = nyunyu:getMark("n_tuguo_choices")
    if mark == 0 then mark = {} end
    mark[name] = mark[name] and mark[name] + 1 or 1
    room:setPlayerMark(nyunyu, "n_tuguo_choices", mark)

    room:damage {
      from = nyunyu,
      to = nyunyu,
      damage = 1,
    }
    if nyunyu.dead then return end
    local cd = Fk.all_card_types[name]
    if not cd then
      H.addHegMark(room, nyunyu, name)
    else
      local c = room:printCard(name, math.random(1,4), math.random(1,13))
      room:obtainCard(nyunyu, c.id, true)
    end
  end,
})

return tuguo
