local utils = require("utils")

local Wall = utils.newClass()

function Wall:init(game, config)
  self.game = assert(game)
  self.id = self.game:generateId()
  self.game.walls[self.id] = self
  self.boxSystem = assert(self.game.systems.box)
  local x = config.x or 0
  local y = config.y or 0
  local width = config.width or 1
  local height = config.height or 1
  self.boxSystem:createBox(self.id, x, y, width, height)
  self.imageFilename = config.image
  self.color = config.color
end

function Wall:destroy()
  self.boxSystem:destroyBox(self.id)
  self.game.walls[self.id] = nil
end

function Wall:getPosition()
  return self.boxSystem:getPosition(self.id)
end

function Wall:draw()
  if self.imageFilename then
    self.game:drawImage(self.imageFilename, self:getPosition())
  elseif self.color then
    local x1, y1, x2, y2 = self.boxSystem:getBounds(self.id)
    love.graphics.setColor(self.color)
    love.graphics.rectangle("fill", x1, y1, x2 - x1, y2 - y1)
    love.graphics.setColor(1, 1, 1, 1)
  end
end

return Wall
