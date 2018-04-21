local utils = require("utils")

local Altar = utils.newClass()

function Altar:init(game, config)
  self.game = assert(game)
  self.id = self.game:generateId()
  self.game.altars[self.id] = self
  local x = config.x or 0
  local y = config.y or 0
  local width = config.width or 2
  local height = config.height or 1
  self.game.systems.box:createBox(self.id, x, y, width, height)
end

function Altar:destroy()
  self.game.systems.box:destroyBox(self.id)
  self.game.altars[self.id] = nil
end

return Altar
