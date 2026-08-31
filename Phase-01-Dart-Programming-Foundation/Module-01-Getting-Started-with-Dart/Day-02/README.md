# 📘 Day 2: Variables, Data Types, Type Inference & Null Safety

> [!NOTE]
> **Summary:** Learn how Dart stores data, infers types, and prevents null-related runtime errors using modern language features that form the foundation of every Flutter application.

**Tags:** `Dart`, `Variables`, `Data Types`, `Null Safety`

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
* **What is a Variable?**: **Definition:** A variable is a named memory location used to store data that can be read, modified, and reused throughout a program. Instead of wr...
* **Why Do We Need Variables?**: Without variables, if a value changes, every occurrence must be updated manually:
* **Real-world Example**: Imagine an e-commerce application. Without variables:
* **Production Example**: Every property inside a model class is a variable.
* **How Variables Work in Memory**: When you write `String city = "Delhi";`, Dart performs:
* **Variables Are References**: One common beginner misconception is that variables "contain" data. In reality, variables generally reference objects in memory.
* **Identifier**: **Definition:** An identifier is the name given to a program element such as a variable, function, class, enum, extension, mixin, or parameter. Ide...
* **Variable Naming Rules**: **Valid:** **String firstName;**, **int age;**, **double totalPrice;**, **bool isLoggedIn;**, **String _privateName;**, **String user_name;**
* **Keywords**: **Definition:** Keywords are reserved words defined by the Dart language. They already have a predefined meaning and therefore cannot be used as id...
* **Naming Conventions**: **camelCase (Recommended)**
* **Data Types**: **Definition:** A data type defines the kind of value a variable can store and the operations that can be performed on it. Without data types, the ...
* **Primitive vs Collection Types**: Although Dart technically treats everything as an object, developers often think of types in two groups.
* **Everything is an Object**: One of Dart's most important concepts. Unlike Java, C++, or C#, Dart treats nearly everything as an object.
* **Literal Values**: A literal is a fixed value written directly into the source code.
* **Type Inference**: **Definition:** Type inference allows the compiler to determine the variable's type automatically based on its initial value.
* **Type Conversion & Safe Parsing**: Applications frequently receive data in one type but require another.
* ****final****: A value assigned only once.
* ****const****: Compile-time constant. Unlike **final**, the value must be known during compilation. Using **const** where possible helps Flutter reuse widget inst...
* ****late****: **Definition:** **late** tells Dart that a non-nullable variable will be initialized later, before it is accessed.
* **Null Safety**: **What is Null?** **null** represents the absence of a value. Before Dart's null safety, many applications crashed because developers accidentally ...
* **Type Promotion**: Dart's compiler can automatically promote nullable variables after performing a null check.
* **Runtime Type**: Sometimes debugging requires inspecting the actual type of an object.
* **Common Real-world Data Types**: | Data | Recommended Type |
* **Memory & Performance**: **Does Choosing the Correct Data Type Matter?**

## 🎯 Implementation Objective
Build a Simple Student Profile using Dart.

## 💡 Additional Materials Included
* **Comparisons:** **var** vs **dynamic**, **Object** vs **dynamic**, **final** vs **const**
* **Common Mistakes & Optimizations** included
* **Architecture Implementation Notes** included

> [!TIP]
> **Deep Dive:** To read the full theory, view detailed code implementations, architectures, and common interview questions, open this lesson interactively inside the **Flutter AI Tutor App**!
