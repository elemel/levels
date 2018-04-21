local utils = require("utils")

local BoxSystem = utils.newClass()

function BoxSystem:init(game, config)
  self.worldWidth = config.worldWidth or 16
  self.xs = {}
  self.ys = {}
  self.widths = {}
  self.heights = {}
  self.velocityXs = {}
  self.velocityYs = {}
  self.movingBoxes = {}
end

function BoxSystem:createBox(id, x, y, width, height, velocityX, velocityY)
  assert(not self.xs[id])
  x = x or 0
  y = y or 0
  x, y = self:normalizePosition(x, y)
  self.xs[id] = x or 0
  self.ys[id] = y or 0
  self.widths[id] = width or 1
  self.heights[id] = height or 1
  self.velocityXs[id] = velocityX or 0
  self.velocityYs[id] = velocityY or 0

  if velocityX ~= 0 or velocityY ~= 0 then
    self.movingBoxes[id] = true
  end
end

function BoxSystem:destroyBox(id)
  assert(self.xs[id])
  self.xs[id] = nil
  self.ys[id] = nil
  self.widths[id] = nil
  self.heights[id] = nil
  self.velocityXs[id] = nil
  self.velocityYs[id] = nil
  self.movingBoxes[id] = nil
end

function BoxSystem:getPosition(id)
  return self.xs[id], self.ys[id]
end

function BoxSystem:getNearestPosition(id, targetX, targetY)
  local x = self.xs[id]
  local y = self.ys[id]

  if x < targetX then
    if math.abs(x + self.worldWidth - targetX) < math.abs(x - targetX) then
      x = x + self.worldWidth
    end
  else
    if math.abs(x - self.worldWidth - targetX) < math.abs(x - targetX) then
      x = x - self.worldWidth
    end
  end

  return x, y
end

function BoxSystem:setPosition(id, x, y)
  x, y = self:normalizePosition(x, y)
  self.xs[id] = assert(x)
  self.ys[id] = assert(y)
end

function BoxSystem:normalizePosition(x, y)
  local worldWidth = self.worldWidth
  x = (x + 0.5 * worldWidth) % worldWidth - 0.5 * worldWidth
  return x, y
end

function BoxSystem:getDimensions(id)
  return self.widths[id], self.heights[id]
end

function BoxSystem:setDimensions(id, width, height)
  self.widths[id] = assert(width)
  self.heights[id] = assert(height)
end

function BoxSystem:getVelocity(id)
  return self.velocityXs[id], self.velocityYs[id]
end

function BoxSystem:setVelocity(id, velocityX, velocityY)
  self.velocityXs[id] = assert(velocityX)
  self.velocityYs[id] = assert(velocityY)

  if velocityX ~= 0 or velocityY ~= 0 then
    self.movingBoxes[id] = true
  else
    self.movingBoxes[id] = nil
  end
end

function BoxSystem:getBounds(id)
  local x = self.xs[id]
  local y = self.ys[id]
  local width = self.widths[id]
  local height = self.heights[id]

  return x - 0.5 * width, y - 0.5 * height, x + 0.5 * width, y + 0.5 * height
end

function BoxSystem:getNearestBounds(id, targetX, targetY)
  local x, y = self:getNearestPosition(id, targetX, targetY)
  local width = self.widths[id]
  local height = self.heights[id]
  return x - 0.5 * width, y - 0.5 * height, x + 0.5 * width, y + 0.5 * height
end

-- TODO: Optimize
function BoxSystem:query(x1, y1, x2, y2, callback)
  local targetX = 0.5 * (x1 + x2)
  local targetY = 0.5 * (y1 + y2)

  for id in pairs(self.xs) do
    local x3, y3, x4, y4 = self:getNearestBounds(id, targetX, targetY)

    if utils.boxesIntersect(x1, y1, x2, y2, x3, y3, x4, y4) then
      callback(id)
    end
  end
end

function BoxSystem:updatePositions(dt)
  local xs = self.xs
  local ys = self.ys
  local velocityXs = self.velocityXs
  local velocityYs = self.velocityYs
  local worldWidth = self.worldWidth

  for id in pairs(self.movingBoxes) do
    local x = xs[id] + velocityXs[id] * dt
    x = (x + 0.5 * worldWidth) % worldWidth - 0.5 * worldWidth
    xs[id] = x
    ys[id] = ys[id] + velocityYs[id] * dt
  end
end

function BoxSystem:drawDebug()
  local worldWidth = self.worldWidth
  local xs = self.xs
  local ys = self.ys
  local widths = self.widths
  local heights = self.heights

  for id, x in pairs(xs) do
    local y = ys[id]
    local width = widths[id]
    local height = heights[id]

    love.graphics.rectangle(
      "line", x - 0.5 * width - worldWidth, y - 0.5 * height, width, height)

    love.graphics.rectangle(
      "line", x - 0.5 * width, y - 0.5 * height, width, height)

    love.graphics.rectangle(
      "line", x - 0.5 * width + worldWidth, y - 0.5 * height, width, height)
  end
end

return BoxSystem
