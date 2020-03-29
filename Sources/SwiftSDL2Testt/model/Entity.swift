import GL

protocol Entity {
    
}

struct Rect: Entity {
    static let vertices = [
        Vertex(x: 0.5,  y: 0.5, z: -0.5, r: 0.0, g: 1.0, b: 1.0, a: 0.2, s: 1, t: 1),  // top right
        Vertex(x: 0.5, y: -0.5, z: -0.5, r: 1.0, g: 0, b: 1.0, a: 0.7, s: 1, t: 0),  // bottom right
        Vertex(x: -0.5, y: -0.5, z: 0.0, r: 1, g: 0, b: 0, a: 0.5, s: 0, t: 0),  // bottom left
        Vertex(x: -0.5, y:  0.5, z: 0.0, r: 1, g: 0.5, b: 0.5, a: 0.5, s: 0, t: 1)  // top left 0
    ]

    static let indices: [GL.UInt] = [
        0, 1, 3,
        1, 2, 3
    ]

    static let TEXTURE_WIDTH = 200
    static let TEXTURE_HEIGHT = 200
    var texture: [GL.UByte]

    var transform = TransformationMatrix()

    var size: (width: Int, height: Int) {
        didSet {
            transform.scaling[0] = Float(size.width)
            transform.scaling[1] = Float(size.height)
        }
    }

    init(width: Int = 1, height: Int = 1) {
        size = (width: width, height: height)
        texture = [GL.UByte](repeating: 0, count: Rect.TEXTURE_WIDTH * Rect.TEXTURE_HEIGHT * 3)
        for pixelIndex in 0..<Int(Rect.TEXTURE_WIDTH * Rect.TEXTURE_HEIGHT) {
            texture[pixelIndex * 3] = GL.UByte(255 - ((pixelIndex * 3) % 255))
            texture[pixelIndex * 3 + 1] = GL.UByte(pixelIndex % 255)
            texture[pixelIndex * 3 + 2] = GL.UByte(pixelIndex % Rect.TEXTURE_WIDTH / Rect.TEXTURE_WIDTH * 255)
        }
    }
}