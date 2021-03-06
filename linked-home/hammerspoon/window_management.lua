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

Enlarging or shrinking the grid resolution is done with cursor-like navigation (s, d, f, g by default).
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
  sizeEnlargeX = {key = "g"},
  sizeEnlargeY = {key = "f"},
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
  local focusedWindow = getDefaultFocusedWindow(preserveFocus)
  if focusedWindow then
    bindKey(keymap.windowManagement, exitWindowManagementState)
    bindKeys(stateKeybindings.windowManagement)
    selectWindow(selections.focusedWindow, focusedWindow)
  end
end

function exitWindowManagementState()
  bindKey(keymap.windowManagement, enterWindowManagementState)
  unbindKeys(stateKeybindings.windowManagement)
  removeAllHighlights()
end

function enterGridState()
  bindKey(keymap.windowManagement, exitGridState)
  bindKeys(stateKeybindings.grid)
  selectWindow(selections.focusedWindow, selections.focusedWindow.window)
  selections.grid.screen = selections.focusedWindow.window:screen()
  createGrid()
end

function exitGridState()
  bindKey(keymap.windowManagement, enterWindowManagementState)
  unbindKeys(stateKeybindings.grid)
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

function gridMoveEast() gridMove(1, 0) end
function gridMoveNorth() gridMove(0, -1) end
function gridMoveSouth() gridMove(0, 1) end
function gridMoveWest() gridMove(-1, 0) end

function gridMove(dx, dy)
  local newX, newY = selections.grid.selectionX + dx, selections.grid.selectionY + dy
  if newX>=0 and newX<selections.grid.width and newY>=0 and newY<selections.grid.height then
    removeGridHighlight()
    selections.grid.selectionX, selections.grid.selectionY = newX, newY
    addGridHighlight()
  end
end

function gridEnlargeX() gridResize(1, 0) end
function gridEnlargeY() gridResize(0, 1) end
function gridShrinkX() gridResize(-1, 0) end
function gridShrinkY() gridResize(0, -1) end

function gridResize(dw, dh)
  local newWidth, newHeight = selections.grid.width + dw, selections.grid.height + dh
  if newWidth>0 and newHeight>0 then
    removeGrid()
    selections.grid.width, selections.grid.height = newWidth, newHeight
    if newWidth<=selections.grid.selectionX then selections.grid.selectionX=selections.grid.width-1 end
    if newHeight<=selections.grid.selectionY then selections.grid.selectionY=selections.grid.height-1 end
    createGrid()
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
        rect:setFill(false)
        rect:setStroke(true)
        rect:setStrokeWidth(dimensions.gridBorderWidth)
        rect:setStrokeColor(colors.gridInactive)
        rect:setLevel(levels.gridInactive)
        cell.rectDrawing = rect
        rect:show()
      end
    end
  end
  addGridHighlight()
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

function addGridHighlight() setGridCellActive(selections.grid.selectionX, selections.grid.selectionY, true)  end

function removeGridHighlight() setGridCellActive(selections.grid.selectionX, selections.grid.selectionY, false) end

function setGridCellActive(x, y, active)
  if selections.grid.rects then
    local cell = selections.grid.rects[x]
    if cell then cell = cell[y] end
    if cell and cell.rectDrawing then
      if active then
        cell.rectDrawing:setStrokeColor(colors.gridActive)
        cell.rectDrawing:setLevel(levels.gridActive)
      else
        cell.rectDrawing:setStrokeColor(colors.gridInactive)
        cell.rectDrawing:setLevel(levels.gridInactive)
      end
    end
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

function bindKeys(bindings) for _, binding in ipairs(bindings) do bindKey(binding.key, binding.func) end end

function unbindKeys(bindings) for _, binding in ipairs(bindings) do unbindKey(binding.key) end end

--
-- Window actions
--

function getDefaultFocusedWindow(preserveFocus)
  local focusedWindow
  if preserveFocus then focusedWindow = selections.focusedWindow.window end
  if not focusedWindow then focusedWindow = hs.window.focusedWindow() end
  if not focusedWindow then focusedWindow = hs.window.frontmostWindow() end
  return focusedWindow
end

--
-- Module initializer
--

bindKey(keymap.windowManagement, enterWindowManagementState)
