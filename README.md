# SDL2 and OpenGL with Swift

dependent on these two packages:

[OpenGL loader written in Swift](https://github.com/kelvin13/swift-opengl.git)

[SDL2 bindings for Swift](https://github.com/PureSwift/SDL)

[A concise path handling library](https://github.com/mxcl/Path.swift.git)

<br>

Tested on Ubuntu 19.10. Latest SDL2 installed. Swift built from [https://github.com/apple/swift/tree/tensorflow](https://github.com/apple/swift/tree/tensorflow)

`swift run` should be enough to start the application.

Note: The program currently relies on the directory structure of the project to load the shader sources. `swift run` must be executed in the root directory of the project.

Output should look like this:

![demo](https://github.com/UnGast/swift_sdl2_opengl_example/blob/master/demo.gif)