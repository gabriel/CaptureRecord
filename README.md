CaptureRecord
===============

For installation and usage instructions, see http://capturerecord.com

Warning
------
The SDK uses a private function UIGetScreenImage to record the screen. It is potentially unsafe and you should only use this for testing or generating videos. Although this private function call is obfuscated, you shouldn't submit apps to the store with this framework included.

Packaging
------
After cloning be sure to recusively update submodules:

    git submodule update --init --recursive

To package the framework yourself, you'll need to install the Real Framework module at https://github.com/kstenerud/iOS-Universal-Framework

License
-------

This is licensed under a dual Cocoa Controls Commercial License (v1) for commercial projects and GPL (v3) for open source projects.
See the LICENSE file for more info.