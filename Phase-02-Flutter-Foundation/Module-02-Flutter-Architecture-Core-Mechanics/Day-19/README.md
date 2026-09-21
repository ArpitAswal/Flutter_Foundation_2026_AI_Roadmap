# 📘 Day 19: InheritedWidget & Scoped Data Propagation

**Module 02:** [Flutter Architecture & Core Mechanics](../README.md) • **Phase 02:** [Flutter Foundation](../../README.md)

> [!NOTE]
> **Lesson Objective:** Master Flutter's built-in mechanism for ambient data sharing down the widget tree without constructor prop-drilling. Learn how InheritedWidget works under the hood, how updateShouldNotify selectively triggers rebuilds of dependent elements, the difference between dependOnInheritedWidgetOfExactType and getInheritedWidgetOfExactType, how Theme, MediaQuery, and Directionality are implemented, and why InheritedWidget is the foundational pillar for Provider, Riverpod, and BLoC.

**Tags:** `Flutter` `InheritedWidget` `Prop Drilling` `Scoped Data` `updateShouldNotify` `dependOnInheritedWidgetOfExactType` `Theme.of` `MediaQuery.of` `State Propagation`

---

## 🚦 Prerequisites
Day 14: Flutter Widgets & Widget Tree Fundamentals; Day 16: StatefulWidget, State & setState; Day 17: BuildContext & The Three Trees (Widget, Element, RenderObject). You should understand BuildContext navigation, immutable widgets vs mutable elements, and the separation of configuration from state.

## 📖 Overview
As Flutter applications grow beyond trivial single-screen prototypes, a fundamental architectural challenge arises: **data sharing across distant widgets**.

Imagine an application with a dark/light theme, an active user profile, or a shopping cart. The data is acquired near the root of the app, but a button nested 15 levels deep inside the drawer needs to know the user's name:

```text
RootApp (holds UserData)
  └── MainScreen(user: user)
        └── Dashboard(user: user)
              └── HeaderSection(user: user)
                    └── UserBadge(user: user)
                          └── Text(user.name)
```

## 📚 Topics Covered
* **1. The Problem: The Fragility of Constructor Prop-Drilling**: As Flutter applications grow beyond trivial single-screen prototypes, a fundamental architectural challenge arises: **data sharing across...
* **2. What Is InheritedWidget?**: `InheritedWidget` is a special base class in Flutter designed for **ambient data sharing and selective dependency propagation** down the ...
* **3. How InheritedWidget Works Under the Hood**: To understand why `InheritedWidget` is so remarkably fast, we must look at how `Element`s store inherited references.
* **4. The Two Consumption APIs on BuildContext**: Locates the `InheritedWidget` AND registers the calling element as a dependent.
* **5. The Canonical Production Pattern: StatefulWidget + InheritedWidget**: Notice that `InheritedWidget` itself is `@immutable`. It cannot mutate its own fields! So how do we build dynamic, updating state with it?

## 🎯 Implementation Objective
Build a clean, robust scoped state management architecture from scratch using a custom InheritedWidget and StatefulWidget wrapper, implementing a Cart & Authentication session system with selective dependent rebuilds and a static of(context) accessor.

