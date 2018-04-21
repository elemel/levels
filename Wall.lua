local utils = require("utils")

local Wall = utils.newClass()

function Wall:init(game, config)
  self.game = assert(game)
  self.id = self.game:generateId()
  self.game.walls[self.id] = self
  local x = config.x or 0
  local y = config.y or 0
  local width = config.width or 1
  local height = config.height or 1
  self.game.systems.box:createBox(self.id, x, y, width, height)
end

function Wall:destroy()
  self.game.systems.box:destroyBox(self.id)
  self.game.walls[self.id] = nil
end

return Wall
