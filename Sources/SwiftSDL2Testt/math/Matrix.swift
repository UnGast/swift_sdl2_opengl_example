import Foundation
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
    var scaling: Vector3 {
        didSet {
            recalc()
        }
    }
    var translation: Vector3 {
        didSet {
            recalc()
        }
    }
    var rotationAxis: Vector3 {
        didSet {
            recalc()
        }
    }
    var rotationAngle: Float {
        didSet {
            recalc()
        }
    }

    init() {
        scaling = Vector3([1, 1, 1])
        translation = Vector3([0, 0, 0])
        elements = [GL.Float](repeating: 0, count: 16)
        self.rotationAngle = 0
        self.rotationAxis = Vector3([0,0,0])
        recalc()
    }

    init(_ elements: [GL.Float]) {
        scaling = Vector3([1, 1, 1])
        translation = Vector3([0, 0, 0])
        self.rotationAngle = 0
        self.rotationAxis = Vector3([0,0,0])
        self.elements = elements
    }

    init(
        scaling: Vector3?, translation: Vector3?, rotationAxis: Vector3?, rotationAngle: Float?) {
            self.scaling = scaling ?? Vector3([1, 1, 1])
            self.translation = translation ?? Vector3([0, 0, 0])
            self.rotationAxis = rotationAxis ?? Vector3([0, 0, 0])
            self.rotationAngle = rotationAngle ?? 0
            self.elements = []
            self.recalc()
    }
    /*
    init(scaling: Vector3, translation: Vector3) {
        self.scaling = scaling
        self.translation = translation
        self.rotationAngle = 0
        self.rotationAxis = Vector3([0,0,0])
        self.elements = []
        recalc()
    }

    init(scaling: GL.Float, translation: Vector3) {
        self.init(scaling: Vector3([scaling, scaling, scaling]), translation: translation)
    }

    init(scaling: GL.Float) {
        self.init(scaling: scaling, translation: Vector3([0,0,0]))
    }

    init(translation: Vector3) {
        self.init(scaling: 1, translation: translation)
    }

    /// - Parameters:
    ///     - rotationAngle: The rotation angle must be specified in degrees.
    init(rotationAxis: Vector3, rotationAngle: Float) {
        self.init(scaling: 1, translation: Vector3([0, 0 ,0]))
        self.rotationAxis = rotationAxis
        self.rotationAngle = rotationAngle
    }*/

    mutating func recalc() {
        let ar = rotationAngle / 180 * Float.pi
        let rc = cos(ar)
        let rc1 = 1 - rc
        let rs = sin(ar)
        let ra = rotationAxis
        elements = [
            scaling[0] * (rc + pow(ra[0], 2) * rc1), ra[0] * ra[1] * rc1, ra[0] * ra[2] * rc1 + ra[1] * rs, translation[0],
            ra[1] * ra[0] * rc1 + ra[2] * rs, scaling[1] * (rc + pow(ra[1], 2) * rc1), ra[1] * ra[2] * rc1 - ra[0] * rs, translation[1],
            ra[2] * ra[0] * rc1 - ra[1] * rs, ra[2] * ra[1] * rc1 + ra[0] * rs, scaling[2] * (rc + pow(ra[2], 2) * rc1), translation[2],
            0, 0, 0, 1
        ]
    }

    /*mutating func scaling (_ factor: Float) {
        elements = try! (self * TransformationMatrix([
            factor, 0.0, 0.0, 0.0,
            0.0, factor, 0.0, 0.0,
            0.0, 0.0, factor, 0.0,
            0.0, 0.0, 0.0, factor
        ])).elements
    }*/
}