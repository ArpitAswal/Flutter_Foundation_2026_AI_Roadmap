# 📘 Day 7: Encapsulation, Getters, Setters & Static Members

> [!NOTE]
> **Summary:** Learn how Dart classes protect internal state, control mutation, expose computed properties, distinguish instance and static members, and establish clean boundaries between an object and its consumers.

**Tags:** `Dart`, `OOP`, `Encapsulation`, `Getters`, `Setters`, `Static`, `Classes`

---

## 🚦 Prerequisites
You should understand classes, objects, fields, methods, constructors, named constructors, const, final, and basic object creation.

## 📖 Overview
Encapsulation is the practice of controlling how an object's internal state is accessed and modified.

The important idea is not simply to make fields private. The deeper idea is that an object should control how its state can be observed or changed.

```dart
class BankAccount {
  double _balance = 0;

## 📚 Topics Covered
* **What Is Encapsulation?**: Encapsulation is the practice of controlling how an object's internal state is accessed and modified.
* **Dart Privacy**: Dart does not use public, protected, and private keywords in the traditional way. An identifier beginning with `_` is private to the Dart library i...
* **Why Encapsulation Matters**: Suppose a product price must never be negative.
* **Getters**: A getter provides read access through property syntax.
* **Computed Properties**: Getters are useful when a value can be derived from object state.
* **Getter vs Method**: Use a getter when the result conceptually represents a property or state of the object:
* **Fields vs Explicit Getters**: Dart intentionally makes fields and getters indistinguishable at the call site. This allows an implementation to evolve from a field to a getter wi...
* **Do Not Add Getters and Setters Unnecessarily**: If a getter/setter pair adds no validation, computation, transformation, or access control, a direct field can be simpler.
* **Setters**: A setter controls how a property is assigned.
* **Read-Only Properties**: If a value should never change after construction, `final` is often the simplest design.
* **Protecting Mutable Collections**: Returning a private mutable collection directly still exposes a mutation path.
* **Getters Are Functions**: A getter is a special kind of function and can calculate a value dynamically.
* **Getter Performance Consideration**: A getter looks like a property but can execute computation. Avoid hiding expensive work, I/O, or significant side effects behind simple property sy...
* **Static Members**: A static member belongs to the class rather than an individual object.
* **Instance vs Static Members**: Instance members belong to an object and can access instance state. Static members belong to the class and do not operate on a particular instance.
* **Static Methods Cannot Use `this`**: A static method does not operate on a particular instance and therefore cannot access instance state through `this`.
* **Static State**: Static variables belong to the class rather than each object and can represent shared class-level state.
* **Static Constants**: Static constants can represent values conceptually associated with a class, although top-level constants can sometimes be clearer.
* **Static Methods vs Top-Level Functions**: If a function has no meaningful relationship to a type, a top-level function can be clearer than a class containing only static helpers.
* **Static Is Not Singleton**: A static member does not mean that a class has exactly one object. Singleton is a separate design pattern and will be studied separately.
* **Encapsulation vs Abstraction**: Encapsulation controls access to state and implementation.
* **Memory & Performance**: Getters and setters are language features, but their implementations determine their cost.

## 💡 Additional Materials Included
* **7 Interview Questions** included
* **Common Mistakes & Optimizations** included
* **Architecture Implementation Notes** included

> [!TIP]
> **Deep Dive:** To read the full theory, view detailed code implementations, architectures, and common interview questions, open this lesson interactively inside the **Flutter AI Tutor App**!
