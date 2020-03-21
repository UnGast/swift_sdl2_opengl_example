import Foundation

for _ in 0...10000000 {
    let wow = UnsafeMutableRawPointer.allocate(byteCount: 32, alignment: 4)
    print(wow)
    wow.deallocate() // if not called, memory of process just grows endlessy
}