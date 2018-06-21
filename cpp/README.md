This is my first real C++ project, so please bare with me :P .

This directory contains the C++ part of this extension. If you don't know how to
code or compile C++, and just want to update the Ruby code, feel free to ignore
it and just focus on the SketchUp Ruby extension.

# Set Up Guide

1. Open the Visual Studio solution.

2. Open properties of the ConvertVersion project (right click > Properties).

3. Make sure _All Configurations_ is selected in the Configurations drop down.

4. Update _Configuration Properties > C/C++ > Include Directories_ to to refer
to where the
[SketchUp SDK](https://extensions.sketchup.com/en/developer_center/sketchup_sdk)
headers are located on your machine.

5. Update _Configuration Properties > Linker > Additional Library
Directories_ to refer to where the SketchUp SDK binaries are located on your
machine.

6. Update _Configuration Properties > Build Events > Post-Build Events > Command
line_ to refer to where the Sketchup SDK binaries are on your machine.

# Use updated program in SketchUp Ruby Extension

After building a new ConvertVersion.exe, copy it into src/bin/ to make it a part
of the Ruby extension (yeah, this could be scripted but let's do one thing at a
time).
