# 📘 Day 39: Imperative Navigation Mechanics, Transitions & Hero Animations

**Module 01:** [Navigation Mechanics, Declarative Routing & Navigation Guards](../README.md) • **Phase 05:** [Navigation, Declarative Routing & Deep Linking](../../README.md)

> [!NOTE]
> **Lesson Objective:** Master Flutter's Navigator 1.0 imperative stack model, custom PageRoute transitions with Curves, modal bottom sheets and dialog barrier dismissals, will-pop scoped guards, and Hero animations with custom flight shaders and border morphing.

**Tags:** `Flutter` `Navigation` `Navigator` `Transitions` `Hero` `Animations` `Modal` `Routes`

---

## 🚦 Prerequisites
Flutter Widgets & Widget Tree Fundamentals; BuildContext & The Three Trees; StatefulWidget & State Lifecycle.
You should understand the widget tree hierarchy, BuildContext lookups, and state lifecycle management.

## 📖 Overview
In mobile applications, user interfaces are structured as a collection of visual screens or pages. The mechanism that coordinates transitions between these screens is the **Navigator**.

Flutter's original navigation system—commonly referred to as **Navigator 1.0 (Imperative Navigation)**—models screen history as a **Last-In, First-Out (LIFO) Stack** managed by a `NavigatorState` widget sitting inside an `Overlay` near the root of the widget tree.

```text
┌────────────────────────────────────────────────────────────────────────┐
│                     THE NAVIGATOR 1.0 ROUTE STACK                      │
├────────────────────────────────────────────────────────────────────────┤
│                                                                        │
│   TOP OF STACK ──▶ [ ProductDetailScreen ] ◄── Active Visible Route    │
│                           │                                            │
│                           ▼ (Navigator.pop(context, true))             │
│                    [ ProductListScreen ]   ◄── Paused in Background    │
│                           │                                            │
│                           ▼ (Navigator.pop(context))                   │
│   BOTTOM OF STACK ─▶ [ HomeScreen ]         ◄── Root Route             │
│                                                                        │
│  ════════════════════════════════════════════════════════════════════  │
│  • Navigator.push()             -> Adds new Route to the top of stack  │
│  • Navigator.pop()              -> Removes top Route, reveals previous │
│  • Navigator.pushReplacement()  -> Replaces top Route with new Route   │
│  • Navigator.pushAndRemoveUntil -> Wipes stack down to predicate route │
└────────────────────────────────────────────────────────────────────────┘
```

## 📚 Topics Covered
* **1. The Imperative Navigation Paradigm**: In mobile applications, user interfaces are structured as a collection of visual screens or pages. The mechanism that coordinates transit...
* **2. Complete Stack Lifecycle Operations**: Replaces the top-most route with a new route without altering the screens below it. Essential when transitioning between transient states...
* **3. Modal Overlays & Bottom Sheets**: Pushes a modal dialog that darkens the background (`barrierColor`) and blocks interactions with the underlying screen until dismissed.
* **4. Custom Physics-Based Transitions with PageRouteBuilder**: By default, `MaterialPageRoute` slides up with a subtle fade on Android, and `CupertinoPageRoute` slides horizontally from the right edge...
* **5. Shared Element Transitions with Hero Animations**: The **Hero** widget creates smooth, continuous visual animations where a widget on Screen A appears to physically fly across the screen a...
* **6. Modern Hardware Back Interception with PopScope**: `canPop` tells the operating system whether the screen can be dismissed immediately. If `canPop` is `false`, the system back gesture is i...

## 🎯 Implementation Objective
Build a production-grade Master-Detail Product Showcase in Flutter demonstrating Imperative Navigation (Navigator 1.0). Features include awaiting return data from child routes, custom slide-and-fade `PageRouteBuilder` transitions, continuous `Hero` image animations, modal bottom sheet checkout previews, and modern `PopScope` unsaved review confirmation.

