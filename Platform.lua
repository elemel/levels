local utils = require("utils")

local Platform = utils.newClass()

function Platform:init(game, config)
  self.game = assert(game)
  self.id = self.game:generateId()
  self.game.platforms[self.id] = self
  self.boxSystem = assert(self.game.systems.box)
  self.x1 = assert(config.x1)
  self.y1 = assert(config.y1)
  self.x2 = assert(config.x2)
  self.y2 = assert(config.y2)
  self.period = config.period or 1
  self.phase = config.phase or 0
  local x, y = self:getTargetPosition(self.game.fixedTime, 0, 0)
  local width = config.width or 1
  local height = config.height or 1
  local velocityX = config.velocityX or 0
  local velocityY = config.velocityY or 0
  self.boxSystem:createBox(self.id, x, y, width, height, velocityX, velocityY)
end

function Platform:destroy()
  self.boxSystem:destroyBox(self.id)
  self.game.platforms[self.id] = nil
end

function Platform:updateVelocity(dt)
  local x, y = self.boxSystem:getPosition(self.id)
  local targetX, targetY = self:getTargetPosition(self.game.fixedTime, x, y)
  local velocityX = (targetX - x) / dt
  local velocityY = (targetY - y) / dt
  self.boxSystem:setVelocity(self.id, velocityX, velocityY)
end

function Platform:getTargetPosition(time, originX, originY)
  local t = 0.5 - 0.5 * math.cos(time * 2 * math.pi / self.period + self.phase)
  local x1, y1 = self:normalizePosition(self.x1, self.y1, originX, originY)
  local x2, y2 = self:normalizePosition(self.x2, self.y2, originX, originY)
  return utils.mix2(x1, y1, x2, y2, t)
end

function Platform:normalizePosition(x, y, originX, originY)
  local worldWidth = self.boxSystem.worldWidth
  x = originX + (x - originX + 0.5 * worldWidth) % worldWidth - 0.5 * worldWidth
  return x, y
end

function Platform:getPosition()
  return self.boxSystem:getPosition(self.id)
end

function Platform:draw()
  self.game:drawImage("resources/images/platform.png", self:getPosition())
end

return Platform