```dart
import 'package:flutter/material.dart';

void main() {
  runApp(const ScopedCartApp());
}

/// Root application setting up the Scoped Cart Provider.
class ScopedCartApp extends StatelessWidget {
  const ScopedCartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const CartScope(
      child: MaterialApp(
        title: 'InheritedWidget Scoped State',
        debugShowCheckedModeBanner: false,
        home: CartHomeScreen(),
      ),
    );
  }
}

/// Pure domain item model.
class CartItem {
  final String id;
  final String name;
  final double price;

  const CartItem({required this.id, required this.name, required this.price});
}

// ============================================================================
// 1. INHERITED WIDGET (The Immutable Distribution Layer)
// ============================================================================
class _InheritedCart extends InheritedWidget {
  final List<CartItem> items;
  final _CartScopeState state;

  const _InheritedCart({
    required this.items,
    required this.state,
    required super.child,
  });

  @override
  bool updateShouldNotify(_InheritedCart oldWidget) {
    // Rebuild dependents only if items list reference or length changed
    return items != oldWidget.items || items.length != oldWidget.items.length;
  }
}

// ============================================================================
// 2. STATEFUL WRAPPER (The Mutable Controller & Manager)
// ============================================================================
class CartScope extends StatefulWidget {
  final Widget child;

  const CartScope({super.key, required this.child});

  /// Convenience accessor that subscribes the calling widget to cart updates.
  static CartScopeController of(BuildContext context) {
    final inherited = context.dependOnInheritedWidgetOfExactType<_InheritedCart>();
    assert(inherited != null, 'No CartScope found in current BuildContext.');
    return CartScopeController(inherited!.state);
  }

  /// Read-only accessor that reads cart without subscribing (no rebuilds).
  static CartScopeController read(BuildContext context) {
    final inherited = context.getInheritedWidgetOfExactType<_InheritedCart>();
    assert(inherited != null, 'No CartScope found in current BuildContext.');
    return CartScopeController(inherited!.state);
  }

  @override
  State<CartScope> createState() => _CartScopeState();
}

class _CartScopeState extends State<CartScope> {
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);
  int get count => _items.length;
  double get totalPrice => _items.fold(0.0, (sum, item) => sum + item.price);

  void addItem(CartItem item) {
    setState(() {
      _items.add(item);
    });
  }

  void removeItem(String id) {
    setState(() {
      _items.removeWhere((item) => item.id == id);
    });
  }

  void clear() {
    setState(() {
      _items.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return _InheritedCart(
      items: items,
      state: this,
      child: widget.child,
    );
  }
}

/// Clean controller exposing only public operations and state to consumers.
class CartScopeController {
  final _CartScopeState _state;

  const CartScopeController(this._state);

  List<CartItem> get items => _state.items;
  int get count => _state.count;
  double get totalPrice => _state.totalPrice;

  void addItem(CartItem item) => _state.addItem(item);
  void removeItem(String id) => _state.removeItem(id);
  void clear() => _state.clear();
}

// ============================================================================
// 3. UI CONSUMER SCREENS & WIDGETS
// ============================================================================
class CartHomeScreen extends StatelessWidget {
  const CartHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('InheritedWidget Scoped State'),
        backgroundColor: Colors.indigo.shade100,
        actions: const [
          // Subscribed Cart Badge
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: CartBadge(),
          ),
        ],
      ),
      body: const Column(
        children: [
          // Unsubscribed Static Banner (Demonstrating Rebuild Bypassing)
          StaticUnsubscribedBanner(),
          Divider(height: 1),
          Expanded(child: ProductCatalogList()),
          CartSummaryBar(),
        ],
      ),
    );
  }
}

/// Subscribed widget: Only this badge rebuilds when an item is added!
class CartBadge extends StatelessWidget {
  const CartBadge({super.key});

  @override
  Widget build(BuildContext context) {
    // Subscribes to CartScope updates via dependOnInheritedWidgetOfExactType
    final cart = CartScope.of(context);

    return Stack(
      alignment: Alignment.center,
      children: [
        const Icon(Icons.shopping_bag_outlined, size: 28),
        if (cart.count > 0)
          Positioned(
            right: 0,
            top: 4,
            child: CircleAvatar(
              radius: 9,
              backgroundColor: Colors.red,
              child: Text(
                '${cart.count}',
                style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
      ],
    );
  }
}

/// Unsubscribed widget: Does not rebuild when cart changes!
class StaticUnsubscribedBanner extends StatelessWidget {
  const StaticUnsubscribedBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12.0),
      color: Colors.amber.shade50,
      child: const Row(
        children: [
          Icon(Icons.info_outline, color: Colors.amber),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Notice: This banner never calls CartScope.of(context). ' 
              'When cart items change, this subtree completely skips rebuilds!',
              style: TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

/// Catalog list that reads the cart controller to dispatch add actions.
class ProductCatalogList extends StatelessWidget {
  const ProductCatalogList({super.key});

  static const _sampleProducts = [
    CartItem(id: 'p1', name: 'Flutter Advanced Architecture Guide', price: 29.99),
    CartItem(id: 'p2', name: 'Clean Dart Patterns Handbook', price: 19.99),
    CartItem(id: 'p3', name: 'Impeller Engine Deep Dive Video', price: 49.99),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: _sampleProducts.length,
      itemBuilder: (context, index) {
        final product = _sampleProducts[index];
        return ListTile(
          title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text('$ ${product.price.toStringAsFixed(2)}'),
          trailing: FilledButton.tonalIcon(
            onPressed: () {
              // Uses CartScope.read to dispatch without subscribing to rebuilds
              CartScope.read(context).addItem(product);
            },
            icon: const Icon(Icons.add_shopping_cart, size: 16),
            label: const Text('Add'),
          ),
        );
      },
    );
  }
}

/// Bottom summary bar showing live total price.
class CartSummaryBar extends StatelessWidget {
  const CartSummaryBar({super.key});

  @override
  Widget build(BuildContext context) {
    // Subscribed to cart updates
    final cart = CartScope.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, -2)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Total Investment', style: TextStyle(color: Colors.grey, fontSize: 12)),
              Text(
                '$ ${cart.totalPrice.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.indigo),
              ),
            ],
          ),
          if (cart.count > 0)
            OutlinedButton(
              onPressed: () => CartScope.read(context).clear(),
              child: const Text('Clear Cart'),
            ),
        ],
      ),
    );
  }
}
```

## 💡 Deep-Dive Materials Included

* **16 Interview Prep Scenarios** included
* **Technology Comparisons:** InheritedWidget vs Constructor Prop Drilling, dependOnInheritedWidgetOfExactType vs getInheritedWidgetOfExactType, InheritedWidget vs Provider vs BLoC, InheritedWidget vs InheritedModel, InheritedWidget vs Global Singleton
* **Common Pitfalls & Optimizations** included
* **Architecture & Production Patterns** included

---

## 🧭 Navigation

[⬅️ Day 18: Widget Keys & State Preservation](../Day-18/README.md) | [📂 Module Index](../README.md)

> [!TIP]
> **Interactive Experience:** To run code interactively, view full theoretical breakdowns, test interview questions, and chat with the AI Tutor, launch the **Flutter AI Tutor App**!

