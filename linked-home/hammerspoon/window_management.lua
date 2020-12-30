--[[
Window management.
Includes window switching, movement and resizing.

Usage:

The window management key (shift+control+escape by default) activates window management.
A red box will be drawn arond the selected window, which starts off as the focus window.
This box can be moved to other windows, by default with cursor keys or Vi-style navigation (h, j, k, l).

Hitting the focus key (enter by default) focuses the selected window and exits window management mode.
Hitting the window management key again exits window management mode without changing anything.
Exiting can also be achieved with the exit key (escape by default).

All other keys will be handled as normal; window management mode is not modal.

Hitting space switches modes.
The initial mode is window focusing, the second mode is the grid mode.

In grid mode, a grid will be drawn on the screen.
The currently selected grid cell will be displayed in blue.
The selection can be moved (cursor keys or Vi-style navigation by default).
Hitting the "accept" key (enter by default) resizes and moves the focused window to the dimension of and exits window
 management.
--]]

--
-- Configuration
--

keymap = {
  acceptSelection = { key = "Return"},
  changeMode = {key = "Space"},
  exit = {key = "escape"},
  selectionEast = {multi = {{key = "Right"}, {key = "l"}}},
  selectionSouth = {multi = {{key = "Down"}, {key = "j"}}},
  selectionNorth = {multi = {{key = "Up"}, {key = "k"}}},
  selectionWest = {multi = {{key = "Left"}, {key = "h"}}},
  sizeEnlargeX = { key = "g"},
  sizeEnlargeY = { key = "f"},
  sizeShrinkX = {key = "s"},
  sizeShrinkY = {key = "d"},
  windowManagement = {mods = {"shift", "control"}, key = "escape"},
}

colors = {
  focus = {red = 1, green = 0.5, blue = 0.5},
  gridActive = {red = 0.75, green = 0.75, blue = 1},
  gridInactive = {red = 0.35, green = 0.35, blue = 0.35},
}

dimensions = {
  defaultGridHeight = 2,
  defaultGridWidth = 3,
  focusedWindowBorderWidth = 5,
  gridBorderWidth = 3,
}

levels = {
  focusedWindow = hs.drawing.windowLevels.assistiveTechHigh+1,
  gridActive = hs.drawing.windowLevels.assistiveTechHigh+3,
  gridInactive = hs.drawing.windowLevels.assistiveTechHigh+2,
}

--
-- Module state variables
--

stateKeybindings = {
  grid = {
    {key = keymap.acceptSelection, func = function() gridAccept() end},
    {key = keymap.changeMode, func = function() exitGridState(); enterWindowManagementState(true) end},
    {key = keymap.exit, func = function() exitGridState() end},
    {key = keymap.selectionEast, func = function() gridMoveEast() end},
    {key = keymap.selectionNorth, func = function() gridMoveNorth() end},
    {key = keymap.selectionSouth, func = function() gridMoveSouth() end},
    {key = keymap.selectionWest, func = function() gridMoveWest() end},
    {key = keymap.sizeEnlargeX, func = function() gridEnlargeX() end},
    {key = keymap.sizeEnlargeY, func = function() gridEnlargeY() end},
    {key = keymap.sizeShrinkX, func = function() gridShrinkX() end},
    {key = keymap.sizeShrinkY, func = function() gridShrinkY() end},
  },
  windowManagement = {
    {key = keymap.acceptSelection, func = function() focusSelection() end},
    {key = keymap.changeMode, func = function() exitWindowManagementState(); enterGridState() end},
    {key = keymap.exit, func = function() exitWindowManagementState() end},
    {key = keymap.selectionEast, func = function() moveSelectionEast() end},
    {key = keymap.selectionNorth, func = function() moveSelectionNorth() end},
    {key = keymap.selectionSouth, func = function() moveSelectionSouth() end},
    {key = keymap.selectionWest, func = function() moveSelectionWest() end},
  }
}

selections = {
  grid = {
    height = dimensions.defaultGridHeight, width = dimensions.defaultGridWidth,
    selectionX = 0, selectionY = 0,
    screen = nil, rects = nil,
  },
  focusedWindow = {rectDrawing = nil, color = colors.focus, window = nil}
}

--
-- UI state management
--

function enterWindowManagementState(preserveFocus)
  local focusedWindow = nil
  if preserveFocus then focusedWindow = selections.focusedWindow.window end
  if not focusedWindow then focusedWindow = hs.window.focusedWindow() end
  if not focusedWindow then focusedWindow = hs.window.frontmostWindow() end
  if focusedWindow then
    bindKey(keymap.windowManagement, exitWindowManagementState)
    for _, keybinding in ipairs(stateKeybindings.windowManagement) do bindKey(keybinding.key, keybinding.func) end
    selectWindow(selections.focusedWindow, focusedWindow)
  end
