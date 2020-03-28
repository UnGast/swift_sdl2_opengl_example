import GL

protocol Entity {
    
}

struct Rect: Entity {
    static let vertices = [
        Vertex(x: 0.5,  y: 0.5, z: 0.0, r: 0.0, g: 1.0, b: 1.0, a: 0.2, s: 1, t: 1),  // top right
        Vertex(x: 0.5, y: -0.5, z: 0.0, r: 1.0, g: 0, b: 1.0, a: 0.7, s: 1, t: 0),  // bottom right
        Vertex(x: -0.5, y: -0.5, z: 0.0, r: 1, g: 0, b: 0, a: 0.5, s: 0, t: 0),  // bottom left
        Vertex(x: -0.5, y:  0.5, z: 0.0, r: 1, g: 0.5, b: 0.5, a: 0.5, s: 0, t: 1)  // top left 0
    ]

    static let indices: [GL.UInt] = [
        0, 1, 3,
        1, 2, 3
    ]

    static let textureWidth = 200
    static let textureHeight = 200
    static let textureData = { () -> [GL.UByte] in 
        var data = [GL.UByte](repeating: 0, count: textureWidth * textureHeight * 3)
        for pixelIndex in 0..<(textureWidth * textureHeight) {
            data[pixelIndex * 3] = 255
            data[pixelIndex * 3 + 1] = 0
            data[pixelIndex * 3 + 2] = 15
        }
        return data
    }()

    var transform = TransformationMatrix()

    var size: (width: Float, height: Float) {
        didSet {
            transform.scale[0] = size.width
            transform.scale[1] = size.height
        }
    }

    init(width: Float = 1, height: Float = 1) {
        self.size = (width: width, height: height)
    }
}