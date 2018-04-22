local BoxSystem = require("BoxSystem")
local Camera = require("Camera")
local Door = require("Door")
local Platform = require("Platform")
local Player = require("Player")
local utils = require("utils")
local Wall = require("Wall")

local Game = utils.newClass()

function Game:init(config)
  self.frame = 0
  self.time = 0
  self.accumulatedDt = 0
  self.fixedFrame = 0
  self.fixedTime = 0
  self.fixedDt = config.fixedDt or 1 / 60
  self.maxId = 0
  self.camera = Camera.new({scale = 1 / 16})
  self.systems = {}
  self.systems.box = BoxSystem.new(self, {})
  self.walls = {}
  self.platforms = {}
  self.doors = {}
  self.players = {}
  self.monsters = {}
  self.images = {}
  self.sounds = {}
  self.texelScale = config.texelScale or 1 / 16
  self:initCommands()
  self.commandSpeed = 1
  self.commandCount = 100
  self.complete = false

  self.commandLayout = {
    up = 1,
    left = 2,
    right = 3,
    down = 4,
  }

  self.commands = {"up", "left", "right", "down"}

  self.level = config.level or 1

  if self.level == 1 then
    self:initLevel1()
  elseif self.level == 2 then
    self:initLevel2()
  elseif self.level == 3 then
    self:initLevel3()
  else
    self:initLevel1()
  end
end

function Game:initCommands()
  self.commandQueue = {minIndex = 1, maxIndex = 0}
  self.commandPosition = -2
end

function Game:initLevel1()
  local wall = Wall.new(self, {
    width = 16,
    height = 0.5,
    y = 1.25,
    color = {0.2, 0.4, 0.4, 1},
  })

  local door = Door.new(self, {x = -4})
  local door = Door.new(self, {x = 4, open = true})

  self.commandSequence = {
    "right",
    false,
  }

  local player = Player.new(self, {
    maxHealth = 1,
  })
end

function Game:initLevel2()
  local wall = Wall.new(self, {
    width = 16,
    height = 0.5,
    y = 1.25,
    color = {0.2, 0.4, 0.4, 1},
  })

  local door = Door.new(self, {x = -4})
  local door = Door.new(self, {x = 4, open = true})

  self.commandSequence = {
    "left",
    false,
  }

  local player = Player.new(self, {
    maxHealth = 1,
  })
end

function Game:initLevel3()
  local wall = Wall.new(self, {
    width = 16,
    height = 0.5,
    y = 1.25,
    color = {0.2, 0.4, 0.4, 1},
  })

  local wall = Wall.new(self, {
    width = 0.5,
    height = 6,
    y = -2,
    color = {0.2, 0.4, 0.4, 1},
  })

  local wall = Wall.new(self, {
    width = 8,
    height = 0.5,
    y = -5.25,
    color = {0.2, 0.4, 0.4, 1},
  })

  local door = Door.new(self, {x = -4})
  local door = Door.new(self, {x = -2, y = -6.5, open = true})

  local wall = Wall.new(self, {
    x = 4,
    y = 0,
    width = 2,
    height = 2,
    image = "resources/images/crate.png",
  })

  local wall = Wall.new(self, {
    x = 3,
    y = -6.5,
    width = 2,
    height = 2,
    image = "resources/images/crate.png",
  })

  local player = Player.new(self, {
    maxHealth = 5,
  })

  Platform.new(self, {
    x1 = -6,
    y1 = -3,
    x2 = 6,
    y2 = -3,
    period = 5,
    width = 2,
    height = 0.5,
    velocityX = 2,
  })

  self.commandSequence = {
    "left",
    "up",
    "right",
    false,
  }
end

function Game:update(dt)
  self.frame = self.frame + 1
  self.time = self.time + dt
  self.accumulatedDt = self.accumulatedDt + dt

  while self.accumulatedDt - self.fixedDt >= 0 do
    self.accumulatedDt = self.accumulatedDt - self.fixedDt
    self:fixedUpdate(self.fixedDt)
  end
end

function Game:fixedUpdate(dt)
  self.fixedFrame = self.fixedFrame + 1
  self.fixedTime = self.fixedTime + dt

  self:updateCommands(dt)

  for id, player in pairs(self.players) do
    player:updateSpawn(dt)
  end

  for id, player in pairs(self.players) do
    player:updateInput(dt)
  end

  for id, monster in pairs(self.monsters) do
    monster:updateTransition(dt)
  end

  for id, platform in pairs(self.platforms) do
    platform:updateVelocity(dt)
  end

  for id, monster in pairs(self.monsters) do
    monster:updateVelocity(dt)
  end

  self.systems.box:updatePositions(dt)

  for id, monster in pairs(self.monsters) do
    monster:updateCollision(dt)
  end

  for id, player in pairs(self.players) do
    player:updateCamera(dt)
  end

  for id, player in pairs(self.players) do
    player:updateComplete(dt)
  end
end

