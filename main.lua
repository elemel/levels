local Game = require("Game")

function love.load()
  love.window.setTitle("Platform Hero")

  love.window.setMode(800, 600, {
    fullscreentype = "desktop",
    resizable = true,
    highdpi = true,
  })

  love.physics.setMeter(1)
  love.graphics.setDefaultFilter("nearest")

  local music =
    love.audio.newSource("resources/music/platformHero.ogg", "stream")

  music:setLooping(true)
  music:play()

  game = Game.new({})
end

function love.update(...)
  game:update(...)

  if game.complete then
    game = Game.new({
      level = game.level + 1,
    })
  end
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
