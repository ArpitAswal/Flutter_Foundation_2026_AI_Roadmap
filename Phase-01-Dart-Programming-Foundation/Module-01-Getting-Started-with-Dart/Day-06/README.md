# 📘 Day 6: Classes, Objects, Fields, Methods & Constructors

> [!NOTE]
> **Summary:** Learn how Dart represents real-world entities through classes and objects, and how constructors initialize those objects with meaningful state and behavior.

**Tags:** `Dart`, `OOP`, `Classes`, `Objects`, `Constructors`, `Methods`

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
* **Class vs Object**: | Class | Object |
* **Why Do We Need Classes?**: Without classes, related information could be represented using separate variables:
* **Fields / Instance Variables**: A class can contain variables representing the state of an object.
* **Methods**: A method is a function associated with a class or object.
* **Instance Methods**: An instance method operates on a particular object.
* **The `this` Keyword**: `this` refers to the current object instance.
* **What Is a Constructor?**: A constructor is used to create and initialize an object.
* **Why Do Constructors Exist?**: Without constructor-based initialization, an object could be created in an incomplete state:
* **Generative Constructors**: A generative constructor creates an instance of the class.
* **Named Parameters in Constructors**: Flutter code frequently uses named parameters:
* **Initializing Formal Parameters**: Without shorthand:
* **Default Constructor**: If a class does not explicitly declare a constructor, Dart provides a default unnamed constructor when applicable.
* **Named Constructors**: A class can have multiple constructors with different names.
* **Real-World Named Constructor Example**: Now:
* **`const` Constructors**: A `const` constructor allows compile-time constant object creation when the class and values satisfy the required constraints.
* **`final` vs `const`**: means the variable cannot be reassigned.
* **Factory Constructors**: A factory constructor can control which instance is returned.
* **Factory vs Generative Constructor**: | Generative Constructor | Factory Constructor |
* **Redirecting Constructors**: A constructor can redirect to another constructor.
* **Constructor Initializer List**: An initializer list appears after the constructor declaration and before the constructor body.
* **Constructor Tear-Offs**: Constructors can also be used as function values.
* **Methods and Object State**: Consider:
* **Real-World Product Model**: Usage:
* **What Should Not Automatically Be Put Into a Model?**: Consider:
* **Classes in Flutter**: A normal Flutter widget demonstrates many Dart class concepts:
* **Primary Constructors in Modern Dart**: Modern Dart also supports primary constructors.
* **Memory & Performance**: Creating an object means allocating an instance with its associated state.

## 💡 Additional Materials Included
* **12 Interview Questions** included
* **Common Mistakes & Optimizations** included
* **Architecture Implementation Notes** included

> [!TIP]
> **Deep Dive:** To read the full theory, view detailed code implementations, architectures, and common interview questions, open this lesson interactively inside the **Flutter AI Tutor App**!
