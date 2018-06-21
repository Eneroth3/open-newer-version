This directory contains the C++ part of this extension. If you don't know how to
code or compile C++, and just want to update the Ruby code, feel free to ignore
it.

# Set Up Guide

1. Open the Visual Studio solution.

2. Open properties of the ConvertVersion project (right click > Properties).

3. Make sure All Configurations is selected in the Configurations drop down.

4. Update _Configuration Properties > C/C++ > Include Directories_ to to refer
to where the
[SketchUp SDK](https://extensions.sketchup.com/en/developer_center/sketchup_sdk)
headers are located on your machine.

5. Update _Configuration Properties > Linker > Additional Library
Directories_ to refer to where the SketchUp SDK binaries are located on your
machine.

6. Update _Configuration Properties > Build Events > Post-Build Events > Command
line_ to refer to where the Sketchup SDK binaries are on your machine.
