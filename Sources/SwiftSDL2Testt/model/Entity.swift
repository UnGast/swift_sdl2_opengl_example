import GL

class Entity: Hashable {
    var vertices: [Vertex] = []
    var indices: [GL.UInt]?
    var textureWidth: Int?
    var textureHeight: Int?
    var texture: [GL.UByte]?
    var transform: TransformationMatrix = TransformationMatrix()

    func hash(into hasher: inout Hasher) {
        vertices.withUnsafeBytes { hasher.combine(bytes: $0) }
        transform.elements.withUnsafeBytes { hasher.combine(bytes: $0) }
    }

    static func == (lhs: Entity, rhs: Entity) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}

class Rect: Entity {
    var size: (width: Int, height: Int) {
        didSet {
            transform.scaling[0] = Float(size.width)
            transform.scaling[1] = Float(size.height)
        }
    }

    init(width: Int = 1, height: Int = 1) {
        size = (width: width, height: height)
        super.init()

        vertices = [
            Vertex(x: 0.5,  y: 0.5, z: -0.5, r: 0.0, g: 1.0, b: 1.0, a: 0.2, s: 1, t: 1),  // top right
            Vertex(x: 0.5, y: -0.5, z: -0.5, r: 1.0, g: 0, b: 1.0, a: 0.7, s: 1, t: 0),  // bottom right
            Vertex(x: -0.5, y: -0.5, z: 0.0, r: 1, g: 0, b: 0, a: 0.5, s: 0, t: 0),  // bottom left
            Vertex(x: -0.5, y:  0.5, z: 0.0, r: 1, g: 0.5, b: 0.5, a: 0.5, s: 0, t: 1)  // top left 0
        ]

        indices = [
            0, 1, 3,
            1, 2, 3
        ]

        textureWidth = 200
        textureHeight = 200
        texture = [GL.UByte](repeating: 0, count: textureWidth! * textureHeight! * 3)
        for pixelIndex in 0..<Int(textureWidth! * textureHeight!) {
            texture![pixelIndex * 3] = GL.UByte(255 - ((pixelIndex * 3) % 255))
            texture![pixelIndex * 3 + 1] = GL.UByte(pixelIndex % 255)
            texture![pixelIndex * 3 + 2] = GL.UByte(pixelIndex % textureWidth! / textureWidth! * 255)
        }
    }
}