end

function exitWindowManagementState()
  bindKey(keymap.windowManagement, enterWindowManagementState)
  for _, keybinding in ipairs(stateKeybindings.windowManagement) do unbindKey(keybinding.key) end
  removeAllHighlights()
end

function enterGridState()
  bindKey(keymap.windowManagement, exitGridState)
  for _, keybinding in ipairs(stateKeybindings.grid) do bindKey(keybinding.key, keybinding.func) end
  selectWindow(selections.focusedWindow, selections.focusedWindow.window)
  createGrid()
end

function exitGridState()
  bindKey(keymap.windowManagement, enterWindowManagementState)
  for _, keybinding in ipairs(stateKeybindings.grid) do unbindKey(keybinding.key) end
  removeAllHighlights()
end

--
-- Window selection
--

function moveSelectionEast() moveSelectionInDirection(selectWindowsToEast) end
function moveSelectionNorth() moveSelectionInDirection(selectWindowsToNorth) end
function moveSelectionSouth() moveSelectionInDirection(selectWindowsToSouth) end
function moveSelectionWest() moveSelectionInDirection(selectWindowsToWest) end

function focusSelection()
  if selections.focusedWindow.window then
    selections.focusedWindow.window:focus()
    exitWindowManagementState()
  end
end

function moveSelectionInDirection(selectInDirection)
  if selections.focusedWindow.window then
    for _, candidate in ipairs(selectInDirection(selections.focusedWindow.window)) do
      if candidate:isVisible() then
        selectWindow(selections.focusedWindow, candidate)
        return
      end
    end
  end
end

function selectWindowsToEast(window) return window:windowsToEast() end
function selectWindowsToNorth(window) return window:windowsToNorth() end
function selectWindowsToSouth(window) return window:windowsToSouth() end
function selectWindowsToWest(window) return window:windowsToWest() end

--
-- Grid selection
--

function gridAccept()
  selections.focusedWindow.window:setFrame(selections.grid.rects[selections.grid.selectionX][selections.grid.selectionY].rectDrawing:frame())
  exitGridState()
end

function gridMoveEast()
  if selections.grid.selectionX+1 < selections.grid.width then
    local cell = selections.grid.rects[selections.grid.selectionX]
    if cell then
      cell = cell[selections.grid.selectionY]
      if cell and cell.rectDrawing then
        cell.rectDrawing:setStrokeColor(colors.gridInactive)
        cell.rectDrawing:setLevel(levels.gridInactive)
      end
    end
    selections.grid.selectionX = selections.grid.selectionX + 1
    selections.grid.rects[selections.grid.selectionX][selections.grid.selectionY].rectDrawing:setStrokeColor(colors.gridActive)
    selections.grid.rects[selections.grid.selectionX][selections.grid.selectionY].rectDrawing:setLevel(levels.gridActive)
  end
end

function gridMoveNorth()
  if selections.grid.selectionY > 0 then
    local cell = selections.grid.rects[selections.grid.selectionX]
    if cell then
      cell = cell[selections.grid.selectionY]
      if cell and cell.rectDrawing then
        cell.rectDrawing:setStrokeColor(colors.gridInactive)
        cell.rectDrawing:setLevel(levels.gridInactive)
      end
    end
    selections.grid.selectionY = selections.grid.selectionY - 1
    selections.grid.rects[selections.grid.selectionX][selections.grid.selectionY].rectDrawing:setStrokeColor(colors.gridActive)
    selections.grid.rects[selections.grid.selectionX][selections.grid.selectionY].rectDrawing:setLevel(levels.gridActive)
  end
end

function gridMoveSouth()
  if selections.grid.selectionY+1 < selections.grid.height then
    local cell = selections.grid.rects[selections.grid.selectionX]
    if cell then
      cell = cell[selections.grid.selectionY]
      if cell and cell.rectDrawing then
        cell.rectDrawing:setStrokeColor(colors.gridInactive)
        cell.rectDrawing:setLevel(levels.gridInactive)
      end
    end
    selections.grid.selectionY = selections.grid.selectionY + 1
    selections.grid.rects[selections.grid.selectionX][selections.grid.selectionY].rectDrawing:setStrokeColor(colors.gridActive)
    selections.grid.rects[selections.grid.selectionX][selections.grid.selectionY].rectDrawing:setLevel(levels.gridActive)
  end
end

