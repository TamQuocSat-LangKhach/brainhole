local brainhole = require 'packages.brainhole.pkg.brainhole'
local new_story = require 'packages.brainhole.pkg.new_story'
local brainhole_cards = require 'packages.brainhole.pkg.brainhole_cards'

--local extension = Package:new("gamemode", Package.SpecialPack)

--extension:loadSkillSkelsByPath("./packages/brainhole/pkg/gamemodes/rule_skills")

--extension:addGameMode(require("packages/brainhole/pkg/brainhole/melee"))
--extension:addGameMode(require("packages/brainhole/pkg/brainhole/samemode"))

return {
  --extension,

  brainhole,
  new_story,
  brainhole_cards,
}