class Cube: Entity {
    override init() {
        super.init()
        vertices = [
    Vertex(x: -0.5, y: -0.5, z: -0.5, r: 255, g: 0, b: 70, a: 0, s: 0.0, t: 0.0),
    Vertex(x: 0.5, y: -0.5, z: -0.5, r: 255, g: 0, b: 70, a: 0, s: 1.0, t: 0.0),
    Vertex(x: 0.5, y: 0.5, z: -0.5, r: 255, g: 0, b: 70, a: 0, s: 1.0, t: 1.0),
    Vertex(x: 0.5, y: 0.5, z: -0.5, r: 255, g: 0, b: 70, a: 0, s: 1.0, t: 1.0),
    Vertex(x: -0.5, y: 0.5, z: -0.5, r: 255, g: 0, b: 70, a: 0, s: 0.0, t: 1.0),
    Vertex(x: -0.5, y: -0.5, z: -0.5, r: 255, g: 0, b: 70, a: 0, s: 0.0, t: 0.0),

    Vertex(x: -0.5, y: -0.5, z: 0.5, r: 255, g: 0, b: 70, a: 0, s: 0.0, t: 0.0),
    Vertex(x: 0.5, y: -0.5, z: 0.5, r: 255, g: 0, b: 70, a: 0, s: 1.0, t: 0.0),
    Vertex(x: 0.5, y: 0.5, z: 0.5, r: 255, g: 0, b: 70, a: 0, s: 1.0, t: 1.0),
    Vertex(x: 0.5, y: 0.5, z: 0.5, r: 255, g: 0, b: 70, a: 0, s: 1.0, t: 1.0),
    Vertex(x: -0.5, y: 0.5, z: 0.5, r: 255, g: 0, b: 70, a: 0, s: 0.0, t: 1.0),
    Vertex(x: -0.5, y: -0.5, z: 0.5, r: 255, g: 0, b: 70, a: 0, s: 0.0, t: 0.0),

    Vertex(x: -0.5, y: 0.5, z: 0.5, r: 255, g: 0, b: 70, a: 0, s: 1.0, t: 0.0),
    Vertex(x: -0.5, y: 0.5, z: -0.5, r: 255, g: 0, b: 70, a: 0, s: 1.0, t: 1.0),
    Vertex(x: -0.5, y: -0.5, z: -0.5, r: 255, g: 0, b: 70, a: 0, s: 0.0, t: 1.0),
    Vertex(x: -0.5, y: -0.5, z: -0.5, r: 255, g: 0, b: 70, a: 0, s: 0.0, t: 1.0),
    Vertex(x: -0.5, y: -0.5, z: 0.5, r: 255, g: 0, b: 70, a: 0, s: 0.0, t: 0.0),
    Vertex(x: -0.5, y: 0.5, z: 0.5, r: 255, g: 0, b: 70, a: 0, s: 1.0, t: 0.0),

    Vertex(x: 0.5, y: 0.5, z: 0.5, r: 255, g: 0, b: 70, a: 0, s: 1.0, t: 0.0),
    Vertex(x: 0.5, y: 0.5, z: -0.5, r: 255, g: 0, b: 70, a: 0, s: 1.0, t: 1.0),
    Vertex(x: 0.5, y: -0.5, z: -0.5, r: 255, g: 0, b: 70, a: 0, s: 0.0, t: 1.0),
    Vertex(x: 0.5, y: -0.5, z: -0.5, r: 255, g: 0, b: 70, a: 0, s: 0.0, t: 1.0),
    Vertex(x: 0.5, y: -0.5, z: 0.5, r: 255, g: 0, b: 70, a: 0, s: 0.0, t: 0.0),
    Vertex(x: 0.5, y: 0.5, z: 0.5, r: 255, g: 0, b: 70, a: 0, s: 1.0, t: 0.0),

    Vertex(x: -0.5, y: -0.5, z: -0.5, r: 255, g: 0, b: 70, a: 0, s: 0.0, t: 1.0),
    Vertex(x: 0.5, y: -0.5, z: -0.5, r: 255, g: 0, b: 70, a: 0, s: 1.0, t: 1.0),
    Vertex(x: 0.5, y: -0.5, z: 0.5, r: 255, g: 0, b: 70, a: 0, s: 1.0, t: 0.0),
    Vertex(x: 0.5, y: -0.5, z: 0.5, r: 255, g: 0, b: 70, a: 0, s: 1.0, t: 0.0),
    Vertex(x: -0.5, y: -0.5, z: 0.5, r: 255, g: 0, b: 70, a: 0, s: 0.0, t: 0.0),
    Vertex(x: -0.5, y: -0.5, z: -0.5, r: 255, g: 0, b: 70, a: 0, s: 0.0, t: 1.0),

    Vertex(x: -0.5, y: 0.5, z: -0.5, r: 255, g: 0, b: 70, a: 0, s: 0.0, t: 1.0),
    Vertex(x: 0.5, y: 0.5, z: -0.5, r: 255, g: 0, b: 70, a: 0, s: 1.0, t: 1.0),
    Vertex(x: 0.5, y: 0.5, z: 0.5, r: 255, g: 0, b: 70, a: 0, s: 1.0, t: 0.0),
    Vertex(x: 0.5, y: 0.5, z: 0.5, r: 255, g: 0, b: 70, a: 0, s: 1.0, t: 0.0),
    Vertex(x: -0.5, y: 0.5, z: 0.5, r: 255, g: 0, b: 70, a: 0, s: 0.0, t: 0.0),
    Vertex(x: -0.5, y: 0.5, z: -0.5, r: 255, g: 0, b: 70, a: 0, s: 0.0, t: 1.0)
        ]
    }
}