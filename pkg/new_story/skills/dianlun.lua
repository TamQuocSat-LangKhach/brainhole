local dianlun = fk.CreateSkill {

  name = "n_dianlun",

  tags = { Skill.Compulsory, },

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
