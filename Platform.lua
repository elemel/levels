local utils = require("utils")

local Platform = utils.newClass()

function Platform:init(game, config)
  self.game = assert(game)
  self.id = self.game:generateId()
  self.game.platforms[self.id] = self
  local x = config.x or 0
  local y = config.y or 0
  local width = config.width or 1
  local height = config.height or 1
  local velocityX = config.velocityX or 0
  local velocityY = config.velocityY or 0

  self.game.systems.box:createBox(
    self.id, x, y, width, height, velocityX, velocityY)
end

function Platform:destroy()
  self.game.systems.box:destroyBox(self.id)
  self.game.platforms[self.id] = nil
end

return Platform
