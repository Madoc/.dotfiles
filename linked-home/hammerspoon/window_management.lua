--[[
Window management.
Includes window switching.

Usage:

The window management key (shift+control+escape by default) activates window management mode.
A red box will be drawn arond the selected window, which starts off as the focus window.
This box can be moved to other windows, by default with cursor keys or Vi-style navigation (h, j, k, l).

Hitting the focus key (space or enter by default) focuses the selected window and exits window management mode.
Hitting the window management key again exits window management mode without changing anything.
Exiting can also be achieved with the exit key (escape by default).

All other keys will be handled as normal; window management mode is not modal.
--]]

--
-- Configuration
--

keymap = {
  exit = {key = "escape"},
  focusSelection = {multi = {{key = "Space"}, {key = "Return"}}},
  selectionEast = {multi = {{key = "Right"}, {key = "l"}}},
  selectionSouth = {multi = {{key = "Down"}, {key = "j"}}},
  selectionNorth = {multi = {{key = "Up"}, {key = "k"}}},
  selectionWest = {multi = {{key = "Left"}, {key = "h"}}},
  windowManagement = {mods = {"shift", "control"}, key = "escape"},
}

colors = {
  focus = {["red"] = 1, ["green"] = 0.5, ["blue"] = 0.5}
}

--
-- Module state variables
--

stateKeybindings = {
  windowManagement = {
    {key = keymap.exit, func = function() exitWindowManagementState() end},
    {key = keymap.focusSelection, func = function() focusSelection() end},
    {key = keymap.selectionEast, func = function() moveSelectionEast() end},
    {key = keymap.selectionNorth, func = function() moveSelectionNorth() end},
    {key = keymap.selectionSouth, func = function() moveSelectionSouth() end},
    {key = keymap.selectionWest, func = function() moveSelectionWest() end},
  }
}

selections = {
  focusedWindow = {rectDrawing = nil, color = colors.focus, window = nil}
}

--
-- UI state management
--

function enterWindowManagementState()
  focusedWindow = hs.window.focusedWindow()
  if not focusedWindow then
    focusedWindow = hs.window.frontmostWindow()
  end
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
    rect:setStrokeWidth(5)
    selection.rectDrawing = rect
    rect:show()
  end
end

function removeAllHighlights()
  removeHighlight(selections.focusedWindow)
end

function removeHighlight(highlight)
  local rectDrawing = highlight.rectDrawing
  if rectDrawing then
    rectDrawing:hide()
    highlight.rectDrawing = nil
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
