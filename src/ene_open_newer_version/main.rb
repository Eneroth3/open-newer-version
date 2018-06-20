module Eneroth
module OpenNewerVersion

  # Mayor version of the running SketchUp.
  SU_VERSION = Sketchup.version.to_i

  # Get SketchUp version string of a saved file.
  #
  # @param path [String]
  #
  # @raise [IOError]
  #
  # @return [String]
  def self.version(path)
    v = File.binread(path, 64).tr("\x00", "")[/{([\d.]+)}/n, 1]

    v || raise(IOError, "Can't determine SU version for '#{path}'. Is file a model?")
  end

  # Convert model to current SU version and open it.
  #
  # @return [Void]
  def self.open_newer_version
    source = UI.openpanel("Open", "", "SketchUp Models|*.skp||")
    return unless source

    if version(source).to_i <= Sketchup.version.to_i
      Sketchup.open_file(source)
      return
    end

    title = "Save As SketchUp #{SU_VERSION} Compatible"
    directory = File.dirname(source)
    # Prefixing version with 20 as SketchUp 2014 is the oldest supported
    # version. If ever supporting versions older than 2013, only prefix for
    # 13 and above.
    filename = "#{File.basename(source, ".skp")} (SU 20#{SU_VERSION}).skp"
    target = UI.savepanel(title, directory, filename)
    return unless target

    # TODO: Move source of binary file into repo once I've got the hang of how
    # to set up C++ projects (so far it is just a modified version of an
    # example inside the SDK directory).
    # TODO: Call program without command line window flashing.
    %x( "#{PLUGIN_DIR}/bin/convert_version" "#{source}" "#{target}" #{SU_VERSION} )
    Sketchup.open_file(target)

    nil
  end

  # Add menu item at custom position in menu.
  #
  # The custom position is only used in SketchUp for Windows version 2016 and
  # above. In other versions the menu item will be placed at the end of the
  # menu. Please note that this is an undocumented SketchUp API behavior that
  # may be subject to change.
  #
  # @param menu [UI::Menu]
  # @param name [String]
  # @param position [Fixnum, nil]
  #
  # @example
  #   # Add Menu Item Right Below Entity Info
  #   UI.add_context_menu_handler do |menu|
  #     SkippyLib::LUI.add_menu_item(menu, "Entity Color Info", 1) do
  #       model = Sketchup.active_model
  #       entity = model.selection.first
  #       return unless entity
  #       color = entity.material ? entity.material.color : model.rendering_options["ForegroundColor"]
  #       UI.messagebox(color.to_a.join(", "))
  #     end
  #   end
  #
  # @return [Fixnum] identifier of menu item.
  def self.add_menu_item(menu, name, position = nil, &block)
    # Sketchup.platform added in SU2014.
    if position && Sketchup.platform == :platform_win && Sketchup.version.to_i >= 16
      menu.add_item(name, position, &block)
    else
      menu.add_item(name, &block)
    end
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
    add_menu_item(menu, "Open Newer Version...", 2) { open_newer_version }
  end

end
end
