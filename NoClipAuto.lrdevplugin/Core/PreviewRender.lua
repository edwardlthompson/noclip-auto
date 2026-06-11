-- Copyright 2026 NoClip Auto contributors
-- SPDX-License-Identifier: Apache-2.0

local LrExportSession = import "LrExportSession"
local LrFileUtils = import "LrFileUtils"
local LrPathUtils = import "LrPathUtils"
local LrTasks = import "LrTasks"

local ClippingClient = require("Core.ClippingClient")

local PreviewRender = {}

local preferThumbnail = false

function PreviewRender.setPreferThumbnail(value)
  preferThumbnail = value == true
end

function PreviewRender.exportPhotoViaThumbnail(photo, previewSize)
  local outPath = ClippingClient.tempJpegPath(photo.localIdentifier)
  LrFileUtils.createAllDirectories(LrPathUtils.parent(outPath))

  local done = false
  local errMsg = nil

  photo:requestJpegThumbnail(previewSize, previewSize, function(jpegData, err)
    if not jpegData then
      errMsg = err or "thumbnail request failed"
      done = true
      return
    end

    local file = io.open(outPath, "wb")
    if not file then
      errMsg = "could not write " .. outPath
      done = true
      return
    end
    file:write(jpegData)
    file:close()
    done = true
  end)

  local deadline = os.time() + 90
  while not done and os.time() < deadline do
    LrTasks.yield()
  end

  if not done then
    return nil, "thumbnail callback timeout"
  end
  if errMsg then
    return nil, errMsg
  end
  return outPath
end

function PreviewRender.exportPhoto(photo, previewSize)
  local useFull = NoClipAuto.prefs and NoClipAuto.prefs.useFullSizePreview == true
  if preferThumbnail or not useFull then
    return PreviewRender.exportPhotoViaThumbnail(photo, previewSize)
  end

  local outPath = ClippingClient.tempJpegPath(photo.localIdentifier)

  local exportSettings = {
    LR_format = "JPEG",
    LR_jpeg_quality = 0.85,
    LR_size_doConstrainSize = true,
    LR_size_resizeType = "longEdge",
    LR_size_maxWidth = previewSize,
    LR_size_maxHeight = previewSize,
    LR_export_useSubfolder = false,
    LR_export_destinationType = "specificFolder",
    LR_export_destinationPathPrefix = LrPathUtils.parent(outPath),
  }

  local session = LrExportSession({
    photosToExport = { photo },
    exportSettings = exportSettings,
  })

  session:doExportOnNewTask()

  local baseName = photo:getFormattedMetadata("fileName") or "preview"
  local stem = baseName:gsub("%.[^%.]+$", "")
  local destDir = LrPathUtils.parent(outPath)
  local candidates = {
    outPath,
    LrPathUtils.child(destDir, stem .. ".jpg"),
    LrPathUtils.child(destDir, stem .. "-Edit.jpg"),
  }

  local deadline = os.time() + 120
  while os.time() < deadline do
    for _, path in ipairs(candidates) do
      if LrFileUtils.exists(path) == "file" then
        if path ~= outPath then
          LrFileUtils.move(path, outPath)
        end
        return outPath
      end
    end
    LrTasks.yield()
  end

  return nil, "preview JPEG not created"
end

function PreviewRender.cleanup(path)
  if path and LrFileUtils.exists(path) == "file" then
    LrFileUtils.delete(path)
  end
end

return PreviewRender
