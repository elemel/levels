local utils = require("utils")

local assert = assert
local clamp = utils.clamp

local MonsterCrouchFallState = utils.newClass()

function MonsterCrouchFallState:init(monster)
  self.monster = assert(monster)

  self.monster.game.systems.box:setDimensions(
    monster.id, monster.stats.crouchWidth, monster.stats.crouchHeight)
end

function MonsterCrouchFallState:updateTransition(dt)
  if self.monster.stats.health <= 0 then
    local MonsterDeadState = require("MonsterDeadState")
    self.monster.state = MonsterDeadState.new(self.monster)
    return
  end

  self.monster:updateWalls()

  if self.monster.walls.down then
    self.monster.game:playSound("resources/sounds/crouch.ogg")
    local MonsterCrouchState = require("MonsterCrouchState")
    self.monster.state = MonsterCrouchState.new(self.monster)
    return
  end

  if self.monster.inputs.y < 0.5 then
    local MonsterCrouchFallState = require("MonsterFallState")
    self.monster.state = MonsterCrouchFallState.new(self.monster)
    return
  end
end

function MonsterCrouchFallState:updateVelocity(dt)
  local monster = self.monster
  local stats = monster.stats
  local boxSystem = assert(monster.game.systems.box)
  local velocityX, velocityY = boxSystem:getVelocity(monster.id)

  local targetVelocityX =
    velocityX + monster.inputs.x * monster.stats.airControlSpeed

  targetVelocityX =
    clamp(
      targetVelocityX,
      -monster.stats.airControlSpeed,
      monster.stats.airControlSpeed)

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

function MonsterCrouchFallState:updateCollision(dt)
  self.monster:resolveWallCollisions()
  self.monster:updateDirection()
end

function MonsterCrouchFallState:draw()
  self.monster:drawSkin("crouch")
end

return MonsterCrouchFallState
