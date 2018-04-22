local utils = require("utils")

local assert = assert
local clamp = utils.clamp

local MonsterDeadState = utils.newClass()

function MonsterDeadState:init(monster)
  self.monster = assert(monster)
  self.monster.dead = true

  self.monster.game.systems.box:setDimensions(
    monster.id, monster.stats.crouchWidth, monster.stats.crouchHeight)
end

function MonsterDeadState:updateTransition(dt)
  local x1, y1, x2, y2 =
    self.monster.game.systems.box:getBounds(self.monster.id)

  if y1 > 100 then
    self.monster:destroy()
    return
  end
end

function MonsterDeadState:updateVelocity(dt)
  local monster = self.monster
  local stats = monster.stats
  local boxSystem = assert(monster.game.systems.box)
  local velocityX, velocityY = boxSystem:getVelocity(monster.id)

  local targetVelocityY = monster.stats.fallSpeed
  local impulseY = targetVelocityY - velocityY
  local maxImpulseY = stats.fallAcceleration * dt
  impulseY = clamp(impulseY, -maxImpulseY, maxImpulseY)
  velocityY = velocityY + impulseY

  boxSystem:setVelocity(monster.id, velocityX, velocityY)
end

function MonsterDeadState:updateCollision(dt)
end

function MonsterDeadState:draw()
  self.monster:drawSkin("crouch")
end

return MonsterDeadState
