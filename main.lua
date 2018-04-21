local Game = require("Game")

function love.load()
  love.window.setTitle("Levels")

  love.window.setMode(800, 600, {
    fullscreentype = "desktop",
    resizable = true,
    highdpi = true,
  })

  love.physics.setMeter(1)

  game = Game.new({})
end

function love.update(...)
  game:update(...)
end

function love.draw(...)
  game:draw(...)
end

function love.resize(...)
  game:resize(...)
end