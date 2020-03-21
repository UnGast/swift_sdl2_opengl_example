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

struct Vertex {
    let x: GL.Float
    let y: GL.Float
    let z: GL.Float
    let r: GL.Float
    let g: GL.Float
    let b: GL.Float
    let a: GL.Float
}

let vertexShaderSource = """
#version 330 core

layout (location = 0) in vec3 aPos;
layout (location = 1) in vec4 inColor;

out vec4 fragColor;

void main()
{
    gl_Position = vec4(aPos.x, aPos.y, aPos.z, 1.0);
    fragColor = inColor;
}
"""

let fragmentShaderSource = """
#version 330 core
uniform vec4 color;
in vec4 fragColor;
out vec4 FragColor;

void main()
{
    FragColor = fragColor + color; // vec4(1.0f, 0.5f, 0.2f, 1.0f);
}
"""

let vertices: [Vertex] = [
    Vertex(x: 0.5,  y: 0.5, z: 0.0, r: 0.0, g: 1.0, b: 1.0, a: 1.0),  // top right
    Vertex(x: 0.5, y: -0.5, z: 0.0, r: 1.0, g: 0, b: 1.0, a: 1.0),  // bottom right
    Vertex(x: -0.5, y: -0.5, z: 0.0, r: 1, g: 0, b: 0, a: 1),  // bottom left
    Vertex(x: -0.5, y:  0.5, z: 0.0, r: 1, g: 0.5, b: 0.5, a: 1)  // top left 0
]
/*let vertices: [GL.Float] = [
    // positions         // colors
     0.5, -0.5, 0.0,  1.0, 0.0, 0.0,   // bottom right
    -0.5, -0.5, 0.0,  0.0, 1.0, 0.0,   // bottom left
     0.0,  0.5, 0.0,  0.0, 0.0, 1.0    // top 
]*/
let indices: [GL.UInt] = [
    0, 1, 3,
    1, 2, 3
]

print(MemoryLayout<GL.Float>.size, MemoryLayout<GL.Float>.stride, MemoryLayout<Vertex>.size, MemoryLayout<Vertex>.stride)

func main() throws {
    
    var isRunning = true
    
    try SDL.initialize(subSystems: [.video])
    
    defer { SDL.quit() }
    
    let windowSize = (width: 600, height: 480)

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
    glBufferData(GL.ARRAY_BUFFER, vertices.count * MemoryLayout<Vertex>.stride, vertices, GL.STATIC_DRAW)

    glBindBuffer(GL.ELEMENT_ARRAY_BUFFER, EBO)
    glBufferData(GL.ELEMENT_ARRAY_BUFFER, indices.count * MemoryLayout<GL.UInt>.stride, indices, GL.STATIC_DRAW)

    let offset1 = UnsafeRawPointer(bitPattern: 0)
    glVertexAttribPointer(
        index: GL.UInt(0),
        size: GL.Int(3),
        type: GL.FLOAT,
        normalized: GL.Bool(false),
        stride: GL.Size(MemoryLayout<Vertex>.stride),
        pointer: offset1)
    //offset1?.deallocate()
    glEnableVertexAttribArray(0)

    let offset2 = UnsafeRawPointer(bitPattern: 3 * MemoryLayout<GL.Float>.stride)
    glVertexAttribPointer(
        index: GL.UInt(1),
        size: GL.Int(4),
        type: GL.FLOAT,
        normalized: GL.Bool(false),
        stride: GL.Size(MemoryLayout<Vertex>.stride),
        pointer: offset2)
    //offset2?.deallocate()
    glEnableVertexAttribArray(1)


    glUseProgram(shaderProgram)
    glBindVertexArray(VAO)
    //glPolygonMode(GL.FRONT_AND_BACK, GL.LINE)

    let uniformColorLocation = glGetUniformLocation(shaderProgram, "color")


    let framesPerSecond = try window.displayMode().refreshRate
    var frame = 0
    var lastFrameTime = SDL_GetTicks()
    var totalTime: UInt32 = 0
    var event = SDL_Event()

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
                    glViewport(x: 0, y: 0, width: GL.Size(event.window.data1), height: GL.Size(event.window.data2)) //t(0, 0, windowSize.width, windowSize.height)
                }
            default:
                break
        }
        
        glClearColor(0.2, 0.3, 0.3, 1.0)
        glClear(GL.COLOR_BUFFER_BIT)
        
        glUniform4f(uniformColorLocation, 0.0, (Float(sin(Float(totalTime) / 1000 * 1 * Float.pi)) + 1.0) / 2, 0.0, 1.0)
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