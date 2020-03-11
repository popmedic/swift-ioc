import Foundation

/// IoC is for "Inversion of Control"
/// Use the IoC class as a container for storing dependencies.
public final class IoC {
    private var storage = [Any]()
    private var access = DispatchQueue(label: "IoC.queue",
                                       attributes: [.concurrent])

    /// the set function will add a dependecy to the container.
    /// multiple of the same types can be added to the container
    /// - parameters
    ///     - element: the element to add to the container.  elements are appended to
    ///         the end for the storage container, unless a index value is used.
    ///     - index: the index in the storage container to put the element.  If the index is
    ///         greater then the size of the storage is with append instad of inserting at the index
    public func set<T>(_ element: T, index: Int? = nil) {
        access.async(flags: [.barrier]) {
            if let index = index, index < self.storage.count {
                self.storage.insert(element, at: index)
            } else {
                self.storage.append(element)
            }
        }
    }
    
    /// get will get the type based on the value type of the return
    /// - example: ` let foo: Foo? = ioc.get()`
    /// - returns: the first stored element of type ` T`, if non exist then `nil`
    public func get<T>() -> T? {
        access.sync {
            storage.filter { $0 is T }.first as? T
        }
    }
    
    /// all will get all elements of type `T` from the storage container
    /// - returns: all the elements that match type `T`
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
