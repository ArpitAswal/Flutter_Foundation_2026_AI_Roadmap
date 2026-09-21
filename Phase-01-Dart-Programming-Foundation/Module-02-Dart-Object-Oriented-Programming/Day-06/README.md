# 📘 Day 06: Classes, Objects, Fields, Methods & Constructors

**Module 02:** [Dart Object-Oriented Programming](../README.md) • **Phase 01:** [Dart Programming Foundation](../../README.md)

> [!NOTE]
> **Lesson Objective:** Learn how Dart represents real-world entities through classes and objects, and how constructors initialize those objects with meaningful state and behavior.

**Tags:** `Dart` `OOP` `Classes` `Objects` `Constructors` `Methods`

---

## 🚦 Prerequisites
You should understand variables, data types, null safety, control flow, functions, parameters, return values, callbacks, and closures.

## 📖 Overview
Object-Oriented Programming (OOP) is a programming approach where software is organized around objects that contain data and behavior.

For example, consider a product in an e-commerce application.

A product has data:

## 📚 Topics Covered
* **What Is Object-Oriented Programming?**: Object-Oriented Programming (OOP) is a programming approach where software is organized around objects that contain data and behavior.
* **What Is a Class?**: A class is a definition that describes what objects of a particular type contain and what they can do.
* **What Is an Object?**: An object is an instance of a class.
* **Class vs Object**
* **Why Do We Need Classes?**: With many products, this becomes difficult to manage.
* **Fields / Instance Variables**: A class can contain variables representing the state of an object.
* **Methods**: A method is a function associated with a class or object.
* **Instance Methods**: An instance method operates on a particular object.
* **The `this` Keyword**: `this` refers to the current object instance.
* **What Is a Constructor?**: A constructor is used to create and initialize an object.
* **Why Do Constructors Exist?**: This makes required initialization explicit.
* **Generative Constructors**: A generative constructor creates an instance of the class.
* **Named Parameters in Constructors**: Named parameters make the meaning of each argument immediately visible.
* **Initializing Formal Parameters**: The second version directly initializes the instance fields from the constructor parameters.
* **Default Constructor**: If a class does not explicitly declare a constructor, Dart provides a default unnamed constructor when applicable.
* **Named Constructors**: A class can have multiple constructors with different names.
* **Real-World Named Constructor Example**: The constructor communicates the intent of object creation.
* **`const` Constructors**: A `const` constructor allows compile-time constant object creation when the class and values satisfy the required constraints.
* **`final` vs `const`**: means the variable cannot be reassigned.
* **Factory Constructors**: A factory constructor can control which instance is returned.
* **Factory vs Generative Constructor**: The `fromJson` pattern will become important when networking and serialization are introduced later.
* **Redirecting Constructors**: A constructor can redirect to another constructor.
* **Constructor Initializer List**: An initializer list appears after the constructor declaration and before the constructor body.
* **Constructor Tear-Offs**: Constructors can also be used as function values.
* **Methods and Object State**: This is the basic OOP relationship between data and behavior.
* **Real-World Product Model**: The object contains product state and behavior directly related to that state.
* **What Should Not Automatically Be Put Into a Model?**: Analytics may be an application/service responsibility rather than intrinsic product behavior.
* **Classes in Flutter**: Inheritance and overriding are intentionally not studied deeply here. They will be covered in a dedicated OOP lesson.
* **Primary Constructors in Modern Dart**: Modern Dart also supports primary constructors.
* **Memory & Performance**: Creating an object means allocating an instance with its associated state.

## 💡 Deep-Dive Materials Included

* **12 Interview Prep Scenarios** included
* **Common Pitfalls & Optimizations** included
* **Architecture & Production Patterns** included

---

## 🧭 Navigation

[📂 Module Index](../README.md) | [Day 07: Encapsulation, Getters, Setters & Static Members ➡️](../Day-07/README.md)

> [!TIP]
> **Interactive Experience:** To run code interactively, view full theoretical breakdowns, test interview questions, and chat with the AI Tutor, launch the **Flutter AI Tutor App**!