```dart
import 'package:flutter/material.dart';

void main() {
  runApp(const ImperativeNavShowcaseApp());
}

// ─────────────────────────────────────────────────────────────────────────────
// 1. DOMAIN MODEL
// ─────────────────────────────────────────────────────────────────────────────

class Product {
  final String id;
  final String title;
  final String category;
  final double price;
  final String imageUrl;
  final String description;

  const Product({
    required this.id,
    required this.title,
    required this.category,
    required this.price,
    required this.imageUrl,
    required this.description,
  });
}

const sampleProduct = Product(
  id: 'prod_99',
  title: 'Bose QuietComfort Ultra',
  category: 'Audio & Acoustics',
  price: 429.00,
  imageUrl: 'https://picsum.photos/seed/headphones/600/400',
  description:
      'World-class noise cancellation, breakthrough spatial audio, and premium materials designed for all-day comfort and acoustic fidelity.',
);

// ─────────────────────────────────────────────────────────────────────────────
// 2. CUSTOM ROUTE TRANSITION BUILDER
// ─────────────────────────────────────────────────────────────────────────────

class SlideFadeRoute<T> extends PageRouteBuilder<T> {
  final Widget child;

  SlideFadeRoute({required this.child})
      : super(
          transitionDuration: const Duration(milliseconds: 350),
          reverseTransitionDuration: const Duration(milliseconds: 250),
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curved = CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOutCubic,
            );

            return FadeTransition(
              opacity: curved,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.0, 0.15),
                  end: Offset.zero,
                ).animate(curved),
                child: child,
              ),
            );
          },
        );
}

// ─────────────────────────────────────────────────────────────────────────────
// 3. PRESENTATION LAYER
// ─────────────────────────────────────────────────────────────────────────────

class ImperativeNavShowcaseApp extends StatelessWidget {
  const ImperativeNavShowcaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Imperative Navigation Architecture',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
      ),
      home: const ProductListScreen(),
    );
  }
}

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  int _cartItemCount = 0;

  Future<void> _navigateToDetail(Product product) async {
    // Awaiting typed result returned from Navigator.pop()
    final bool? addedToCart = await Navigator.push<bool>(
      context,
      SlideFadeRoute(child: ProductDetailScreen(product: product)),
    );

    if (addedToCart == true && mounted) {
      setState(() => _cartItemCount++);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${product.title} added to your cart!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Store Showcase (Navigator 1.0)'),
        centerTitle: true,
        actions: [
          Badge.count(
            count: _cartItemCount,
            child: const Icon(Icons.shopping_bag_outlined),
          ),
          const SizedBox(width: 20),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildInfoBanner(),
          const SizedBox(height: 20),
          _buildProductCard(context),
        ],
      ),
    );
  }

  Widget _buildInfoBanner() {
    return Card(
      elevation: 0,
      color: Colors.indigo.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.alt_route_rounded, color: Colors.indigo, size: 28),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Navigator 1.0: LIFO Stack, PageRouteBuilder transitions, Hero animations, and PopScope hardware intercepts.',
                style: TextStyle(fontSize: 12, height: 1.4, color: Colors.indigo, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(BuildContext context) {
    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: () => _navigateToDetail(sampleProduct),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Source Widget
            Hero(
              tag: 'product_image_${sampleProduct.id}',
              child: Container(
                height: 180,
                width: double.infinity,
                color: Colors.indigo.shade100,
                child: Center(
                  child: Icon(Icons.headphones_rounded, size: 80, color: Colors.indigo.shade700),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sampleProduct.category.toUpperCase(),
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.1, color: Colors.indigo.shade700),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    sampleProduct.title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '\$${sampleProduct.price.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.green),
                  ),
                  const SizedBox(height: 12),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text('Tap to View with Hero Animation ➔', style: TextStyle(fontSize: 12, color: Colors.indigo, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  bool _hasUnsavedNotes = false;
  final TextEditingController _notesController = TextEditingController();

  void _showOrderBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Quick Checkout Preview', style: Theme.of(sheetContext).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text('Item: ${widget.product.title}'),
            Text('Total: \$${widget.product.price.toStringAsFixed(2)}'),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () {
                Navigator.pop(sheetContext); // Dismiss bottom sheet
                Navigator.pop(context, true); // Pop detail screen and return true to list!
              },
              child: const Text('Confirm Purchase & Return'),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _confirmDiscardChanges() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Unsaved Notes'),
        content: const Text('You have entered product review notes. Leaving will discard them. Are you sure?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogCtx, false), child: const Text('Stay')),
          FilledButton(
            onPressed: () => Navigator.pop(dialogCtx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    // PopScope intercepts Android system back gestures and iOS edge-swipe back
    return PopScope(
      canPop: !_hasUnsavedNotes,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldDiscard = await _confirmDiscardChanges();
        if (shouldDiscard && context.mounted) {
          Navigator.pop(context, result);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.product.title),
        ),
        body: ListView(
          children: [
            // Hero Destination Widget with Matching Tag!
            Hero(
              tag: 'product_image_${widget.product.id}',
              child: Container(
                height: 260,
                color: Colors.indigo.shade100,
                child: Center(
                  child: Icon(Icons.headphones_rounded, size: 140, color: Colors.indigo.shade700),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.product.category,
                        style: TextStyle(color: Colors.indigo.shade700, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '\$${widget.product.price.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.green),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.product.description,
                    style: const TextStyle(height: 1.5, fontSize: 14, color: Colors.black87),
                  ),
                  const SizedBox(height: 24),
                  const Text('Personal Product Notes (Tests PopScope)', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _notesController,
                    decoration: const InputDecoration(
                      hintText: 'Type notes here to trigger PopScope back intercept...',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (text) {
                      setState(() {
                        _hasUnsavedNotes = text.trim().isNotEmpty;
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: FilledButton.icon(
              onPressed: () => _showOrderBottomSheet(context),
              icon: const Icon(Icons.shopping_cart_checkout_rounded),
              label: const Text('Open Checkout BottomSheet'),
            ),
          ),
        ),
      ),
    );
  }
}
```

## 💡 Deep-Dive Materials Included

* **3 Interview Prep Scenarios** included
* **Technology Comparisons:** Navigator 1.0 Stack Operations Comparison, WillPopScope (Deprecated) vs PopScope (Modern Flutter)
* **Common Pitfalls & Optimizations** included
* **Architecture & Production Patterns** included

---

## 🧭 Navigation

[📂 Module Index](../README.md) | [Day 40: Declarative Routing with go_router: ShellRoutes & Navigation Guards ➡️](../Day-40/README.md)

> [!TIP]
> **Interactive Experience:** To run code interactively, view full theoretical breakdowns, test interview questions, and chat with the AI Tutor, launch the **Flutter AI Tutor App**!

