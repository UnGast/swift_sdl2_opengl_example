import GL

struct ShaderError: Error {
    let info: String

    init(_ info: String) {
        self.info = info
    }
}

struct Shader {
    let vertexSource: String
    let fragmentSource: String
    var id: GL.UInt?

    /// compiles and links the shaders
    mutating func compile() throws {
        let vertexShader = glCreateShader(GL.VERTEX_SHADER)
        withUnsafePointer(to: vertexSource) { ptr in glShaderSource(vertexShader, 1, ptr, nil) }
        glCompileShader(vertexShader)

        let success = UnsafeMutablePointer<GL.Int>.allocate(capacity: 1)
        let info = UnsafeMutablePointer<GL.Char>.allocate(capacity: 512)
        glGetShaderiv(vertexShader, GL.COMPILE_STATUS, success)
        if (success.pointee == 0) {
            glGetShaderInfoLog(vertexShader, 512, nil, info)
            throw ShaderError(String(cString: info))
        } else {
            print("Vertex shader successfully compiled.")
        }

        let fragmentShader = glCreateShader(GL.FRAGMENT_SHADER)
        withUnsafePointer(to: fragmentSource) { ptr in glShaderSource(fragmentShader, 1, ptr, nil) }
        glCompileShader(fragmentShader)
        glGetShaderiv(fragmentShader, GL.COMPILE_STATUS, success)
        if (success.pointee == 0) {
            glGetShaderInfoLog(fragmentShader, 512, nil, info)
            throw ShaderError(String(cString: info))
        } else {
            print("Fragment shader successfully compiled.")
        }

        self.id = glCreateProgram()
        glAttachShader(self.id!, vertexShader)
        glAttachShader(self.id!, fragmentShader)
        glLinkProgram(self.id!)

        glGetProgramiv(self.id!, GL.LINK_STATUS, success)
        if (success.pointee == 0) {
            glGetProgramInfoLog(self.id!, 512, nil, info)
            throw ShaderError(String(cString: info))
        } else {
            print("Shader program linked successfully.")
        }

        glDeleteShader(vertexShader)
        glDeleteShader(fragmentShader)
    }
}