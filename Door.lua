local utils = require("utils")

local Door = utils.newClass()

function Door:init(game, config)
  self.game = assert(game)
  self.id = self.game:generateId()
  self.game.doors[self.id] = self
  local x = config.x or 0
  local y = config.y or 0
  local width = config.width or 2
  local height = config.height or 1
  self.open = config.open or false
  self.game.systems.box:createBox(self.id, x, y, width, height)
end

function Door:destroy()
  self.game.systems.box:destroyBox(self.id)
  self.game.doors[self.id] = nil
end

function Door:getPosition()
  local boxSystem = self.game.systems.box
  return boxSystem:getPosition(self.id)
end

function Door:draw()
  local filename =
    self.open and
    "resources/images/openDoor.png" or
    "resources/images/closedDoor.png"

  self.game:drawImage(filename, self:getPosition())
end

return Door
