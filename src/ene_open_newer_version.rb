#-------------------------------------------------------------------------------
#
#    Author: Julia Christina Eneroth
# Copyright: Copyright (c) 2019
#   License: MIT
#
#-------------------------------------------------------------------------------

require "extensions.rb"

# Eneroth Extensions
module Eneroth

# Open Newer Version
module OpenNewerVersion

  path = __FILE__
  path.force_encoding("UTF-8") if path.respond_to?(:force_encoding)

  PLUGIN_ID = File.basename(path, ".*")
  PLUGIN_DIR = File.join(File.dirname(path), PLUGIN_ID)

  EXTENSION = SketchupExtension.new(
    "Eneroth Open Newer Version",
    File.join(PLUGIN_DIR, "main")
  )
  EXTENSION.creator     = "Julia Christina Eneroth"
  EXTENSION.description =
    "Convert and open models made in newer versions of SketchUp."
  EXTENSION.version     = "1.0.5"
  EXTENSION.copyright   = "2020, #{EXTENSION.creator}"
  Sketchup.register_extension(EXTENSION, true)

end
end
