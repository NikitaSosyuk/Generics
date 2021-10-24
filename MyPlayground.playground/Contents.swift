import Foundation

// MARK: - Protocol Queueable with associatedType

protocol Queueable {
    associatedtype Element

    var head: Element? { get }
    var tip: Element? { get }
    var isEmpty: Bool { get }
    var count: Int { get }

    mutating func enqueue(_ element: Element)
    @discardableResult mutating func dequeue() -> Element?
}

// MARK: - Implementation of Queueable protocol

public struct Queue<T>: Queueable {
    // мне так больше нравится, когда явно пишем
    typealias Element = T

    private var _array = [T]()

    public var isEmpty: Bool {
        _array.isEmpty
    }

    public var count: Int {
        _array.count
    }

    public mutating func enqueue(_ element: T) {
        _array.append(element)
    }

    public mutating func dequeue() -> T? {
        isEmpty ? nil : _array.remove(at: 0)
    }

    public var head: T? {
        _array.first
    }

    public var tip: T? {
        _array.last
    }
}

extension Queue where T: Equatable {
    func contains(element: T) -> Bool {
        _array.contains(where: { $0 == element })
    }
}

extension Queue where T == Task {
    mutating func executeAll() {
        _array.forEach { $0.execute() }
        _array.removeAll()
    }

    func contains(identifier: String) -> Bool {
        _array.contains(Task(identifier: identifier))
    }
}

// MARK: - Example of element in queue

struct Task {
    let identifier: String

    func execute() {
        print("""
              My identifier is \(identifier).
                - I'm done, bye!
              """)
    }
}

extension Task: Equatable {
    static func ==(lhs: Task, rhs: Task) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}

// MARK: - Use Example

let tasks  = [
    Task(identifier: "🐶"),
    Task(identifier: "🐱"),
    Task(identifier: "🐰"),
    Task(identifier: "🐻"),
    Task(identifier: "🐼"),
    Task(identifier: "🦁"),
    Task(identifier: "🐨"),
    Task(identifier: "🐷")
]

var taskQueue = Queue<Task>()
tasks.forEach { taskQueue.enqueue($0) }

print("Does queue empty? \(taskQueue.isEmpty)\n")
print("Count of elements = \(taskQueue.count)\n")
print("Head = \(taskQueue.head!)\n") // тут я уверен, что не nil 😅
print("Tip = \(taskQueue.tip!)\n") // тут я уверен, что не nil 😅
print("Does queue contains Task with identifier 🐰?  \(taskQueue.contains(identifier: "🐰")) \n")

taskQueue.contains(element: tasks[2])

let firstTask = taskQueue.dequeue()

taskQueue.executeAll()

firstTask?.execute()

// MARK: - Type Erasure

protocol ValueValidator {
    associatedtype Value
    func isValid(_ value: Value) -> Bool
}

private class _AnyValueValidator<Value>: ValueValidator {
    func isValid(_ value: Value) -> Bool {
        assertionFailure("Dude, this method is abstract")
        return false
   }
}

private class _ValidatorBox<Base: ValueValidator>: _AnyValueValidator<Base.Value> {
   private let _base: Base

   init(_ base: Base) {
      _base = base
   }

   override func isValid(_ value: Value) -> Bool {
      return _base.isValid(value)
   }
}

struct AnyValueValidator<Value>: ValueValidator {
    private let _box: _AnyValueValidator<Value>

    init<ValidatorType: ValueValidator>(_ validator: ValidatorType) where ValidatorType.Value == Value {
        _box = _ValidatorBox(validator)
    }

    func isValid(_ value: Value) -> Bool {
        return _box.isValid(value)
    }
}

class StringValidator: ValueValidator {
    typealias Value = String

    private let reference = "Nikita Sosyuk 🦦"

    func isValid(_ value: String) -> Bool {
        value == reference
    }
}

class ViewController {
    var label: String = "Empty"

    var validator: AnyValueValidator<String>!
}

let vc = ViewController()
vc.validator = AnyValueValidator(StringValidator())

vc.validator.isValid(vc.label)
vc.label = "Nikita Sosyuk 🦦"
vc.validator.isValid(vc.label)
