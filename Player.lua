local Monster = require("Monster")
local utils = require("utils")

local Player = utils.newClass()

function Player:init(game, config)
  self.game = assert(game)
  self.id = self.game:generateId()
  self.game.players[self.id] = self
  self.maxCameraDistance = config.maxCameraDistance or 1
  self.maxHealth = config.maxHealth or 3

  self.oldInputs = {
    up = false,
    left = false,
    right = false,
    down = false,
  }

  self.inputs = {
    up = false,
    left = false,
    right = false,
    down = false,
  }

  self.inputs.up = love.keyboard.isDown("up") or love.keyboard.isDown("w") or love.keyboard.isDown("space")
  self.inputs.left = love.keyboard.isDown("left") or love.keyboard.isDown("a")
  self.inputs.right = love.keyboard.isDown("right") or love.keyboard.isDown("d")
  self.inputs.down = love.keyboard.isDown("down") or love.keyboard.isDown("s")

  self.oldInputs.up = self.inputs.up
  self.oldInputs.left = self.inputs.left
  self.oldInputs.right = self.inputs.right
  self.oldInputs.down = self.inputs.down

  self.spawnDelay = 0
  self.maxSpawnDelay = 1
end

function Player:updateInput(dt)
  local monster = self.monsterId and self.game.monsters[self.monsterId]

  self.oldInputs.up = self.inputs.up
  self.oldInputs.left = self.inputs.left
  self.oldInputs.right = self.inputs.right
  self.oldInputs.down = self.inputs.down

  self.inputs.up = love.keyboard.isDown("up") or love.keyboard.isDown("w") or love.keyboard.isDown("space")
  self.inputs.left = love.keyboard.isDown("left") or love.keyboard.isDown("a")
  self.inputs.right = love.keyboard.isDown("right") or love.keyboard.isDown("d")
  self.inputs.down = love.keyboard.isDown("down") or love.keyboard.isDown("s")

  for input, active in pairs(self.inputs) do
    local oldActive = self.oldInputs[input]

    if active and not oldActive then
      local commandIndex = math.floor(self.game.commandPosition + 0.5)
      local command = nil

      if math.abs(commandIndex - self.game.commandPosition) < 0.25 then
        command = self.game.commandQueue[commandIndex]
      end

      if command == input then
        self.game.commandQueue[commandIndex] = nil

        if monster and monster.stats.health < monster.stats.maxHealth then
          monster.stats.health = monster.stats.health + 1
        end
      else
        self.game:playSound("resources/sounds/miss.ogg")

        if monster and monster.stats.health >= 1 then
          monster.stats.health = monster.stats.health - 1
        end
      end
    end
  end

  if monster then
    monster.oldInputs.x = monster.inputs.x
    monster.oldInputs.y = monster.inputs.y

    monster.inputs.x =
      (self.inputs.right and 1 or 0) - (self.inputs.left and 1 or 0)

    monster.inputs.y =
      (self.inputs.down and 1 or 0) - (self.inputs.up and 1 or 0)
  end
end

function Player:updateSpawn(dt)
  local monster = self.monsterId and self.game.monsters[self.monsterId]

  if not monster or monster.dead then
    self.spawnDelay = self.spawnDelay - dt

    if self.spawnDelay < 0 then
      self.spawnDelay = self.maxSpawnDelay

      local door = self:getDoor(false)
      local x1, y1, x2, y2 = self.game.systems.box:getBounds(door.id)
      local x = 0.5 * (x1 + x2)

      local monster = Monster.new(self.game, {
        x = x,
        y = y2 - 0.5 * 1.75,
        width = 0.75,
        height = 1.75,
        alignment = "good",
        maxHealth = self.maxHealth,
      })

      self.monsterId = monster.id
      self.game:initCommands()
    end
  end
end

function Player:updateComplete(dt)
  local monster = self.monsterId and self.game.monsters[self.monsterId]

  if monster and not monster.dead then
    local door = self:getDoor(true)

    local x1, y1, x2, y2 = self.game.systems.box:getBounds(monster.id)
    local x3, y3, x4, y4 = self.game.systems.box:getBounds(door.id)
    local x5, y5, x6, y6 = utils.boxesIntersection(x1, y1, x2, y2, x3, y3, x4, y4)

    if x5 < x6 and y5 < y6 and (x6 - x5) * (y6 - y5) > 0.5 * (x2 - x1) * (y2 - y1) then
      self.game.complete = true
    end
  end
end

function Player:getDoor(open)
  for doorId, door in pairs(self.game.doors) do
    if door.open == open then
      return door
    end
  end

  return nil
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
