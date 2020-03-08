import UIKit

/*:
 ### Hello, my name is Vlad
*/

var str = "Hello, playground"

enum SomeType {
    case none
    case first(String)
    case second(Int)
}

extension SomeType {
    init() {
        self = .none
    }

    init?(_ value: String) {
        self = .first(value)
    }

    init?(_ value: Int) {
        self = .second(value)
    }

}

let a: SomeType = .first("Hello")
let b: SomeType = .second(15)
let c = SomeType()

let strings = [1: "first", 2: "second"]

for (index, string) in strings {
    _ = "\(index) and \(string)"
}
