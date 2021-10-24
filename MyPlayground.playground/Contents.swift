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

