local n_jiequanisbest = fk.CreateSkill {
  name = "n_jiequanisbest",
}

n_jiequanisbest:addEffect(fk.GameStart,{
  mute=true
})



return n_jiequanisbest