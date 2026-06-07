-- Copyright 2026 NoClip Auto contributors
-- SPDX-License-Identifier: Apache-2.0

local LrApplication = import "LrApplication"
local LrExportSession = import "LrExportSession"
local LrFileUtils = import "LrFileUtils"

local ClippingClient = require("Core.ClippingClient")

local PreviewRender = {}

function PreviewRender.exportPhoto(photo, previewSize)
  local catalog = LrApplication.activeCatalog()
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
    LR_export_destinationPathPrefix = LrFileUtils.parent(outPath),
  }

  local session = LrExportSession({
    photosToExport = { photo },
    exportSettings = exportSettings,
  })

  local rendered = false
  for _, rendition in session:renditions({ stopIfCanceled = true }) do
    local success, pathOrMessage = rendition:waitForRender()
    if success then
      if pathOrMessage ~= outPath and LrFileUtils.exists(pathOrMessage) == "file" then
        LrFileUtils.move(pathOrMessage, outPath)
      end
      rendered = true
    else
      return nil, pathOrMessage or "render failed"
    end
  end

  if not rendered or LrFileUtils.exists(outPath) ~= "file" then
    return nil, "preview JPEG not created"
  end

  return outPath
end

function PreviewRender.cleanup(path)
  if path and LrFileUtils.exists(path) == "file" then
    LrFileUtils.delete(path)
  end
end

return PreviewRender
