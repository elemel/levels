local utils = require("utils")

local abs = math.abs
local assert = assert
local clamp = utils.clamp
local require = require

local MonsterStandState = utils.newClass()

function MonsterStandState:init(monster)
  self.monster = assert(monster)

  self.monster.game.systems.box:setDimensions(
    monster.id, monster.stats.standWidth, monster.stats.standHeight)
end

function MonsterStandState:updateTransition(dt)
  self.monster:updateWalls()

  if not self.monster.walls.down then
    local MonsterFallState = require("MonsterFallState")
    self.monster.state = MonsterFallState.new(self.monster)
    return
  end

  if self.monster.inputs.y > 0.5 then
    local MonsterCrouchFallState = require("MonsterCrouchFallState")
    self.monster.state = MonsterCrouchFallState.new(self.monster)
    return
  end

  if abs(self.monster.inputs.x) > 0.5 then
    local MonsterWalkState = require("MonsterWalkState")
    self.monster.state = MonsterWalkState.new(self.monster)
    return
  end

  if self.monster.inputs.jump and not self.monster.inputs.oldJump then
    local boxSystem = self.monster.game.systems.box
    local velocityX, velocityY = boxSystem:getVelocity(self.monster.id)

    local wallVelocityX, wallVelocityY =
      boxSystem:getVelocity(self.monster.walls.down)

    boxSystem:setVelocity(
      self.monster.id, velocityX, wallVelocityY - self.monster.stats.jumpSpeed)

    local MonsterFallState = require("MonsterFallState")
    self.monster.state = MonsterFallState.new(self.monster)
  end
end

function MonsterStandState:updateVelocity(dt)
  local monster = self.monster
  local stats = monster.stats
  local boxSystem = monster.game.systems.box
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

function MonsterStandState:updateCollision(dt)
  self.monster:resolveWallCollisions()
  self.monster:updateDirection()
end

function MonsterStandState:draw()
  self.monster:drawSkin("stand")
end

return MonsterStandState
