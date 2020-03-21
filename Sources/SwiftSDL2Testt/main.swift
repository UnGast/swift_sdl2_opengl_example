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

layout (location = 0) in vec3 aPos;

void main()
{
    gl_Position = vec4(aPos.x, aPos.y, aPos.z, 1.0);
}
"""

let fragmentShaderSource = """
#version 330 core
out vec4 FragColor;

void main()
{
    FragColor = vec4(1.0f, 0.5f, 0.2f, 1.0f);
}
"""

let vertices: [Float] = [
    -0.5, -0.5, 0.0,
     0.5, -0.5, 0.0,
     0.0,  0.5, 0.0
]

func main() throws {
    
    var isRunning = true
    
    try SDL.initialize(subSystems: [.video])
    
    defer { SDL.quit() }
    
    let windowSize = (width: 600, height: 480)

    let window = try SDLWindow(title: "SDLDemo",
                               frame: (x: .centered, y: .centered, width: windowSize.width, height: windowSize.height),
                               options: [.resizable, .shown, .opengl])
    
    let framesPerSecond = try window.displayMode().refreshRate

    var frame = 0
    
    var event = SDL_Event()
    
    var needsDisplay = true


    let context = try SDLGLContext(window: window)

    /*glMatrixMode(GL.PROJECTION)
    glLoadIdentity()
    glMatrixMode(GL.MODELVIEW)
    glLoadIdentity()*/
    glViewport(x: 0, y: 0, width: GL.Size(windowSize.width), height: GL.Size(windowSize.height)) //t(0, 0, windowSize.width, windowSize.height)

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
    /*glClearColor(0.0, 0.0, 0.0, 1.0)
    glClear(GL.COLOR_BUFFER_BIT)*/

    print("ERROR?: ", glGetError())

    /*
    glPushMatrix() //Make sure our transformations don't affect any other transformations in other code
    glTranslatef(5, 5, 0.0) //Translate rectangle to its assigned x and y position
    //Put other transformations here
    glBegin(GL.QUADS) //We want to draw a quad, i.e. shape with four sides
    glColor3f(1, 1, 0)//Set the colour to red 
    glVertex2f(0, 0)         //Draw the four corners of the rectangle
    glVertex2f(0, 100)
    glVertex2f(100, 100)
    glVertex2f(100, 0)
    glEnd()
    glPopMatrix()*/

    // window.glSwap()

    var VAO = GL.UInt()
    withUnsafeMutablePointer(to: &VAO) { ptr in glGenVertexArrays(1, ptr) }
    var VBO = GL.UInt()
    withUnsafeMutablePointer(to: &VBO) { ptr in glGenBuffers(1, ptr) }

    glBindVertexArray(VAO)

    glBindBuffer(GL.ARRAY_BUFFER, VBO)
    glBufferData(GL.ARRAY_BUFFER, vertices.count * MemoryLayout<Float>.stride, vertices, GL.STATIC_DRAW)

    let offset = UnsafeRawPointer.init(bitPattern: 0)
    glVertexAttribPointer(index: GL.UInt(0), size: GL.Int(3), type: GL.FLOAT, normalized: GL.Bool(false), stride: GL.Size(3 * MemoryLayout<GL.Float>.stride), pointer: offset)
    // glVertexAttribPointer(index: GL.UInt, size: GL.Int, type: GL.Enum, normalized: GL.Bool, stride: GL.Size, pointer: UnsafeRawPointer?)
    glEnableVertexAttribArray(0)

    glBindVertexArray(VAO)

    /*var VAO = GL.UInt()
    withUnsafeMutablePointer(to: &VAO) { ptr in glGenVertexArrays(1, ptr) }

    glBindVertexArray(VAO)
    glBindBuffer(GL.ARRAY_BUFFER, VBO)



*/

    //SDL_Delay(4000)

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
                    glViewport(x: 0, y: 0, width: GL.Size(event.window.data1), height: GL.Size(event.window.data2)) //t(0, 0, windowSize.width, windowSize.height)
                    needsDisplay = true
                }
            default:
                break
        }
        
        glClearColor(0.2, 0.3, 0.3, 1.0)
        glClear(GL.COLOR_BUFFER_BIT)

        glUseProgram(shaderProgram)
        glBindVertexArray(VAO)
        glDrawArrays(GL.TRIANGLES, 0, 3)

        window.glSwap()

        //glBindBuffer(GL.ARRAY_BUFFER, VBO)
        //glBufferData(GL.ARRAY_BUFFER, MemoryLayout<[Double]>.size(ofValue: vertices),)
        //glDrawArrays(GL.TRIANGLES, 0, 3);

        //glBegin(GL.TRIANGLES)
        /*for vertex in vertices {
            glVertex2f(vertex)
        }*/
        /*
        glVertex2f(-0.5, -0.5)
        glVertex2f(0.5 + Float(frame % 50) * 0.01, -0.5)
        glVertex2f(0.5,  0.5)
        glVertex2f(-0.5,  0.5)*/
        //glEnd()

        //glPushMatrix() //Make sure our transformations don't affect any other transformations in other code
        /*glTranslatef(10, 100, 0.0) //Translate rectangle to its assigned x and y position
        //Put other transformations here
        glBegin(GL.QUADS) //We want to draw a quad, i.e. shape with four sides
        glColor3f(1, 1, 0)//Set the colour to red 
        glVertex2f(0, 0)         //Draw the four corners of the rectangle
        glVertex2f(0, 100)
        glVertex2f(100, 100)
        glVertex2f(100, 0)
        glEnd()*/
        //glPopMatrix()
        // print("HERE")

        //window.glSwap()

        // sleep to save energy
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