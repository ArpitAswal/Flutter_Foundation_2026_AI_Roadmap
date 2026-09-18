# 📘 Day 10: Dart Class Modifiers

> [!NOTE]
> **Summary:** Learn how modern Dart class modifiers control construction, inheritance, interface implementation, mixin usage, subtype boundaries, API evolution, and exhaustive type hierarchies through abstract, base, interface, final, and sealed classes.

**Tags:** `Dart`, `OOP`, `Class Modifiers`, `abstract`, `base`, `interface`, `abstract interface`, `final`, `sealed`, `Inheritance`, `Interfaces`, `Pattern Matching`, `API Design`

---

## 🚦 Prerequisites
Dart classes, constructors, inheritance, extends, method overriding, polymorphism, composition, abstract classes, abstract members, interfaces, implements, interface class, and abstract interface class.

## 📖 Overview
Dart class modifiers control how a class can be constructed, extended, implemented, or otherwise used across library boundaries.

Modern Dart provides:

```text
abstract
base
interface
final
sealed
```

## 📚 Topics Covered
* **What Are Class Modifiers?**: Dart class modifiers control how a class can be constructed, extended, implemented, or otherwise used across library boundaries.
* **Why Do Class Modifiers Exist?**: Without explicit restrictions, a public Dart class can become an unintended extension or implementation point.
* **No Modifier**: An ordinary class is open by default.
* **`abstract`**: An abstract class cannot be directly instantiated.
* **`base`**: A base class requires external subtypes to inherit its implementation rather than independently implement its interface.
* **Why `base` Exists**: Suppose a library relies on implementation inherited from a class:
* **`interface`**: Outside its defining library, an interface class can be implemented but cannot be extended.
* **Why `interface` Exists**: Inheritance creates strong coupling because a subclass depends on the superclass implementation and behavior.
* **`abstract interface`**: This combines:
* **`final`**: A final class prevents external subtyping.
* **Why `final` Exists**: A package may expose a class whose behavior should remain completely under the package author's control.
* **`sealed`**: A sealed class:
* **Why `sealed` Is Different From `final`**: Both restrict external subtyping, but their design intent differs.
* **Sealed Classes in Flutter**: Sealed classes are useful for finite application states.
* **`base` vs `interface`**: These modifiers represent almost opposite intentions.
* **`final` vs `sealed`**: | Feature | `final` | `sealed` |
* **Modifier Combinations**: Dart permits certain modifier combinations but rejects contradictory combinations.
* **`abstract final`**: This combination creates a type that cannot be instantiated and cannot be externally subtyped.
* **Library Boundaries**: Class modifiers are particularly important when designing package or library APIs.
* **API Evolution**: Class modifiers communicate and enforce API intent.
* **Internal Architecture**: ### Documented Behavior
* **Memory Implications**: Class modifiers do not create a separate per-instance memory structure.
* **Performance Implications**: Class modifiers are primarily type-system and API-design mechanisms.
* **Real-World Applications**: ### Flutter UI State

## 💡 Additional Materials Included
* **15 Interview Questions** included
* **Comparisons:** Choose `abstract` when, Choose `base` when, Choose `interface` when, Choose `abstract interface` when, Choose `final` when, Choose `sealed` when, Choose no modifier when
* **Common Mistakes & Optimizations** included
* **Architecture Implementation Notes** included

> [!TIP]
> **Deep Dive:** To read the full theory, view detailed code implementations, architectures, and common interview questions, open this lesson interactively inside the **Flutter AI Tutor App**!
