import CSDL2
import SDL
import GL
import Foundation

/*print("All Render Drivers:")
let renderDrivers = SDLRenderer.Driver.all
if renderDrivers.isEmpty == false {
    print("=======")
    for driver in renderDrivers {
        
        do {
            let info = try SDLRenderer.Info(driver: driver)
            print("Driver:", driver.rawValue)
            print("Name:", info.name)
            print("Options:")
            info.options.forEach { print("  \($0)") }
            print("Formats:")
            info.formats.forEach { print("  \($0)") }
            if info.maximumSize.width > 0 || info.maximumSize.height > 0 {
                print("Maximum Size:")
                print("  Width: \(info.maximumSize.width)")
                print("  Height: \(info.maximumSize.height)")
            }
            print("=======")
        } catch {
            print("Could not get information for driver \(driver.rawValue)")
        }
    }
}*/
let vertexShaderSource = """
#version 330 core

layout (location = 0) in vec3 position;
layout (location = 1) in vec4 inColor;
layout (location = 2) in vec2 texCoord;

uniform mat4 model;
uniform mat4 view;
uniform mat4 projection;

out vec4 fragColor;
out vec2 TexCoord;

void main()
{
    gl_Position = projection * view * model * vec4(position, 1.0);
    fragColor = inColor;
    TexCoord = texCoord;
}
"""

let fragmentShaderSource = """
#version 330 core

uniform vec4 color;
uniform sampler2D inTexture;

in vec4 fragColor;
in vec2 TexCoord;

out vec4 FragColor;

void main()
{
    FragColor = texture(inTexture, TexCoord); // vec4(1.0f, 0.5f, 0.2f, 1.0f);
}
"""


let viewMatrix = TransformationMatrix(
    scaling: nil,
    translation: Vector3([0, 0, -5]),
    rotationAxis: Vector3([0, 0, 1]),
    rotationAngle: 50)

var projectionMatrix = TransformationMatrix()
func updateProjectionMatrix() {
    let aspectRatio = Float(windowSize.width) / Float(windowSize.height)
    let near = Float(0.1)
    let far = Float(100)
    let fov = Float(45)
    let fovRad = fov / 180 * Float.pi
    
    projectionMatrix = TransformationMatrix([
        1 / (aspectRatio * tan(fovRad / 2)), 0, 0, 0,
        0, 1 / tan(fovRad / 2), 0, 0,
        0, 0, -(far + near) / (far - near), -(2 * far * near) / (far - near),
        0, 0, -1, 0
    ])
    //let uh = 1/tan(fov/2)
    /*let scale = tan(viewAngle * 0.5 * Float.pi / 180) * near; 
    print("SCALE", scale)
    let right = aspectRatio * scale
    print("ASPECT", scale)
    let left = -right; 
    let top = scale;
    let bottom = -top; 
    /*
    let S = 1 / (tan((fov/2) * (Float.PI/180)))
    let v1 = -far/(far - near)
    let v2 = -(far * near)/(far - near)*/
    projectionMatrix = TransformationMatrix([
        (2 * near)/(right - left), 0, (right + left)/(right - left), 0,
        0, 2 * near / (top - bottom), (top + bottom)/(top - bottom), 0,
        0, 0, -(far + near)/(far - near), -(2 * far * near)/(far - near),
        0, 0, -1, 0
    ])*/
    print(projectionMatrix)
}
updateProjectionMatrix()

var rect = Rect()

var windowSize = (width: 600, height: 480)
/*
var globalTransform = TransformationMatrix(
    scale: Vector3([1, 1, 1]), translation: Vector3([0, 0, 0]))

func updateGlobalTransform() {
    var scale: Vector3
    if (windowSize.width > windowSize.height) {
        scale = Vector3([
            GL.Float(windowSize.height) / GL.Float(windowSize.width),
            1,
            1
        ])
    } else {
        scale = Vector3([
            1,
            GL.Float(windowSize.width) / GL.Float(windowSize.height),
            1
        ])
    }
    globalTransform.scale = scale
}
updateGlobalTransform()*/

