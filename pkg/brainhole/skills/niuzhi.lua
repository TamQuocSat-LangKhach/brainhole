local niuzhi = fk.CreateSkill {
  name = "n_niuzhi",
}

Fk:loadTranslationTable{
  [":n_niuzhi"] = "当你受到伤害后，你可以对伤害来源发起一次<a href='heg_command'>“军令”</a>，若其不执行，你回复一点体力，否则你本阶段不能再发动此技能。",
  ["heg_command"] = "<b>军令</b>：<u>发起军令的角色</u>随机获得两张军令牌，然后选择其中一张。<u>执行军令的角色</u>选择是否执行该“军令”。<br/>"..
  "军令牌有6种：<br/>军令一：对发起者指定的角色造成1点伤害；<br/>军令二：摸一张牌，然后交给发起者两张牌；<br/>"..
  "军令三：失去1点体力；<br/>军令四：本回合不能使用或打出手牌且所有非锁定技失效；<br/>"..
  "军令五：叠置，本回合不能回复体力；<br/>军令六：选择一张手牌和一张装备区里的牌，弃置其余的牌。",
  ["#n_niuzhi-ask"] = "牛智: 你可以对 %src 发起“军令”，若其不执行你回血",
}

local H = require 'packages/hegemony/util'

niuzhi:addEffect(fk.Damaged, {
  anim_type = "defensive",
  can_trigger = function(self, event, target, nyunyu, data)
    return target == nyunyu and nyunyu:hasSkill(self) and data.from and nyunyu:getMark("n_niuzhi-turn") == 0
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    if room:askForSkillInvoke(player, self.name, nil, "#n_niuzhi-ask:" .. data.from.id) then
      return true
    end
  end,
  on_use = function(self, event, target, nyunyu, data)
    local room = nyunyu.room
    if H.askCommandTo(nyunyu, data.from, self.name) then
      room:addPlayerMark(nyunyu, "n_niuzhi-turn", 1)
    else
      room:recover{
        who = nyunyu,
        num = 1,
        skillName = self.name,
      }
    end
  end,
})

return niuzhi
