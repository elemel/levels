local MonsterWalkState = require("MonsterWalkState")
local utils = require("utils")

local abs = math.abs
local assert = assert
local min = math.min
local max = math.max

local Monster = utils.newClass()

function Monster:init(game, config)
  self.game = assert(game)
  self.id = self.game:generateId()
  self.game.monsters[self.id] = self
  local x = config.x or 0
  local y = config.y or 0
  local width = config.width or 1
  local height = config.height or 1
  self.game.systems.box:createBox(self.id, x, y, width, height)
  self.inputs = {}
  self.inputs.x = 0
  self.inputs.y = 0
  self.oldInputs = {}
  self.oldInputs.x = 0
  self.oldInputs.y = 0
  self.stats = {}
  self.stats.walkAcceleration = 20
  self.stats.walkSpeed = 5
  self.stats.fallAcceleration = 20
  self.stats.fallSpeed = 20
  self.stats.airControlAcceleration = 5
  self.stats.airControlSpeed = 5
  self.stats.jumpSpeed = 10
  self.stats.crouchWidth = config.crouchWidth or 0.75
  self.stats.crouchHeight = config.crouchHeight or 1.25
  self.stats.standWidth = config.standWidth or 0.75
  self.stats.standHeight = config.standHeight or 1.75
  self.stats.maxHealth = config.maxHealth or 3
  self.stats.health = config.health or self.stats.maxHealth
  self.state = MonsterWalkState.new(self)
  self.wallCollisions = {}
  self.walls = {}
  self.alignment = config.alignment or "evil"
  self.dead = false
  self.skin = config.skin or "hero"
  self.direction = config.direction or 1
end

function Monster:destroy()
  self.game.systems.box:destroyBox(self.id)
  self.game.monsters[self.id] = nil
end

function Monster:updateTransition(dt)
  self.state:updateTransition(dt)
end

function Monster:updateVelocity(dt)
  self.state:updateVelocity(dt)
end

function Monster:updateCollision(dt)
  self.state:updateCollision(dt)
end

function Monster:updateWalls()
  local abs = abs

  self.walls.up = nil
  self.walls.left = nil
  self.walls.down = nil
  self.walls.right = nil

  local boxSystem = self.game.systems.box
  local walls = game.walls
  local platforms = game.platforms
  local x, y = boxSystem:getPosition(self.id)
  local x1, y1, x2, y2 = boxSystem:getBounds(self.id)

  local function callback(otherId)
    if walls[otherId] or platforms[otherId] then
      local x3, y3, x4, y4 = boxSystem:getNearestBounds(otherId, x, y)

      local distance, normalX, normalY =
        utils.maxDistanceBox(x1, y1, x2, y2, x3, y3, x4, y4)

      if abs(normalX) > abs(normalY) then
        if normalX < 0 then
          self.walls.left = otherId
        else
          self.walls.right = otherId
        end
      else
        if normalY < 0 then
          self.walls.up = otherId
        else
          self.walls.down = otherId
        end
      end
    end
  end

  boxSystem:query(x1 - 0.001, y1 - 0.001, x2 + 0.001, y2 + 0.001, callback)
end

function Monster:resolveWallCollisions()
  for i = 1, 4 do
    self:resolveWallCollision()
  end
end

function Monster:resolveWallCollision()
  local id = self.id
  local game = self.game
  local max = max
  local min = min
  local boxSystem = game.systems.box
  local walls = game.walls
  local platforms = game.platforms
  local x, y = boxSystem:getPosition(id)
  local x1, y1, x2, y2 = boxSystem:getBounds(id)
  local wallId = nil
  local maxArea = 0

  local function callback(otherId)
    if walls[otherId] or platforms[otherId] then
      local x3, y3, x4, y4 = boxSystem:getNearestBounds(otherId, x, y)

      if x1 < x4 and x3 < x2 and y1 < y4 and y3 < y2 then
        local x5 = max(x1, x3)
        local y5 = max(y1, y3)
        local x6 = min(x2, x4)
        local y6 = min(y2, y4)
        local area = (x6 - x5) * (y6 - y5)

        if area > maxArea then
          wallId = otherId
          maxArea = area
        end
      end
    end
  end

  boxSystem:query(x1, y1, x2, y2, callback)

  if wallId then
    local x, y = boxSystem:getPosition(id)
    local x3, y3, x4, y4 = boxSystem:getNearestBounds(wallId, x, y)

    local distance, normalX, normalY =
      utils.maxDistanceBox(x1, y1, x2, y2, x3, y3, x4, y4)

    local velocityX, velocityY = boxSystem:getVelocity(id)
    local wallVelocityX, wallVelocityY = boxSystem:getVelocity(wallId)
    x = x + distance * normalX
    y = y + distance * normalY

    velocityX =
      velocityX - normalX * max(0, (velocityX - wallVelocityX) * normalX)

    velocityY =
      velocityY - normalY * max(0, (velocityY - wallVelocityY) * normalY)

    boxSystem:setPosition(id, x, y)
    boxSystem:setVelocity(id, velocityX, velocityY)    
  end
end

function Monster:updateDirection()
  if math.abs(self.inputs.x) > 0.5 then
    self.direction = (self.inputs.x) < 0 and -1 or 1
  end
end

function Monster:draw()
  self.state:draw()
end

function Monster:getPosition()
  local boxSystem = self.game.systems.box
  return boxSystem:getPosition(self.id)
end

function Monster:drawSkin(frame)
  local filename =
    "resources/images/skins/" .. self.skin .. "/" .. frame .. ".png"

  local x, y = self:getPosition()
  self.game:drawImage(filename, x, y, 0, self.direction)
end

return Monster
