local utils = require("utils")

local Camera = utils.newClass()

function Camera:init(config)
  self.x = config.x or 0
  self.y = config.y or 0
  self.angle = config.angle or 0
  self.scale = config.scale or 1
  self.lineWidth = 1
  self.viewportX = config.viewportX or 0
  self.viewportY = config.viewportY or 0
  self.viewportWidth = config.viewportWidth or 800
  self.viewportHeight = config.viewportHeight or 600
  self.transform = love.math.newTransform()
  self:update()
end

function Camera:getPosition()
  return self.x, self.y
end

function Camera:setPosition(x, y)
  self.x = assert(x)
  self.y = assert(y)
  self:update()
end

function Camera:getAngle()
  return self.angle
end

function Camera:setAngle(angle)
  self.angle = assert(angle)
  self:update()
end

function Camera:getTransform()
  return self.transform
end

function Camera:getLineWidth()
  return self.lineWidth
end

function Camera:getViewport()
  return self.viewportX, self.viewportY, self.viewportWidth, self.viewportHeight
end

function Camera:setViewport(x, y, width, height)
  self.viewportX = assert(x)
  self.viewportY = assert(y)
  self.viewportWidth = assert(width)
  self.viewportHeight = assert(height)
  self:update()
end

function Camera:update()
  self.transform:reset()

  self.transform:translate(
    self.viewportX + 0.5 * self.viewportWidth,
    self.viewportY + 0.5 * self.viewportHeight)

  local scale = self.viewportWidth * self.scale
  self.transform:scale(scale)
  self.transform:translate(-self.x, -self.y)
  self.transform:rotate(-self.angle)
  self.lineWidth = 1 / scale
end

return Camera
