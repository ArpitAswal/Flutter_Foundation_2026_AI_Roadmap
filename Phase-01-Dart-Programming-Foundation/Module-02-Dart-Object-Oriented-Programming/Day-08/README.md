# 📘 Day 08: Inheritance, Types of Inheritance, Method Overriding & Polymorphism

**Module 02:** [Dart Object-Oriented Programming](../README.md) • **Phase 01:** [Dart Programming Foundation](../../README.md)

> [!NOTE]
> **Lesson Objective:** Learn how Dart classes establish parent-child relationships, reuse and specialize behavior, understand the different inheritance structures and Dart's single-inheritance model, override inherited members, and use polymorphism through common parent types.

**Tags:** `Dart` `OOP` `Inheritance` `Extends` `Method Overriding` `Polymorphism` `super` `Composition`

---

## 🚦 Prerequisites
You should understand classes, objects, constructors, encapsulation, private members, getters, setters, instance members, and static members.

## 📖 Overview
Inheritance is an object-oriented programming mechanism that allows a new class to derive from an existing class and reuse or specialize its behavior.

```dart
class User {
  final String name;

User(this.name);

## 📚 Topics Covered
* **What Is Inheritance?**: Inheritance is an object-oriented programming mechanism that allows a new class to derive from an existing class and reuse or specialize ...
* **Why Does Inheritance Exist?**: Inheritance is useful when there is a genuine is-a relationship.
* **Dart's Inheritance Model**: Dart uses single class inheritance. A class has one superclass, although Dart provides other mechanisms such as mixins and interfaces for...
* **Types of Inheritance**: Inheritance terminology is often taught using a language-independent OOP taxonomy. We need to distinguish that terminology from what Dart...
* **Inheritance Type Decision Table**: This distinction is important in interviews. Saying that Dart supports multiple inheritance simply because it supports interfaces or mixi...
* **Basic `extends`**: Dart uses `extends` to establish class inheritance.
* **What Does the Child Inherit?**: A subclass can inherit accessible instance members from its superclass, subject to Dart's language and library rules.
* **Inheritance Does Not Mean Copying Code**: Inheritance establishes a type relationship. It does not simply copy the parent's source code into the child.
* **The `super` Keyword**: `super` is used to access the superclass context, commonly to invoke superclass constructors or methods.
* **Calling a Superclass Constructor**: A subclass defines its own constructors and initializes the superclass appropriately.
* **Constructors Are Not Inherited**: Constructors are not inherited like ordinary instance members.
* **Method Overriding**: When a child class provides a new implementation for an inherited member, it is overriding that member.
* **Why `@override`?**: `@override` documents the programmer's intention and allows Dart's analyzer to detect mistakes in the override declaration.
* **Override vs New Method**
* **Why Override Behavior?**: Different subclasses can expose the same operation while implementing it differently.
* **Polymorphism**: Polymorphism is the capability of different object types to be treated as instances of a common parent class or interface, executing diff...
* **Static Type vs Runtime Object Type**: The declared/static type is `Notification`.
* **Real-World Example — Payment Methods**: Suppose an application supports different payment methods.
* **Upcasting**: Assigning a child object to a parent-type variable is commonly called upcasting.
* **Downcasting**: If a value is known to contain a more specific object, Dart provides `is` and `as` for type checks and casts.
* **`is` vs `as`**: `is` checks whether a value has a particular runtime type and can enable type promotion.
* **Polymorphism With Collections**: Different concrete implementations can be stored in a collection of their common parent type.
* **`super` vs `this`**: `this` refers to the current object.
* **Inheritance vs Composition**: Inheritance represents an `is-a` relationship.
* **Why Composition Can Be Better**: If a repository merely uses an API service, it does not necessarily mean that the repository is an API service.
* **Inheritance and Type Safety**: code can use members available through `Animal`. It cannot assume every `Animal` is a `Dog`.
* **`Overriding` and `super`**: A subclass can override behavior while still using the parent implementation.
* **What Can Be Overridden?**: For normal Dart classes, inherited instance members can be overridden where the language rules permit.
* **Method Signature Compatibility**: An override must remain compatible with the member being overridden.

## 💡 Deep-Dive Materials Included

* **14 Interview Prep Scenarios** included
* **Common Pitfalls & Optimizations** included
* **Architecture & Production Patterns** included

---

## 🧭 Navigation

[⬅️ Day 07: Encapsulation, Getters, Setters & Static Members](../Day-07/README.md) | [📂 Module Index](../README.md) | [Day 09: Abstract Classes, Interfaces & Contracts ➡️](../Day-09/README.md)

> [!TIP]
> **Interactive Experience:** To run code interactively, view full theoretical breakdowns, test interview questions, and chat with the AI Tutor, launch the **Flutter AI Tutor App**!

