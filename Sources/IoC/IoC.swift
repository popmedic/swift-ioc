import Foundation

public final class IoC {
    private var storage = [Any]()
    private var access = DispatchQueue(label: "IoC.queue",
                                       attributes: [.concurrent])
    
    public func set<T>(_ element: T) {
        access.async(flags: [.barrier]) {
            self.storage = self.storage.filter { !($0 is T) }
            self.storage.append(element)
        }
    }
    
    public func get<T>() -> T? {
        access.sync {
            storage.filter { $0 is T }.first as? T
        }
    }
    
    public func all<T: Any>() -> [T] {
        return access.sync {
            var res = [T]()
            for i in 0..<storage.count {
                if let value = storage[i] as? T { res.append(value) }
            }
            return res
        }
    }
}
