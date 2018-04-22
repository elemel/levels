local max = math.max
local min = math.min
local setmetatable = setmetatable

local function mix(x1, x2, t)
  return (1 - t) * x1 + t * x2
end

local function mix2(x1, y1, x2, y2, t)
  return (1 - t) * x1 + t * x2, (1 - t) * y1 + t * y2
end

local function clamp(x, x1, x2)
  return min(max(x, x1), x2)
end

local function newClass()
  local class = {}
  class.__index = class

  function class.new(...)
    local instance = setmetatable({}, class)
    instance:init(...)
    return instance
  end

  return class
end

local function boxesIntersect(x1, y1, x2, y2, x3, y3, x4, y4)
  return x1 < x4 and x3 < x2 and y1 < y4 and y3 < y2
end

local function boxesIntersection(x1, y1, x2, y2, x3, y3, x4, y4)
  return max(x1, x3), max(y1, y3), min(x2, x4), min(y2, y4)
end

local function maxDistanceBox(x1, y1, x2, y2, x3, y3, x4, y4)
  local leftDistance = x1 - x4
  local rightDistance = x3 - x2
  local upDistance = y1 - y4
  local downDistance = y3 - y2

  if max(leftDistance, rightDistance) > max(upDistance, downDistance) then
    if leftDistance > rightDistance then
      return leftDistance, -1, 0
    else
      return rightDistance, 1, 0
    end
  else
    if upDistance > downDistance then
      return upDistance, 0, -1
    else
      return downDistance, 0, 1
    end
  end
end

return {
  clamp = clamp,
  mix = mix,
  mix2 = mix2,
  newClass = newClass,
  boxesIntersect = boxesIntersect,
  boxesIntersection = boxesIntersection,
  maxDistanceBox = maxDistanceBox,
}
