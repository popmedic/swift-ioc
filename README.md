# swift-ioc

swift-injector is an Inverstion of Control class for managing dependencies.  This container can be used to store objects and functions that can then be used for dependency management and invert the control.

## Distribution

Swift Package Management.

## Usage

```
import ioc

let ioc = IoC()

ioc.set(Object()) // register an object as a singleton

let object: Object! = ioc.get() // retrieve the object as a singleton

ioc.set(Object.init) // register a factory function for creating an object

let instanciate: (() -> Object)? = ioc.get() // retrieve the factory function for object

let object = instanciate?()
```
