module Eneroth
module OpenNewerVersion

  # Get the number of the running SU version, e.g. 8 or 2013.
  #
  # @return [Integer]
  def self.current_su_version
    version = Sketchup.version.to_i
    version += 2000 if version > 8

    version
  end

  # Convert model to current SU version and open it.
  #
  # @return [Void]
  def self.open_newer_version
    source = UI.openpanel("Open", "", "SketchUp Models|*.skp||")
    return unless source

    # TODO: Open directly if of supported version.

    title = "Save As SketchUp #{current_su_version} Compatible"
    directory = File.dirname(source)
    filename = "#{File.basename(source, ".skp")} (SU #{current_su_version}).skp"
    target = UI.savepanel(title, directory, filename)
    return unless target

    # TODO: Move source of binary file into repo once I've got the hang of how
    # to set up C++ projects (so far it is just a modified version of an
    # example inside the SDK directory).
    # TODO: Call program without command line window flashing.
    %x( "#{PLUGIN_DIR}/bin/convert_version" "#{source}" "#{target}" #{current_su_version} )
    Sketchup.open_file(target)

    nil
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

  # Menu
  unless @loaded
    @loaded = true

    menu = UI.menu("File")
    cmd = UI::Command.new("Open Newer Version") { open_newer_version }
    # TODO: Add directly below "Open".
    menu.add_item(cmd)
  end

end
end
