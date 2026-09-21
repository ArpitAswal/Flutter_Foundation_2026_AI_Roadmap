# 📘 Day 09: Abstract Classes, Interfaces & Contracts

**Module 02:** [Dart Object-Oriented Programming](../README.md) • **Phase 01:** [Dart Programming Foundation](../../README.md)

> [!NOTE]
> **Lesson Objective:** Learn how Dart defines abstractions and contracts through abstract classes & members, implicit interfaces, implements, interface classes, and abstract interface classes, and how these mechanisms support polymorphism and production-level separation between application logic and concrete implementations.

**Tags:** `Dart` `OOP` `Abstraction` `Abstract Class` `Abstract Methods` `Interfaces` `Contracts` `implements` `interface class` `abstract interface class` `Polymorphism` `Dependency Inversion`

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
* **What Is Abstraction?**: Abstraction is an object-oriented design concept where a type exposes the behavior that consumers need while hiding implementation detail...
* **Why Does Abstraction Exist?**: Tight coupling between components
* **Abstraction vs Encapsulation**: These concepts are related but different.
* **What Is an Abstract Class?**: An abstract class is declared using the `abstract` modifier.
* **Why Does an Abstract Class Exist?**: An abstract class is useful when a type should represent a common abstraction but should not itself be directly constructed.
* **Abstract Classes Can Contain Concrete Members**: An abstract class does not mean that every member must be abstract.
* **What Is an Abstract Method?**: An abstract method declares required behavior without providing an implementation.
* **Abstract Class Constructors**: Abstract classes can have constructors.
* **What Is an Interface in Dart?**: An interface in **Object-Oriented Programming** (OOP) is a formal contract or blueprint that defines a specific set of signatures for met...
* **What Does `implements` Mean?**: `implements` establishes a contract relationship.
* **`extends` vs `implements`**: Use `extends` when the subtype relationship and inherited implementation are genuinely useful.
* **Interfaces Do Not Mean Multiple Superclass Inheritance**: A Dart class has one superclass.
* **What Is a Contract?**: A contract defines what an implementation promises to provide.
* **What Is `interface class`?**: Dart provides the `interface` class modifier.
* **What Is `abstract interface class`?**: The resulting type is intended to be a non-instantiable contract that can be implemented but not externally extended.
* **Why Use an Explicit Interface Contract?**: The implementation can change without requiring the ViewModel to know the details.
* **Polymorphism Through Interfaces**: Interfaces can be used as polymorphic types.
* **Why This Improves Testability**: The `CheckoutService` does not need to change.
* **Abstraction and Dependency Inversion**: The language-level abstraction introduced here supports a larger architectural principle.
* **Interface Segregation**: Contracts should represent focused responsibilities.
* **Abstraction vs Composition**: Abstraction defines a contract.
* **Flutter Relationship**: Flutter application code uses inheritance for framework specialization and can use interfaces for application architecture.
* **Internal Architecture**: Internal explanations must distinguish three levels.
* **Memory Implications**: An abstraction does not automatically create a separate runtime object.
* **Performance Implications**: Do not select abstract classes or interfaces based on speculative micro-optimizations.
* **Important Design Boundary**: Not every class needs an interface.

## 💡 Deep-Dive Materials Included

* **15 Interview Prep Scenarios** included
* **Technology Comparisons:** Choose an Abstract Class When, Choose an Interface When, Choose Composition When, Avoid Abstraction When
* **Common Pitfalls & Optimizations** included
* **Architecture & Production Patterns** included

---

## 🧭 Navigation

[⬅️ Day 08: Inheritance, Types of Inheritance, Method Overriding & Polymorphism](../Day-08/README.md) | [📂 Module Index](../README.md) | [Day 10: Dart Class Modifiers ➡️](../Day-10/README.md)

> [!TIP]
> **Interactive Experience:** To run code interactively, view full theoretical breakdowns, test interview questions, and chat with the AI Tutor, launch the **Flutter AI Tutor App**!

