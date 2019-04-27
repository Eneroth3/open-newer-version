module Eneroth
  module OpenNewerVersion
    if !Sketchup.platform == :platform_win
      UI.messahebox("#{EXTENSION.name} is only supported on Windows.")
    elsif Sketchup.respond_to?(:is_64bit?) && !Sketchup.is_64bit?
      # Can't detect and handle 32 bitness in SU 2014 :( .
      UI.messahebox("#{EXTENSION.name} requires 64 bit Windows.")
    elsif Sketchup.version.to_i < 14
      UI.messahebox("#{EXTENSION.name} requires SketchUp 2014 or newer.")
    else
      Sketchup.require File.join(PLUGIN_DIR, "menu")
    end

    # Reload extension.
    #
    # @param clear_console [Boolean] Whether console should be cleared.
    # @param undo [Boolean] Whether last operation should be undone.
    #
    # @return [Void]
    def self.reload(clear_console = true, undo = false)
      # Hide warnings for already defined constants.
      verbose = $VERBOSE
      $VERBOSE = nil
      Dir.glob(File.join(PLUGIN_DIR, "**/*.{rb,rbe}")).each { |f| load(f) }
      $VERBOSE = verbose

      # Use a timer to make call to method itself register to console.
      # Otherwise the user cannot use up arrow to repeat command.
      UI.start_timer(0) { SKETCHUP_CONSOLE.clear } if clear_console

      Sketchup.undo if undo

      nil
    end
  end
end
