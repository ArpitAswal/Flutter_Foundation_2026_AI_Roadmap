# 📘 Day 02: Variables, Data Types, Type Inference & Null Safety

**Module 01:** [Getting Started with Dart](../README.md) • **Phase 01:** [Dart Programming Foundation](../../README.md)

> [!NOTE]
> **Lesson Objective:** Learn how Dart stores data, infers types, and prevents null-related runtime errors using modern language features that form the foundation of every Flutter application.

**Tags:** `Dart` `Variables` `Data Types` `Null Safety`

---

## 🚦 Prerequisites
- Basic understanding of Dart and the Flutter ecosystem.
- Able to run a simple Dart program.

## 📖 Overview
**Definition:** A variable is a named memory location used to store data that can be read, modified, and reused throughout a program. Instead of writing the same value multiple times, we store it in a variable and reference it by its name.

```dart
String name = "Alex";
print(name);
// Output : Alex
```

Without variables, if a value changes, every occurrence must be updated manually:
```dart
print("Alex");
print("Alex");
print("Alex");
```
With variables, only one value needs to change:
```dart
String name = "Alex";
print(name);
print(name);
print(name);
```

## 📚 Topics Covered
* **What is a Variable?**: A variable is a named memory location used to store data that can be read, modified, and reused throughout a program. Instead of writing ...
* **Why Do We Need Variables?**
* **Real-world Example**: Whenever `productPrice` changes, the final calculation updates automatically.
* **Production Example**: Every property inside a model class is a variable.
* **How Variables Work in Memory**: The variable stores a reference to the value.
* **Variables Are References**: One common beginner misconception is that variables "contain" data. In reality, variables generally reference objects in memory.
* **Identifier**: An identifier is the name given to a program element such as a variable, function, class, enum, extension, mixin, or parameter. Identifie...
* **Variable Naming Rules**: **Valid:** **String firstName;**, **int age;**, **double totalPrice;**, **bool isLoggedIn;**, **String _privateName;**, **String user_nam...
* **Keywords**: Keywords are reserved words defined by the Dart language. They already have a predefined meaning and therefore cannot be used as identifi...
* **Naming Conventions**: **camelCase (Recommended)**
* **Data Types**: A data type defines the kind of value a variable can store and the operations that can be performed on it. Without data types, the compil...
* **Primitive vs Collection Types**: Although Dart technically treats everything as an object, developers often think of types in two groups.
* **Everything is an Object**: One of Dart's most important concepts. Unlike Java, C++, or C#, Dart treats nearly everything as an object.
* **Literal Values**: A literal is a fixed value written directly into the source code.
* **Type Inference**: Type inference allows the compiler to determine the variable's type automatically based on its initial value.
* **Type Conversion & Safe Parsing**: Applications frequently receive data in one type but require another.
* ****final****: A value assigned only once.
* ****const****: Compile-time constant. Unlike **final**, the value must be known during compilation. Using **const** where possible helps Flutter reuse w...
* ****late****: **late** tells Dart that a non-nullable variable will be initialized later, before it is accessed.
* **Null Safety**: **What is Null?** **null** represents the absence of a value. Before Dart's null safety, many applications crashed because developers acc...
* **Type Promotion**: Dart's compiler can automatically promote nullable variables after performing a null check.
* **Runtime Type**: Sometimes debugging requires inspecting the actual type of an object.
* **Common Real-world Data Types**: Choosing the correct type improves readability, enables compile-time checking, and reduces bugs.
* **Memory & Performance**: **Does Choosing the Correct Data Type Matter?**

## 🎯 Implementation Objective
Build a Simple Student Profile using Dart.

## 💡 Deep-Dive Materials Included

* **Technology Comparisons:** **var** vs **dynamic**, **Object** vs **dynamic**, **final** vs **const**
* **Common Pitfalls & Optimizations** included
* **Architecture & Production Patterns** included

---

## 🧭 Navigation

[⬅️ Day 01: Introduction to Programming, Dart & Flutter Ecosystem](../Day-01/README.md) | [📂 Module Index](../README.md) | [Day 03: Operators, Expressions & Control Flow ➡️](../Day-03/README.md)

> [!TIP]
> **Interactive Experience:** To run code interactively, view full theoretical breakdowns, test interview questions, and chat with the AI Tutor, launch the **Flutter AI Tutor App**!

