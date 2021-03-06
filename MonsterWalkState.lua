local utils = require("utils")

local abs = math.abs
local assert = assert
local clamp = utils.clamp
local require = require

local MonsterWalkState = utils.newClass()

function MonsterWalkState:init(monster)
  self.monster = assert(monster)

  self.monster.game.systems.box:setDimensions(
    monster.id, monster.stats.standWidth, monster.stats.standHeight)
end

function MonsterWalkState:updateTransition(dt)
  if self.monster.stats.health <= 0 then
    local MonsterDeadState = require("MonsterDeadState")
    self.monster.state = MonsterDeadState.new(self.monster)
    return
  end

  self.monster:updateWalls()

  if not self.monster.walls.down then
    local MonsterFallState = require("MonsterFallState")
    self.monster.state = MonsterFallState.new(self.monster)
    return
  end

  if self.monster.inputs.y > 0.5 then
    local MonsterFallState = require("MonsterCrouchFallState")
    self.monster.state = MonsterFallState.new(self.monster)
    return
  end

  if abs(self.monster.inputs.x) < 0.5 then
    local MonsterStandState = require("MonsterStandState")
    self.monster.state = MonsterStandState.new(self.monster)
    return
  end

  if self.monster.inputs.y < -0.5 and self.monster.oldInputs.y > -0.5 then
    self.monster.game:playSound("resources/sounds/jump.ogg")
    local boxSystem = assert(self.monster.game.systems.box)
    local velocityX, velocityY = boxSystem:getVelocity(self.monster.id)

    local wallVelocityX, wallVelocityY =
      boxSystem:getVelocity(self.monster.walls.down)

    boxSystem:setVelocity(
      self.monster.id, velocityX, wallVelocityY - self.monster.stats.jumpSpeed)

    local MonsterFallState = require("MonsterFallState")
    self.monster.state = MonsterFallState.new(self.monster)
  end
end

function MonsterWalkState:updateVelocity(dt)
  local monster = self.monster
  local stats = monster.stats
  local boxSystem = assert(monster.game.systems.box)
  local velocityX, velocityY = boxSystem:getVelocity(monster.id)

  local wallVelocityX, wallVelocityY =
    boxSystem:getVelocity(self.monster.walls.down)

  local targetVelocityX =
    wallVelocityX + monster.inputs.x * monster.stats.walkSpeed

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

function MonsterWalkState:updateCollision(dt)
  self.monster:resolveWallCollisions()
  self.monster:updateDirection()
end

function MonsterWalkState:draw()
  self.monster:drawSkin("stand")
end

return MonsterWalkState
