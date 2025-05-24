local dianlun = fk.CreateSkill {
  name = "n_dianlun",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["n_dianlun"] = "典论",
  [":n_dianlun"] = "锁定技，每回合限一次，你在摸牌阶段外获得牌后，你须弃置一张牌并从随机2个典中爆一次典。<br/>"..
  "<font color=>*论英：令你和一名其他角色依次进行闪电判定，直到有一方受到伤害为止，其在开始判定之前可以对自己造成1点雷电伤害中止此流程。<br/>"..
  "*割须：弃置装备区的1张牌并回复1点体力。<br/>"..
  "*夺妻：整局游戏限一次，获得一名其他女性角色武将牌上的一个技能。<br/>"..
  "*三笑：指定一名角色，令其选择是否对你用一张无视距离的【杀】，若其未使用【杀】或此【杀】未造成对你伤害，其本回合非锁定技失效。<br/>"..
  "*假寐：你令一名其他角色摸1张牌，再视为对其使用一张【杀】。<br/>"..
  "*共枕：指定一名其他女性角色，你与其各摸1张牌并翻面。</font>",

  ["#n_dianlun_start"] = "典论: 请弃置一张牌并爆典",

  ["n_cc_lunying"] = "论英",
  [":n_cc_lunying"] = "令你和一名其他角色依次进行闪电判定，直到有一方受到伤害为止，其在开始判定之前可以对自己造成1点雷电伤害中止此流程。",
  ["#n_cc_lunying"] = "论英: 选择一名其他角色，和他谈论当世英雄！",
  ["#n_cc_lunying_cancel"] = "论英: 你现在可以对自己造成一点雷电伤害并中止“论英”",
  ["n_cc_gexu"] = "割须",
  [":n_cc_gexu"] = "弃置装备区的1张牌并回复1点体力。",
  ["#n_cc_gexu"] = "割须: 请弃置一张装备牌，回复1点体力",
  ["n_cc_duoqi"] = "夺妻",
  [":n_cc_duoqi"] = "获得一名其他女性角色武将牌上的一个技能。",
  ["#n_cc_duoqi"] = "夺妻: 选择一名女性角色，永久获得她的一个技能",
  ["#n_cc_duoqi-choice"] = "夺妻: 获得 %dest 的一个技能",
  ["n_cc_sanxiao"] = "三笑",
  [":n_cc_sanxiao"] = "指定一名角色，令其对你用一张无视距离的【杀】，若此杀未造成伤害，其本回合非锁定技失效。",
  ["#n_cc_sanxiao"] = "三笑: 令一名其他角色【杀】你，若没杀中则其本回合非锁定技失效",
  ["#n_cc_sanxiao-use"] = "三笑: 请对 %src 使用【杀】，不杀或未杀中则本回合非锁定技失效",
  ["@@n_cc_sanxiao-turn"] = "被三笑",
  ["n_cc_jiamei"] = "假寐",
  [":n_cc_jiamei"] = "你令一名其他角色摸1张牌，再视为对其使用一张【杀】。",
  ["#n_cc_jiamei"] = "假寐: 令一名其他角色摸一张牌并视为对其出【杀】",
  ["n_cc_gongzhen"] = "共枕",
  [":n_cc_gongzhen"] = "指定一名其他女性角色，和你各摸1张牌并翻面。",
  ["#n_cc_gongzhen"] = "共枕: 与一名女性角色各摸一张并翻面",
}

