# 📘 Day 9: Abstract Classes, Interfaces & Contracts

> [!NOTE]
> **Summary:** Learn how Dart defines abstractions and contracts through abstract classes & members, implicit interfaces, implements, interface classes, and abstract interface classes, and how these mechanisms support polymorphism and production-level separation between application logic and concrete implementations.

**Tags:** `Dart`, `OOP`, `Abstraction`, `Abstract Class`, `Abstract Methods`, `Interfaces`, `Contracts`, `implements`, `interface class`, `abstract interface class`, `Polymorphism`, `Dependency Inversion`

---

## 🚦 Prerequisites
You should understand classes, objects, constructors, encapsulation, private members, getters, setters, instance members, static members, inheritance, extends, super, constructor forwarding, method overriding, @override, polymorphism, static type vs runtime type, is, as, and composition.

## 📖 Overview
Abstraction is an object-oriented design concept where a type exposes the behavior that consumers need while hiding implementation details that consumers should not depend on.

For example, a payment system can expose:

```dart
abstract interface class PaymentGateway {
  Future<void> pay(double amount);
}
```

## 📚 Topics Covered
* **What Is Abstraction?**: Abstraction is an object-oriented design concept where a type exposes the behavior that consumers need while hiding implementation details that con...
* **Why Does Abstraction Exist?**: Abstraction exists to solve problems such as:
* **Abstraction vs Encapsulation**: These concepts are related but different.
* **What Is an Abstract Class?**: An abstract class is declared using the `abstract` modifier.
* **Why Does an Abstract Class Exist?**: An abstract class is useful when a type should represent a common abstraction but should not itself be directly constructed.
* **Abstract Classes Can Contain Concrete Members**: An abstract class does not mean that every member must be abstract.
* **What Is an Abstract Method?**: An abstract method declares required behavior without providing an implementation.
* **Abstract Class Constructors**: Abstract classes can have constructors.
* **What Is an Interface in Dart?**: An interface in **Object-Oriented Programming** (OOP) is a formal contract or blueprint that defines a specific set of signatures for methods, prop...
* **What Does `implements` Mean?**: `implements` establishes a contract relationship.
* **`extends` vs `implements`**: | **Feature** | **extends** (Inheritance) | **implements** (Interface) |
* **Interfaces Do Not Mean Multiple Superclass Inheritance**: A Dart class has one superclass.
* **What Is a Contract?**: A contract defines what an implementation promises to provide.
* **What Is `interface class`?**: Dart provides the `interface` class modifier.
* **What Is `abstract interface class`?**: Dart also provides:
* **Why Use an Explicit Interface Contract?**: Consider:
* **Polymorphism Through Interfaces**: Interfaces can be used as polymorphic types.
* **Why This Improves Testability**: Production:
* **Abstraction and Dependency Inversion**: The language-level abstraction introduced here supports a larger architectural principle.
* **Interface Segregation**: Contracts should represent focused responsibilities.
* **Abstraction vs Composition**: Abstraction defines a contract.
* **Flutter Relationship**: Flutter application code uses inheritance for framework specialization and can use interfaces for application architecture.
* **Internal Architecture**: Internal explanations must distinguish three levels.
* **Memory Implications**: An abstraction does not automatically create a separate runtime object.
* **Performance Implications**: Do not select abstract classes or interfaces based on speculative micro-optimizations.
* **Important Design Boundary**: Not every class needs an interface.

## 💡 Additional Materials Included
* **15 Interview Questions** included
* **Comparisons:** Choose an Abstract Class When, Choose an Interface When, Choose Composition When, Avoid Abstraction When
* **Common Mistakes & Optimizations** included
* **Architecture Implementation Notes** included

> [!TIP]
> **Deep Dive:** To read the full theory, view detailed code implementations, architectures, and common interview questions, open this lesson interactively inside the **Flutter AI Tutor App**!
