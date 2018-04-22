local Game = require("Game")

function love.load()
  love.window.setTitle("Levels")

  love.window.setMode(800, 600, {
    fullscreentype = "desktop",
    resizable = true,
    -- highdpi = true,
  })

  love.physics.setMeter(1)
  love.graphics.setDefaultFilter("nearest")

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

function love.keypressed(key, scancode, isrepeat)
  if key == "f1" then
    love.graphics.captureScreenshot("screenshot.png")
  end
end