dianlun:addEffect(fk.AfterCardsMove, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    if player.phase == Player.Draw or not player:hasSkill(dianlun.name) then return end
    if player:usedSkillTimes(dianlun.name, Player.HistoryTurn) > 0 then return end
    local room = player.room
    for _, move in ipairs(data) do
      if move.to == player and move.toArea == Card.PlayerHand then
        for _, info in ipairs(move.moveInfo) do
          local id = info.cardId
          if room:getCardArea(id) == Card.PlayerHand and room:getCardOwner(id) == player then
            return true
          end
        end
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if player:isAllNude() then return end
    room:askToDiscard(player, {
      min_num = 1,
      max_num = 1,
      include_equip = true,
      skill_name = dianlun.name,
      cancelable = false,
      prompt = "#n_dianlun_start"
    })
    local classic = {
      'n_cc_lunying',
      'n_cc_gexu',
      'n_cc_duoqi',
      'n_cc_sanxiao',
      'n_cc_jiamei',
      'n_cc_gongzhen',
    }
    local female = table.filter(room:getOtherPlayers(player, false), function(p)
      return p:isFemale()
    end)
    if #female == 0 then
      table.removeOne(classic, 'n_cc_gongzhen')
      table.removeOne(classic, 'n_cc_duoqi')
    end
    if player:getMark('n_cc_duoqi') ~= 0 then
      table.removeOne(classic, 'n_cc_duoqi')
    end
    if #player:getCardIds('e') == 0 or not player:isWounded() then
      table.removeOne(classic, 'n_cc_gexu')
    end
    room:notifySkillInvoked(player, dianlun.name, 'special')
    local choices = table.random(classic, 2)
    local choice = room:askToChoice(player, {
      choices = choices,
      skill_name = dianlun.name,
      detailed = true
    })
    if choice == 'n_cc_lunying' then
      local to = room:askToChoosePlayers(player, {
        targets = room:getOtherPlayers(player, false),
        min_num = 1,
        max_num = 1,
        prompt = "#n_cc_lunying",
        skill_name = dianlun.name,
        cancelable = false
      })[1]
      local tgt = to
      player:broadcastSkillInvoke(dianlun.name, 1)
      room:notifySkillInvoked(player, 'n_cc_lunying', 'special', { to })
      while true do
        if player.dead then break end
        if tgt.dead then break end
        local judge = {
          who = player,
          reason = dianlun.name,
          pattern = ".|2~9|spade",
        }
        room:judge(judge)
        local result = judge.card
        if result.suit == Card.Spade and result.number >= 2 and result.number <= 9 then
          room:damage {
            to = judge.who,
            damage = 3,
            damageType = fk.ThunderDamage,
            skillName = dianlun.name,
          }
          break
        end

        if room:askToSkillInvoke(tgt, {
              skill_name = 'n_cc_lunying',
              prompt = '#n_cc_lunying_cancel'
            }) then
          room:damage { from = tgt, to = tgt, damage = 1, damageType = fk.ThunderDamage }
          break
        end
        judge = {
          who = tgt,
          reason = dianlun.name,
          pattern = ".|2~9|spade",
        }
        room:judge(judge)
        result = judge.card
        if result.suit == Card.Spade and result.number >= 2 and result.number <= 9 then
          room:damage {
            to = judge.who,
            damage = 3,
            damageType = fk.ThunderDamage,
            skillName = dianlun.name,
          }
          break
        end
      end
    elseif choice == 'n_cc_gexu' then
      room:askToDiscard(player, {
        min_num = 1,
        max_num = 1,
        include_equip = true,
        skill_name = dianlun.name,
        cancelable = false,
        pattern = '.|.|.|equip',
        prompt = "#n_cc_gexu",
      })
      player:broadcastSkillInvoke(dianlun.name, 2)
      room:notifySkillInvoked(player, 'n_cc_gexu', 'support')
      room:recover { num = 1, skillName = dianlun.name, who = player }
    elseif choice == 'n_cc_duoqi' then
      local to = room:askToChoosePlayers(player, {
        targets = female,
        min_num = 1,
        max_num = 1,
        prompt = "#n_cc_duoqi",
        skill_name = dianlun.name,
        cancelable = false
      })[1]
      local tgt = to
      player:broadcastSkillInvoke(dianlun.name, 3)
      room:notifySkillInvoked(player, 'n_cc_duoqi', 'control', { to })
      local skills = Fk.generals[tgt.general]:getSkillNameList()
      if Fk.generals[tgt.deputyGeneral] and Fk.generals[tgt.deputyGeneral].gender == General.Female then
        table.insertTableIfNeed(skills, Fk.generals[tgt.deputyGeneral]:getSkillNameList())
      end
      skills = table.filter(skills, function(skill_name)
        local skill = Fk.skills[skill_name]
        return not player:hasSkill(skill, true) and
            (#skill:getSkeleton().attached_kingdom == 0 or table.contains(skill:getSkeleton().attached_kingdom, player.kingdom))
      end)
      if #skills > 0 then
        room:setPlayerMark(player, 'n_cc_duoqi', 1)
        local c = room:askToChoice(player, {
          choices = skills,
          skill_name = dianlun.name,
          prompt = "#n_cc_duoqi-choice::" .. tgt.id,
          detailed = true,
        })
        room:handleAddLoseSkills(player, c, nil, true, true)
      end
    elseif choice == 'n_cc_sanxiao' then
      local to = room:askToChoosePlayers(player, {
        targets = room:getOtherPlayers(player, false),
        min_num = 1,
        max_num = 1,
        prompt = "#n_cc_sanxiao",
        skill_name = dianlun.name,
        cancelable = false
      })[1]
      local tgt = to
      player:broadcastSkillInvoke(dianlun.name, 4)
      room:notifySkillInvoked(player, 'n_cc_sanxiao', 'masochism', { to })
      local use = room:askToUseCard(tgt, {
        pattern = "slash",
        prompt = "#n_cc_sanxiao-use:" .. player.id,
        cancelable = true,
        extra_data = {
          must_targets = { player.id },
          bypass_distances = true,
        },
        skill_name = dianlun.name
      })
      if use then room:useCard(use) end
      if (not use) or (not use.damageDealt) or (not use.damageDealt[player]) then
        room:addPlayerMark(tgt, MarkEnum.UncompulsoryInvalidity .. "-turn")
        room:setPlayerMark(tgt, "@@n_cc_sanxiao-turn", 1)
      end
    elseif choice == 'n_cc_jiamei' then
      local to = room:askToChoosePlayers(player, {
        targets = room:getOtherPlayers(player, false),
        min_num = 1,
        max_num = 1,
        prompt = "#n_cc_jiamei",
        skill_name = dianlun.name,
        cancelable = false
      })[1]
      local tgt = to
      player:broadcastSkillInvoke(dianlun.name, 5)
      room:notifySkillInvoked(player, 'n_cc_jiamei', 'offensive', { to })
      tgt:drawCards(1, dianlun.name)
      room:useVirtualCard('slash', nil, player, tgt, dianlun.name, true)
    elseif choice == 'n_cc_gongzhen' then
      local to = room:askToChoosePlayers(player, {
        targets = female,
        min_num = 1,
        max_num = 1,
        prompt = "#n_cc_gongzhen",
        skill_name = dianlun.name,
        cancelable = false
      })[1]
      local tgt = to
      player:broadcastSkillInvoke(dianlun.name, 6)
      room:notifySkillInvoked(player, 'n_cc_gongzhen', 'control', { to })
      player:drawCards(1, dianlun.name)
      if not tgt.dead then
        tgt:drawCards(1, dianlun.name)
      end
      player:turnOver()
      tgt:turnOver()
    end
  end,
})

return dianlun
