Creational 

### Singleton
Intent:
Ensure a class only has one instance, and provide a global point of access to it.

start - Prototype and Problem Definition
second - Conventional Implemention of Singleton in Node
final - Node's own Singleton Implementation

### Prototype
Intent:
Specify the kinds of object to create using prototypical instance, and create new
objects by copying this prototype.

start - Prototype and Problem Definition
final - Implementation of a prototype and clone methods

** clone **: Get prototype(definition) of the classs, clone the prototype and copy the attributes.

### Factory
Intent:
Define an interface for createing an object, but let subclasses decide which class to instantiate.
Factory method lets a class defer instantiation to subclasses.

start - Protoype and Problem Definition
final - Factory implementation, check payDay method.

### Builder
Intent:
Separate the construction of a complex object from its representation so that the same construction process can create different representaions.
This is to solve the "Anti Pattern" telescoping constructors.

start - Prototype and Problem Definition
final - Wow, builder is building the object.