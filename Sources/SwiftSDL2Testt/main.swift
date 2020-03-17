import CSDL2
import SDL
import GL

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

func main() throws {
    
    var isRunning = true
    
    try SDL.initialize(subSystems: [.video])
    
    defer { SDL.quit() }
    
    let windowSize = (width: 600, height: 480)
    
    let window = try SDLWindow(title: "SDLDemo",
                               frame: (x: .centered, y: .centered, width: windowSize.width, height: windowSize.height),
                               options: [.resizable, .shown, .opengl])
    
    let context = try SDLGLContext(window: window)

    glMatrixMode(GL.PROJECTION)
    glLoadIdentity()
    glMatrixMode(GL.MODELVIEW)
    glLoadIdentity()

    glViewport(x: 0, y: 0, width: GL.Size(windowSize.width), height: GL.Size(windowSize.height)) //t(0, 0, windowSize.width, windowSize.height)
    glClearColor(0.0, 0.0, 0.0, 1.0)
    glClear(GL.COLOR_BUFFER_BIT);

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
    let framesPerSecond = try window.displayMode().refreshRate

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
        

        glClear(GL.COLOR_BUFFER_BIT)

        glBegin(GL.QUADS)
        glVertex2f( -0.5, -0.5 )
        glVertex2f(  0.5, -0.5 )
        glVertex2f(  0.5,  0.5 )
        glVertex2f( -0.5,  0.5 )
        glEnd()

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
        print("HERE")

        window.glSwap()

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