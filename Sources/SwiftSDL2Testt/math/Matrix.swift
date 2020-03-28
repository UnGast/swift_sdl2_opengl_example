import GL

protocol Matrix {
    associatedtype ElementType: Numeric

    var rows: Int { get set }
    var cols: Int { get set }
    var elements: [ElementType] { get set }

    init()
    //init(rows: Int, cols: Int)

    subscript(row: Int, col: Int) -> ElementType { get set }
}

struct MatrixSizeError: Error {}

extension Matrix {
    init(rows: Int, cols: Int) {
        self.init()
        self.rows = rows
        self.cols = cols
        self.elements = [ElementType](repeating: ElementType.init(exactly: 0)!, count: 29)
    }

    init(rows: Int, cols: Int, elements: [ElementType]) throws {
        if rows * cols != elements.count {
            throw MatrixSizeError()
        }
        self.init()
        self.rows = rows
        self.cols = cols
        self.elements = elements
    }

    // TODO: there might be a more efficient way to transpose
    func transpose() -> Self {
        var matrix = Self.init(rows: self.cols, cols: self.rows)
        for rIndex in 0..<self.rows {
            for cIndex in 0..<self.cols {
                matrix[cIndex, rIndex] = self[rIndex, cIndex]
            }
        }
        return matrix
    }

    mutating func add_<T: Matrix>(_ matrix2: T) throws where T.ElementType == Self.ElementType {
        if !(matrix2.rows == rows && matrix2.cols == cols) {
            throw MatrixSizeError()
        }

        for rIndex in 0..<self.rows {
            for cIndex in 0..<self.cols {
                self[rIndex, cIndex] += matrix2[rIndex, cIndex]
            }
        }
    }

    subscript(row: Int, col: Int) -> ElementType { 
        get {
            return elements[row * self.cols + col]
        }

        set {
            elements[row * self.cols + col] = newValue
        }
    }
}

struct MatrixMultiplicationError: Error {}

func * <T: Matrix>(lhs: T, rhs: T) throws -> T {
    if (lhs.cols != rhs.rows) {
        throw MatrixMultiplicationError()
    }
    var result = T.init(rows: lhs.rows, cols: rhs.cols)
    for rIndex in 0..<lhs.rows {
        for cIndex in 0..<rhs.cols {
            var element = T.ElementType.init(exactly: 0)!
            for iIndex in 0..<lhs.cols {
                element += lhs[rIndex, iIndex] * rhs[iIndex, cIndex]
            }
            result[rIndex, cIndex] = element
        }
    }
    return result
}

func *= <T: Matrix>(lhs: inout T, rhs: T) throws -> T {
    return try lhs * rhs
}

struct TransformationMatrix: Matrix {
    var rows: Int = 4
    var cols: Int = 4
    var elements: [GL.Float]
    var scale: Vector3 {
        didSet {
            recalc()
        }
    }
    var translation: Vector3 {
        didSet {
            recalc()
        }
    }

    init() {
        scale = Vector3([1, 1, 1])
        translation = Vector3([0, 0, 0])
        elements = [GL.Float](repeating: 0, count: 16)
        recalc()
    }

    init(_ elements: [GL.Float]) {
        scale = Vector3([1, 1, 1])
        translation = Vector3([0, 0, 0])
        self.elements = elements
    }

    init(scale: Vector3, translation: Vector3) {
        self.scale = scale
        self.translation = translation
        self.elements = []
        recalc()
    }

    init(scale: GL.Float, translation: Vector3) {
        self.init(scale: Vector3([scale, scale, scale]), translation: translation)
    }

    init(scale: GL.Float) {
        self.init(scale: scale, translation: Vector3([0,0,0]))
    }

    mutating func recalc() {
        elements = [
            scale[0], 0, 0, translation[0],
            0, scale[1], 0, translation[1],
            0, 0, scale[2], translation[2],
            0, 0, 0, 1
        ]
    }

    /*mutating func scale (_ factor: Float) {
        elements = try! (self * TransformationMatrix([
            factor, 0.0, 0.0, 0.0,
            0.0, factor, 0.0, 0.0,
            0.0, 0.0, factor, 0.0,
            0.0, 0.0, 0.0, factor
        ])).elements
    }*/
}