function gridMoveWest()
  if selections.grid.selectionX > 0 then
    local cell = selections.grid.rects[selections.grid.selectionX]
    if cell then
      cell = cell[selections.grid.selectionY]
      if cell and cell.rectDrawing then
        cell.rectDrawing:setStrokeColor(colors.gridInactive)
        cell.rectDrawing:setLevel(levels.gridInactive)
      end
    end
    selections.grid.selectionX = selections.grid.selectionX - 1
    selections.grid.rects[selections.grid.selectionX][selections.grid.selectionY].rectDrawing:setStrokeColor(colors.gridActive)
    selections.grid.rects[selections.grid.selectionX][selections.grid.selectionY].rectDrawing:setLevel(levels.gridActive)
  end
end

function gridEnlargeX()
  removeGrid()
  selections.grid.width = selections.grid.width + 1
  createGrid()
end

function gridEnlargeY()
  removeGrid()
  selections.grid.height = selections.grid.height + 1
  createGrid()
end

function gridShrinkX()
  if selections.grid.width > 1 then
    removeGrid()
    selections.grid.width = selections.grid.width - 1
    createGrid()
    if selections.grid.width <= selections.grid.selectionX then gridMoveWest() end
  end
end

function gridShrinkY()
  if selections.grid.height > 1 then
    removeGrid()
    selections.grid.height = selections.grid.height - 1
    createGrid()
    if selections.grid.height <= selections.grid.selectionY then gridMoveNorth() end
  end
end

--
-- Visual feedback
--

function selectWindow(selection, window)
  removeHighlight(selection)
  selection.window = window
  if window then
    local rect = hs.drawing.rectangle(window:frame())
    rect:setFill(false)
    rect:setStroke(true)
    rect:setStrokeColor(selection.color)
    rect:setStrokeWidth(dimensions.focusedWindowBorderWidth)
    rect:setLevel(levels.focusedWindow)
    selection.rectDrawing = rect
    rect:show()
  end
end

function createGrid()
  if not selections.grid.screen then selections.grid.screen = selections.focusedWindow.window:screen() end
  local screen = selections.grid.screen
  if screen then
    local screenX1, screenY1 = screen:frame().x1, screen:frame().y1
    local screenWidth, screenHeight = screen:frame().w, screen:frame().h
    selections.grid.rects = {}
    for x = 0, selections.grid.width-1 do
      local row = {}
      selections.grid.rects[x] = row
      for y = 0, selections.grid.height-1 do
        local cell = {}
        row[y] = cell
        local rectX1, rectY1 = screenX1 + math.floor(screenWidth*x/selections.grid.width), screenY1 + math.floor(screenHeight*y/selections.grid.height)
        local rectX2, rectY2 = screenX1 + math.floor(screenWidth*(x+1)/selections.grid.width), screenY1 + math.floor(screenHeight*(y+1)/selections.grid.height)
        local rect = hs.drawing.rectangle(hs.geometry.rect(rectX1, rectY1, rectX2-rectX1+1, rectY2-rectY1+1))
        local isSelected = (x == selections.grid.selectionX) and (y == selections.grid.selectionY)
        rect:setFill(false)
        rect:setStroke(true)
        rect:setStrokeWidth(dimensions.gridBorderWidth)
        if isSelected then
          rect:setStrokeColor(colors.gridActive)
          rect:setLevel(levels.gridActive)
        else
          rect:setStrokeColor(colors.gridInactive)
          rect:setLevel(levels.gridInactive)
        end
        cell.rectDrawing = rect
        rect:show()
      end
    end
  end
end

function removeAllHighlights()
  removeGrid()
  removeHighlight(selections.focusedWindow)
end

function removeHighlight(highlight)
  local rectDrawing = highlight.rectDrawing
  if rectDrawing then
    rectDrawing:hide()
    highlight.rectDrawing = nil
  end
end

function removeGrid()
  if selections.grid.rects then
    for x = 0, selections.grid.width-1 do for y = 0, selections.grid.height-1 do
      local cell = selections.grid.rects[x][y]
      if cell then removeHighlight(cell) end
    end end
    selections.grid.rects = nil
  end
end

--
-- Key bindings
--

function bindKey(keymapElement, func)
  if keymapElement.multi then
    for _, innerElement in ipairs(keymapElement.multi) do bindKey(innerElement, func) end
  else
    unbindKey(keymapElement)
    keymapElement.hotkey = hs.hotkey.bind(keymapElement.mods, keymapElement.key, func)
  end
end

function unbindKey(keymapElement)
  if keymapElement.multi then
    for _, innerElement in ipairs(keymapElement.multi) do unbindKey(innerElement) end
  else
    if keymapElement.hotkey then
      keymapElement.hotkey:delete()
      keymapElement.hotkey = nil
    end
  end
end

--
-- Module initializer
--

bindKey(keymap.windowManagement, enterWindowManagementState)