func main() throws {
    
    var isRunning = true
    
    try SDL.initialize(subSystems: [.video])
    
    defer { SDL.quit() }
    
    let window = try SDLWindow(title: "SDLDemo",
                               frame: (x: .centered, y: .centered, width: windowSize.width, height: windowSize.height),
                               options: [.resizable, .shown, .opengl])

    let context = try SDLGLContext(window: window)

    glViewport(x: 0, y: 0, width: GL.Size(windowSize.width), height: GL.Size(windowSize.height))

    let vertexShader = glCreateShader(GL.VERTEX_SHADER)
    withUnsafePointer(to: vertexShaderSource) { ptr in glShaderSource(vertexShader, 1, ptr, nil) }
    glCompileShader(vertexShader)

    var success = UnsafeMutablePointer<GL.Int>.allocate(capacity: 1)
    var info = UnsafeMutablePointer<GL.Char>.allocate(capacity: 512)
    glGetShaderiv(vertexShader, GL.COMPILE_STATUS, success)
    if (success.pointee == 0) {
        glGetShaderInfoLog(vertexShader, 512, nil, info)
        print("Vertex shader info:\n", String(cString: info))
    } else {
        print("Vertex shader successfully compiled.")
    }

    let fragmentShader = glCreateShader(GL.FRAGMENT_SHADER)
    withUnsafePointer(to: fragmentShaderSource) { ptr in glShaderSource(fragmentShader, 1, ptr, nil) }
    glCompileShader(fragmentShader)
    glGetShaderiv(fragmentShader, GL.COMPILE_STATUS, success)
    if (success.pointee == 0) {
        glGetShaderInfoLog(fragmentShader, 512, nil, info)
        print("Fragment shader info:\n", String(cString: info))
    } else {
        print("Fragment shader successfully compiled.")
    }

    let shaderProgram = glCreateProgram()
    glAttachShader(shaderProgram, vertexShader)
    glAttachShader(shaderProgram, fragmentShader)
    glLinkProgram(shaderProgram)

    glGetProgramiv(shaderProgram, GL.LINK_STATUS, success)
    if (success.pointee == 0) {
        glGetProgramInfoLog(shaderProgram, 512, nil, info)
        print("Shader program info:\n", String(cString: info))
    } else {
        print("Shader program linked successfully.")
    }

    glDeleteShader(vertexShader)
    glDeleteShader(fragmentShader)

    print("ERROR?: ", glGetError())


    var VAO = GL.UInt()
    withUnsafeMutablePointer(to: &VAO) { glGenVertexArrays(1, $0) }
    var VBO = GL.UInt()
    withUnsafeMutablePointer(to: &VBO) { glGenBuffers(1, $0) }
    var EBO = GL.UInt()
    withUnsafeMutablePointer(to: &EBO) { glGenBuffers(1, $0) }

    glBindVertexArray(VAO)

    glBindBuffer(GL.ARRAY_BUFFER, VBO)
    glBufferData(GL.ARRAY_BUFFER, Rect.vertices.count * MemoryLayout<Vertex>.stride, Rect.vertices, GL.STATIC_DRAW)

    glBindBuffer(GL.ELEMENT_ARRAY_BUFFER, EBO)
    glBufferData(GL.ELEMENT_ARRAY_BUFFER, Rect.indices.count * MemoryLayout<GL.UInt>.stride, Rect.indices, GL.STATIC_DRAW)

    glVertexAttribPointer(
        index: GL.UInt(0),
        size: 3,
        type: GL.FLOAT,
        normalized: false,
        stride: GL.Size(MemoryLayout<Vertex>.stride),
        pointer: UnsafeRawPointer(bitPattern: 0))
    glEnableVertexAttribArray(0)

    glVertexAttribPointer(
        index: GL.UInt(1),
        size: 4,
        type: GL.FLOAT,
        normalized: false,
        stride: GL.Size(MemoryLayout<Vertex>.stride),
        pointer: UnsafeRawPointer(bitPattern: 3 * MemoryLayout<GL.Float>.stride))
    glEnableVertexAttribArray(1)

    glVertexAttribPointer(
        index: GL.UInt(2),
        size: 2,
        type: GL.FLOAT,
        normalized: false,
        stride: GL.Size(MemoryLayout<Vertex>.stride),
        pointer: UnsafeRawPointer(bitPattern: 7 * MemoryLayout<GL.Float>.stride))
    glEnableVertexAttribArray(2)

    var texture = GL.UInt()
    withUnsafeMutablePointer(to: &texture) { glGenTextures(1, $0) }
    glBindTexture(GL.TEXTURE_2D, texture)
    glTexParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_S, GL.REPEAT)
    glTexParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_T, GL.REPEAT)
    glTexParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, GL.LINEAR)
    glTexParameteri(GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, GL.LINEAR)
    glTexImage2D(GL.TEXTURE_2D, 0, GL.RGB, GL.Size(Rect.TEXTURE_WIDTH), GL.Size(Rect.TEXTURE_HEIGHT), 0, GL.RGB, GL.UNSIGNED_BYTE, rect.texture)
    glGenerateMipmap(GL.TEXTURE_2D)
    ///glBindVertexArray(0)
    //glBindTexture(GL.TEXTURE_2D, 0)

    print("ERROR?: ", glGetError())

    let uniformModelLocation = glGetUniformLocation(shaderProgram, "model")
    let uniformViewLocation = glGetUniformLocation(shaderProgram, "view")
    let uniformProjectionLocation = glGetUniformLocation(shaderProgram, "projection")
    let uniformColorLocation = glGetUniformLocation(shaderProgram, "color")

    glUseProgram(shaderProgram)
    glActiveTexture(GL.TEXTURE0)
    glBindTexture(GL.TEXTURE_2D, texture)
    glBindVertexArray(VAO)
    //glPolygonMode(GL.FRONT_AND_BACK, GL.LINE)


    let framesPerSecond = try window.displayMode().refreshRate
    var frame = 0
    var lastFrameTime = SDL_GetTicks()
    var totalTime: UInt32 = 0
    var event = SDL_Event()
    var activeKeys = [
        SDL_Keycode(SDLK_DOWN): false,
        SDL_Keycode(SDLK_UP): false,
        SDL_Keycode(SDLK_LEFT): false,
        SDL_Keycode(SDLK_RIGHT): false
    ]

    while isRunning {
        SDL_PollEvent(&event)

        // increment ticker
        frame += 1
        let startTime = SDL_GetTicks()
        let 𝚫time = startTime - lastFrameTime
        lastFrameTime = startTime
        totalTime += 𝚫time
        let eventType = SDL_EventType(rawValue: event.type)
        
        switch eventType {
            case SDL_QUIT, SDL_APP_TERMINATING:
                isRunning = false
            case SDL_WINDOWEVENT:
                if event.window.event == UInt8(SDL_WINDOWEVENT_SIZE_CHANGED.rawValue) {
                    windowSize.width = Int(event.window.data1)
                    windowSize.height = Int(event.window.data2)
                    glViewport(x: 0, y: 0, width: GL.Size(windowSize.width), height: GL.Size(windowSize.height)) //t(0, 0, windowSize.width, windowSize.height)
                    updateProjectionMatrix()
                }
            case SDL_KEYDOWN:
                activeKeys[event.key.keysym.sym] = true
            case SDL_KEYUP:
                activeKeys[event.key.keysym.sym] = false
            default:
                break
        }
        
        let velocity = 0.5 * Float(𝚫time) / 1000
        var velocityChangeVector = Vector3()
        if activeKeys[SDL_Keycode(SDLK_UP)]! {
            velocityChangeVector[1] += velocity
        }
        if activeKeys[SDL_Keycode(SDLK_DOWN)]! {
            velocityChangeVector[1] -= velocity
        }
        if activeKeys[SDL_Keycode(SDLK_LEFT)]! {
            velocityChangeVector[0] -= velocity
        }
        if activeKeys[SDL_Keycode(SDLK_RIGHT)]! {
            velocityChangeVector[0] += velocity
        }
        try? rect.transform.translation.add_(velocityChangeVector)

        glClearColor(0.2, 0.3, 0.3, 1.0)
        glClear(GL.COLOR_BUFFER_BIT)
        
        glUniform4f(uniformColorLocation, 0.0, (Float(sin(Float(totalTime) / 1000 * 1 * Float.pi)) + 1.0) / 2, 0.0, 1.0)
        glUniformMatrix4fv(uniformModelLocation, 1, true, rect.transform.elements)
        glUniformMatrix4fv(uniformViewLocation, 1, true, viewMatrix.elements)
        glUniformMatrix4fv(uniformProjectionLocation, 1, true, projectionMatrix.elements)
        glDrawElements(mode: GL.TRIANGLES, count: 6, type: GL.UNSIGNED_INT, indices: UnsafeRawPointer(bitPattern: 0))

        window.glSwap()

        let frameDuration = SDL_GetTicks() - startTime
        if frameDuration < 1000 / UInt32(framesPerSecond) {
           SDL_Delay((1000 / UInt32(framesPerSecond)) - frameDuration)
        }
    }


    /*let framesPerSecond = try window.displayMode().refreshRate
    
    print("Running at \(framesPerSecond) FPS")
    
    // renderer
    let renderer = try SDLRenderer(window: window)
    
    var frame = 0
    
    var event = SDL_Event()
    
    var needsDisplay = true
    
    while isRunning {
        
        SDL_PollEvent(&event)
        
        // increment ticker
        frame += 1
        let startTime = SDL_GetTicks()
        let eventType = SDL_EventType(rawValue: event.type)
        
        switch eventType {
        case SDL_QUIT, SDL_APP_TERMINATING:
            isRunning = false
        case SDL_WINDOWEVENT:
            if event.window.event == UInt8(SDL_WINDOWEVENT_SIZE_CHANGED.rawValue) {
                needsDisplay = true
            }
        default:
            break
        }
        
        if needsDisplay {
            try renderer.setDrawColor(red: 0xFF, green: 0x00, blue: 0xFF, alpha: 0x00)
            try renderer.clear()
            
            let surface = try SDLSurface(rgb: (0, 0, 0, 0), size: (width: 1, height: 1), depth: 32)
            let color = SDLColor(
                format: try SDLPixelFormat(format: .argb8888),
                red: 255, green: 255, blue: .max, alpha: 0
            )
            try surface.fill(color: color)
            surface.doThing()
            let surfaceTexture = try SDLTexture(renderer: renderer, surface: surface)
            try surfaceTexture.setBlendMode([.alpha])
            try renderer.copy(surfaceTexture, destination: SDL_Rect(x: 100, y: 100, w: 200, h: 200))
            
            // render to screen
            renderer.present()
            
            print("Did redraw screen")
            
            needsDisplay = false
        }
        
        // sleep to save energy
        let frameDuration = SDL_GetTicks() - startTime
        if frameDuration < 1000 / UInt32(framesPerSecond) {
            SDL_Delay((1000 / UInt32(framesPerSecond)) - frameDuration)
        }
    }*/
}

do { try main() }
catch let error as SDLError {
    print("Error: \(error.debugDescription)")
    exit(EXIT_FAILURE)
}
catch {
    print("Error: \(error)")
    exit(EXIT_FAILURE)
}