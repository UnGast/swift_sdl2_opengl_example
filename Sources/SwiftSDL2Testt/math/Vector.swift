import GL

protocol Vector: Matrix {}

extension Vector {
    init(rows: Int) {
        self.init()
        self.rows = rows
        self.cols = 1
    }

    subscript(row: Int) -> ElementType {
        get {
            return elements[row]
        }

        set {
            elements[row] = newValue
        }
    }
}

struct Vector3: Vector {
    var rows: Int
    var cols: Int
    var elements: [GL.Float]

    init() {
        self.rows = 3
        self.cols = 1
        self.elements = [GL.Float](repeating: 0, count: 3)
    }

    init(_ elements: [GL.Float]) {
        self.init()
        self.elements = elements
    }
}