local Monster = require("Monster")
local utils = require("utils")

local Player = utils.newClass()

function Player:init(game, config)
  self.game = assert(game)
  self.id = self.game:generateId()
  self.game.players[self.id] = self
  self.maxCameraDistance = config.maxCameraDistance or 1
end

function Player:updateInput(dt)
  local monster = self.monsterId and self.game.monsters[self.monsterId]

  if monster then
    local up = love.keyboard.isDown("w")
    local left = love.keyboard.isDown("a")
    local down = love.keyboard.isDown("s")
    local right = love.keyboard.isDown("d")
    monster.inputs.x = (right and 1 or 0) - (left and 1 or 0)
    monster.inputs.y = (down and 1 or 0) - (up and 1 or 0)
    monster.inputs.oldJump = monster.inputs.jump
    monster.inputs.jump = love.keyboard.isDown("space")
  end
end

function Player:updateSpawn(dt)
  local monster = self.monsterId and self.game.monsters[self.monsterId]

  if not monster or monster.dead then
    local altarId = next(self.game.altars)
    local x1, y1, x2, y2 = self.game.systems.box:getBounds(altarId)
    local x = 0.5 * (x1 + x2)

    local monster = Monster.new(self.game, {
      x = x,
      y = y2 - 0.5 * 1.75,
      width = 0.75,
      height = 1.75,
      alignment = "good",
    })

    self.monsterId = monster.id
  end
end

function Player:updateCamera(dt)
  local monster = self.monsterId and self.game.monsters[self.monsterId]

  if monster and not monster.dead then
    local cameraX, cameraY = self.game.camera:getPosition()
    local monsterX, monsterY = self.game.systems.box:getPosition(self.monsterId)

    cameraY =
      utils.clamp(
        cameraY,
        monsterY - self.maxCameraDistance,
        monsterY + self.maxCameraDistance)

    self.game.camera:setPosition(cameraX, cameraY)
  end
end

return Player
