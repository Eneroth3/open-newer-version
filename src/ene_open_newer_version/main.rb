require "tempfile"

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

  # Ask user for path to open from.
  #
  # @return [String]
  def self.prompt_source_path
    UI.openpanel("Open", "", "SketchUp Models|*.skp||")
  end

  # Ask user for path to save converted model to.
  #
  # @param source [String]
  #
  # @return [String]
  def self.prompt_target_path(source)
    # Prefixing version with 20 as SketchUp 2014 is the oldest supported
    # version. If ever supporting versions 8 or older, only prefix for
    # [20]13 and above.
    title = "Save As SketchUp 20#{SU_VERSION} Compatible"
    directory = File.dirname(source)
    filename = "#{File.basename(source, '.skp')} (SU 20#{SU_VERSION}).skp"

    UI.savepanel(title, directory, filename)
  end

  # Run system call without flashing command line window on Windows.
  # Runs asynchronously.
  # Windows only hack.
  #
  # @param cmd String.
  #
  # @return [Void].
  def self.system_call(cmd)
    # HACK: Run the command through a VBS script to avoid flashing command line
    # window.
    file = Tempfile.new(["cmd", ".vbs"])
    file.write("Set WshShell = CreateObject(\"WScript.Shell\")\n")
    file.write("WshShell.Run \"#{cmd.gsub('"', '""')}\", 0\n")
    file.close
    UI.openURL("file://#{file.path}")

    nil
  end

  # Run block once a file has been created.
  #
  # @param path [String]
  # @param async [Boolean]
  # @param delay [Flaot]
  # @param block [Proc]
  #
  # @return [Void]
  def self.on_exist(path, async = true, delay = 0.2, &block)
    if File.exist?(path)
      block.call
      return
    end

    if async
      UI.start_timer(delay) { on_exist(path, async, delay, &block) }
    else
      sleep(delay)
      on_exist(path, async, delay, &block)
    end

    nil
  end

  # Convert an external model to the current SU version and open it.
  #
  # @param source [String]
  # @param target [String]
  #
  # @return [Void]
  def self.convert_and_open(source, target)
    Sketchup.status_text = "Converting model to supported format..."

    # Since the hack for running the system command without a flashing window
    # makes the call asynchronous, we need to wait to open the converted model
    # until its file exists. To check for file creation, we must first make sure
    # there is no existing file by the same name already.
    File.delete(target) if File.exist?(target)

    system_call(%("#{PLUGIN_DIR}/bin/ConvertVersion" "#{source}" "#{target}" #{SU_VERSION}))
    on_exist(target, false) { Sketchup.open_file(target) }

    nil
  end

  # Ask for path to open, convert if needed and open.
  #
  # @return [Void]
  def self.open_newer_version
    source = prompt_source_path || return
    if version(source).to_i <= Sketchup.version.to_i
      Sketchup.open_file(source)
      return
    end
    target = prompt_target_path(source) || return
    convert_and_open(source, target)

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
  # @param position [Integer, nil]
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
  # @return [Integer] identifier of menu item.
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
