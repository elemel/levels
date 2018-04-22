local utils = require("utils")

local assert = assert
local clamp = utils.clamp

local MonsterCrouchState = utils.newClass()

function MonsterCrouchState:init(monster)
  self.monster = assert(monster)

  self.monster.game.systems.box:setDimensions(
    monster.id, monster.stats.crouchWidth, monster.stats.crouchHeight)
end

function MonsterCrouchState:updateTransition(dt)
  self.monster:updateWalls()

  if not self.monster.walls.down then
    local MonsterFallState = require("MonsterFallState")
    self.monster.state = MonsterFallState.new(self.monster)
    return
  end

  if self.monster.inputs.y < 0.5 then
    local MonsterStandState = require("MonsterStandState")
    self.monster.state = MonsterStandState.new(self.monster)
    return
  end
end

function MonsterCrouchState:updateVelocity(dt)
  local monster = self.monster
  local stats = monster.stats
  local boxSystem = assert(monster.game.systems.box)
  local velocityX, velocityY = boxSystem:getVelocity(monster.id)

  local wallVelocityX, wallVelocityY =
    boxSystem:getVelocity(self.monster.walls.down)

  local targetVelocityX = wallVelocityX
  local impulseX = targetVelocityX - velocityX
  local maxImpulseX = stats.walkAcceleration * dt
  impulseX = clamp(impulseX, -maxImpulseX, maxImpulseX)
  velocityX = velocityX + impulseX

  local targetVelocityY = wallVelocityY
  local impulseY = targetVelocityY - velocityY
  local maxImpulseY = stats.fallAcceleration * dt
  impulseY = clamp(impulseY, -maxImpulseY, maxImpulseY)
  velocityY = velocityY + impulseY

  boxSystem:setVelocity(monster.id, velocityX, velocityY)
end

function MonsterCrouchState:updateCollision(dt)
  self.monster:resolveWallCollisions()
  self.monster:updateDirection()
end

function MonsterCrouchState:draw()
  self.monster:drawSkin("crouch")
end

return MonsterCrouchState