function Game:draw()
  love.graphics.clear(0.1, 0.2, 0.2, 1)
  love.graphics.applyTransform(self.camera:getTransform())
  love.graphics.setLineWidth(self.camera:getLineWidth())
  -- self:drawDebug()

  for id, wall in pairs(self.walls) do
    wall:draw()
  end

  for id, door in pairs(self.doors) do
    door:draw()
  end

  for id, platform in pairs(self.platforms) do
    platform:draw()
  end

  for id, monster in pairs(self.monsters) do
    monster:draw()
  end

  love.graphics.reset()
  self:drawHud()
end

function Game:drawDebug()
  self.systems.box:drawDebug()
end

function Game:resize(width, height)
  self.camera:setViewport(0, 0, width, height)
end

function Game:generateId()
  self.maxId = self.maxId + 1
  return self.maxId
end

function Game:loadImage(filename)
  if not self.images[filename] then
    local image = love.graphics.newImage(filename)
    image:setFilter("nearest", "nearest")
    self.images[filename] = image
  end

  return self.images[filename]
end

function Game:loadSound(filename)
  if not self.sounds[filename] then
    local sound = love.audio.newSource(filename, "static")
    self.sounds[filename] = sound
  end

  return self.sounds[filename]
end

function Game:drawImage(image, x, y, angle, scaleX, scaleY, originX, originY)
  if type(image) == "string" then
    image = self:loadImage(image)
  end

  scaleX = (scaleX or 1) * self.texelScale
  scaleY = (scaleY or 1) * self.texelScale

  if not originX or not originY then
    local width, height = image:getDimensions()
    originX = originX or 0.5 * width
    originY = originY or 0.5 * height
  end

  local boxSystem = self.systems.box
  local worldWidth = boxSystem.worldWidth

  for i = -1, 1 do
    love.graphics.draw(
      image, x + i * worldWidth, y, angle, scaleX, scaleY, originX, originY)
  end
end

function Game:generateCommand()
  self.commandQueue.maxIndex = self.commandQueue.maxIndex + 1
  local command = nil
  local i = (self.commandQueue.maxIndex - 1) % #self.commandSequence + 1
  command = self.commandSequence[i] or nil
  self.commandQueue[self.commandQueue.maxIndex] = command
end

function Game:updateCommands(dt)
  self.commandPosition = self.commandPosition + self.commandSpeed * dt

  while self.commandQueue.minIndex < self.commandPosition - 0.25 and
    self.commandQueue.minIndex <= self.commandQueue.maxIndex do

    local command = self.commandQueue[self.commandQueue.minIndex]
    self.commandQueue[self.commandQueue.minIndex] = nil
    self.commandQueue.minIndex = self.commandQueue.minIndex + 1

    if command then
      local playerId, player = next(self.players)
      local monster = player and player.monsterId and self.monsters[player.monsterId]

      if monster and monster.stats.health >= 1 then
        self:playSound("resources/sounds/miss.ogg")
        monster.stats.health = monster.stats.health - 1
      end
    end
  end

  while self.commandQueue.maxIndex - self.commandQueue.minIndex + 1 < self.commandCount do
    self:generateCommand()
  end
end

function Game:drawHud()
  local width, height = love.graphics.getDimensions()
  local scale = 0.003 * height

  love.graphics.setColor(0, 0, 0, 0.5)
  love.graphics.rectangle("fill", 0, height - scale * 80, width, scale * 80)
  love.graphics.setColor(1, 1, 1, 1)

  local upCursorImage = self:loadImage("resources/images/upCursor.png")
  local leftCursorImage = self:loadImage("resources/images/leftCursor.png")
  local rightCursorImage = self:loadImage("resources/images/rightCursor.png")
  local downCursorImage = self:loadImage("resources/images/downCursor.png")

  local cursorX = 0
  love.graphics.draw(upCursorImage, cursorX, height - 4 * scale * 16, 0, scale)
  love.graphics.draw(leftCursorImage, cursorX, height - 3 * scale * 16, 0, scale)
  love.graphics.draw(rightCursorImage, cursorX, height - 2 * scale * 16, 0, scale)
  love.graphics.draw(downCursorImage, cursorX, height - scale * 16, 0, scale)

  for i = self.commandQueue.minIndex, self.commandQueue.maxIndex do
    local command = self.commandQueue[i]

    if command then
      local y = self.commandLayout[command]
      local filename = "resources/images/commands/" .. command .. ".png"
      local image = self:loadImage(filename)
      local x = scale * (i - self.commandPosition) * 48
      local y = height - (5 - y) * scale * 16

      if x > cursorX then
        love.graphics.draw(image, x, y, 0, scale)
      end
    end
  end

  local playerId, player = next(self.players)
  local monster = player and player.monsterId and self.monsters[player.monsterId]

  if monster and not monster.dead then
    local image = self:loadImage("resources/images/heart.png")

    for i = 1, monster.stats.health do
      x = scale * (i - 1) * 16
      y = height - 5 * scale * 16
      love.graphics.draw(image, x, y, 0, scale)
    end
  end
end

function Game:playSound(filename, volume)
  local sound = self:loadSound(filename):clone()

  if volume then
    sound:setVolume(volume)
  end

  sound:play()
end

return Game
