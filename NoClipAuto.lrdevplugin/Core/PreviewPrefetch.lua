-- Copyright 2026 NoClip Auto contributors
-- SPDX-License-Identifier: Apache-2.0

local LrTasks = import "LrTasks"

local PreviewRender = require("Core.PreviewRender")

local PreviewPrefetch = {}
PreviewPrefetch.__index = PreviewPrefetch

function PreviewPrefetch.new(previewSize)
  return setmetatable({
    previewSize = previewSize,
    slot = nil,
  }, PreviewPrefetch)
end

function PreviewPrefetch:enqueue(photo)
  if self.slot then
    return
  end

  local previewSize = self.previewSize
  self.slot = {
    photo = photo,
    ready = false,
    path = nil,
    err = nil,
  }

  local slot = self.slot
  LrTasks.startAsyncTask(function()
    local path, err = PreviewRender.exportPhoto(photo, previewSize)
    slot.path = path
    slot.err = err
    slot.ready = true
  end)
end

function PreviewPrefetch:take(photo)
  if self.slot and self.slot.photo == photo then
    local deadline = os.time() + 120
    while not self.slot.ready and os.time() < deadline do
      LrTasks.yield()
    end

    local path = self.slot.path
    local err = self.slot.err
    self.slot = nil

    if not path then
      return nil, err or "prefetch export failed"
    end
    return path
  end

  return PreviewRender.exportPhoto(photo, self.previewSize)
end

return PreviewPrefetch
