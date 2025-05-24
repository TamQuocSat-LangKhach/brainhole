local n_jiequanisbest = fk.CreateSkill {
  name = "n_jiequanisbest",
}

Fk:loadTranslationTable{
  ["n_jiequanisbest"] = "信界权得永生",
  [":n_jiequanisbest"] = "你发动“会玩”后，可以获胜。",
}

n_jiequanisbest:addEffect("visibility", {})

return n_jiequanisbest