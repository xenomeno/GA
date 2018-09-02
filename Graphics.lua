dofile("Bitmap.lua")

function DrawGraphs(bmp, funcs_data, div, int_x, int_y)
  div = div or 10
  
  local any = funcs_data.funcs[next(funcs_data.funcs)][1]
  local min_x, min_y, max_x, max_y = any.x, any.y, any.x, any.y
  for _, func_points in pairs(funcs_data.funcs) do
    for _, pt in ipairs(func_points) do
      min_x = (pt.x < min_x) and pt.x or min_x
      min_y = (pt.y < min_y) and pt.y or min_y
      max_x = (pt.x > max_x) and pt.x or max_x
      max_y = (pt.y > max_y) and pt.y or max_y
    end
  end
  
  local size_x = math.ceil(max_x)
  local size_y = math.ceil(max_y)
  
  local width, height = bmp.width, bmp.height
  local spacing_x, spacing_y = width // (div + 2), height // (div + 2)
  local scale_x, scale_y = 10 * spacing_x / size_x, 10 * spacing_y / size_y
  local Ox = spacing_x
  local Oy = height - spacing_y
  
  -- draw coordinate system
  bmp:DrawLine(Ox - spacing_x // 2, Oy, Ox + 10 * spacing_x + spacing_x // 2, Oy, {128, 128, 128})
  bmp:DrawLine(Ox, Oy + spacing_y // 2, Ox, Oy - 10 * spacing_y - spacing_y // 2, {128, 128, 128})
  local metric_x, metric_y = spacing_x // 10, spacing_y // 10
  for k = 1, div do
    bmp:DrawLine(Ox + k * spacing_x, Oy - metric_y, Ox + k * spacing_x, Oy + metric_y, {128, 128, 128})
    bmp:DrawLine(Ox - metric_x, Oy - k * spacing_y, Ox + metric_x, Oy - k * spacing_y, {128, 128, 128})
    local text = int_x and string.format("%d", k * size_x // div) or string.format("%.2f", k * size_x / div)
    local tw, th = bmp:MeasureText(text)
    bmp:DrawText(Ox + k * spacing_x - tw // 2, Oy + 2 * metric_y, text, {128, 128, 128})
    text = int_y and string.format("%d", k * size_y // div) or string.format("%.2f", k * size_y / div)
    tw, th = bmp:MeasureText(text)
    bmp:DrawText(0, Oy - k * spacing_y - th // 2, text, {128, 128, 128})
  end
  
  -- draw graphs
  local box_size = 2
  local name_x = spacing_x + 10
  for name, func_points in pairs(funcs_data.funcs) do
    local last_x, last_y
    for _, pt in ipairs(func_points) do
      local x = math.floor(Ox + scale_x * pt.x)
      local y = math.floor(Oy - scale_y * pt.y)
      if last_x and last_y then
        bmp:DrawLine(last_x, last_y, x, y, func_points.color)
      end
      bmp:DrawBox(x - box_size, y - box_size, x + box_size, y + box_size, func_points.color)
      last_x, last_y = x, y
    end
    local w, h = bmp:MeasureText(name)
    bmp:DrawText(name_x, height - h, name, func_points.color)
    name_x = name_x + w + 30
  end
  
  if funcs_data.name_y then
    bmp:DrawText(5, 5, funcs_data.name_y, {128, 128, 128})
  end
  if funcs_data.name_x then
    local w, h = bmp:MeasureText(funcs_data.name_x)
    bmp:DrawText(width - w - 5, height - h - 5, funcs_data.name_x, {128, 128, 128})
  end
end