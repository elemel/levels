local utils = require("utils")

local assert = assert
local clamp = utils.clamp

local MonsterFallState = utils.newClass()

function MonsterFallState:init(monster)
  self.monster = assert(monster)

  self.monster.game.systems.box:setDimensions(
    monster.id, monster.stats.crouchWidth, monster.stats.crouchHeight)
end

function MonsterFallState:updateTransition(dt)
  self.monster:updateWalls()

  if self.monster.walls.down then
    local MonsterCrouchState = require("MonsterCrouchState")
    self.monster.state = MonsterCrouchState.new(self.monster)
    return
  end
end

function MonsterFallState:updateVelocity(dt)
  local monster = self.monster
  local stats = monster.stats
  local boxSystem = assert(monster.game.systems.box)
  local velocityX, velocityY = boxSystem:getVelocity(monster.id)

  local targetVelocityX = velocityX + monster.inputs.x * monster.stats.airControlSpeed
  targetVelocityX = clamp(targetVelocityX, -monster.stats.airControlSpeed, monster.stats.airControlSpeed)
  local impulseX = targetVelocityX - velocityX
  local maxImpulseX = stats.airControlAcceleration * dt
  impulseX = clamp(impulseX, -maxImpulseX, maxImpulseX)
  velocityX = velocityX + impulseX

  local targetVelocityY = monster.stats.fallSpeed
  local impulseY = targetVelocityY - velocityY
  local maxImpulseY = stats.fallAcceleration * dt
  impulseY = clamp(impulseY, -maxImpulseY, maxImpulseY)
  velocityY = velocityY + impulseY

  boxSystem:setVelocity(monster.id, velocityX, velocityY)
end

function MonsterFallState:updateCollision(dt)
  self.monster:resolveWallCollisions()
end

return MonsterFallState
