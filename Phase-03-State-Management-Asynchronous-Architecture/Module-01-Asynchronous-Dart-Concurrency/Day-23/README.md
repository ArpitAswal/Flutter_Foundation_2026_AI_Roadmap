# 📘 Day 23: Futures, Async/Await & The Event Loop

**Module 01:** [Asynchronous Dart & Concurrency](../README.md) • **Phase 03:** [State Management & Asynchronous Architecture](../../README.md)

> [!NOTE]
> **Lesson Objective:** Understand how Dart executes asynchronous tasks on a single thread through the Event Loop, Microtask Queue, and Event Queue. Master Future states and chaining, non-blocking async/await syntax, robust error handling, and Flutter's FutureBuilder with safe mounted checks.

**Tags:** `Dart` `Flutter` `Futures` `async/await` `Event Loop` `Microtask Queue` `Event Queue` `FutureBuilder` `Async Architecture`

---

## 🚦 Prerequisites
Functions, Parameters, Return Values & Functional Concepts; Functions as First-Class Objects, Callbacks & Closures; StatefulWidget, State & setState; BuildContext & The Three Trees (mounted property). 
 You should understand how the call stack executes functions and how widget rebuilds are triggered in Flutter.

## 📖 Overview
Dart applications execute code inside an **Isolate**, which has a single thread of execution and its own isolated memory heap. Unlike multi-threaded runtimes where blocking operations (such as HTTP requests, file reads, or database queries) can be spawned on worker threads sharing memory, a blocking call on Dart's main thread immediately halts all execution—freezing UI animations, dropping frame rates below 60/120 FPS, and triggering Application Not Responding (ANR) dialogs.

To achieve smooth responsiveness without multi-threaded concurrency bugs (like data races and mutex deadlocks), Dart employs an **asynchronous, non-blocking event-driven concurrency model** powered by the **Event Loop**.

The Event Loop is an infinite processing loop that orchestrates code execution by continuously monitoring two distinct internal FIFO queues:

## 📚 Topics Covered
* **1. Why Asynchronous Programming in Dart?**: Dart applications execute code inside an **Isolate**, which has a single thread of execution and its own isolated memory heap. Unlike mul...
* **2. The Dart Event Loop Architecture**: 1. Synchronous code executes immediately on the **Call Stack** until the stack is completely empty.
* **3. Futures & The Future Lifecycle**: A `Future<T>` represents a computation that does not complete immediately. It is an object that promises to deliver a value of type `T` (...
* **4. Under the Hood of async and await**: Marking a function `async` guarantees it returns a `Future`, even if you return a raw value (e.g. `return 42;` becomes `Future<int>.value...
* **5. Modern Asynchronous Error Handling**
* **6. Integrating Futures in Flutter UI: FutureBuilder & mounted Checks**: `FutureBuilder<T>` listens to a future and exposes an `AsyncSnapshot<T>` containing `ConnectionState` (`none`, `waiting`, `active`, `done...

## 🎯 Implementation Objective
Build a production-grade asynchronous currency & market ticker monitor demonstrating Future states, async/await with timeout handling, exponential backoff retry algorithms, safe BuildContext.mounted checks, and reactive FutureBuilder UI with loading, error, and empty states.

```dart
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const AsyncMasteryApp());
}

/// Root application entrypoint.
class AsyncMasteryApp extends StatelessWidget {
  const AsyncMasteryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Futures & Event Loop Mastery',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.teal,
        useMaterial3: true,
      ),
      home: const CurrencyDashboardScreen(),
    );
  }
}

/// Immutable domain model representing currency quote.
class CurrencyRate {
  final String pair;
  final double rate;
  final double change24h;
  final DateTime timestamp;

  const CurrencyRate({
    required this.pair,
    required this.rate,
    required this.change24h,
    required this.timestamp,
  });
}

/// Dashboard screen demonstrating Future management, retry backoff,
/// and mounted-safe async navigation.
class CurrencyDashboardScreen extends StatefulWidget {
  const CurrencyDashboardScreen({super.key});

  @override
  State<CurrencyDashboardScreen> createState() => _CurrencyDashboardScreenState();
}

class _CurrencyDashboardScreenState extends State<CurrencyDashboardScreen> {
  /// Stored Future instance. Initialized in initState() to prevent
  /// re-triggering network requests on widget rebuilds!
  late Future<List<CurrencyRate>> _ratesFuture;
  bool _isManualRefreshing = false;

  @override
  void initState() {
    super.initState();
    _ratesFuture = _fetchRatesWithRetry();
  }

  /// Production Asynchronous Fetcher with Simulated Network, Timeout,
  /// and Exponential Backoff Retry Logic.
  Future<List<CurrencyRate>> _fetchRatesWithRetry({int maxRetries = 3}) async {
    int attempts = 0;
    Duration delay = const Duration(milliseconds: 600);

    while (true) {
      attempts++;
      try {
        // Wrap the network simulation with a hard timeout of 3 seconds
        return await _simulateNetworkCall().timeout(
          const Duration(seconds: 3),
          onTimeout: () => throw TimeoutException('Network request timed out.'),
        );
      } catch (error) {
        if (attempts >= maxRetries) {
          rethrow; // Exhausted all retries; forward error to UI
        }
        // Exponential backoff: delay * 2^attempt + jitter
        await Future.delayed(delay);
        delay = delay * 2;
      }
    }
  }

  /// Simulates a remote HTTP REST API endpoint with simulated latency and failure rate.
  Future<List<CurrencyRate>> _simulateNetworkCall() async {
    await Future.delayed(const Duration(milliseconds: 1200));

    // 20% intentional random failure to demonstrate error state recovery
    final random = Random();
    if (random.nextDouble() < 0.20) {
      throw Exception('503 Service Unavailable: Remote exchange gateway busy.');
    }

    return [
      CurrencyRate(
        pair: 'USD / EUR',
        rate: 0.9245,
        change24h: 0.18,
        timestamp: DateTime.now(),
      ),
      CurrencyRate(
        pair: 'USD / JPY',
        rate: 154.62,
        change24h: -0.45,
        timestamp: DateTime.now(),
      ),
      CurrencyRate(
        pair: 'GBP / USD',
        rate: 1.2890,
        change24h: 0.32,
        timestamp: DateTime.now(),
      ),
      CurrencyRate(
        pair: 'BTC / USD',
        rate: 68420.50,
        change24h: 3.84,
        timestamp: DateTime.now(),
      ),
    ];
  }

  /// Manual reload handler updating the Future state
  void _reloadRates() {
    setState(() {
      _ratesFuture = _fetchRatesWithRetry();
    });
  }

  /// Async handler demonstrating proper context.mounted safety before SnackBar
  Future<void> _handleQuickConvert(CurrencyRate rate) async {
    setState(() => _isManualRefreshing = true);

    // Simulate background calculation
    await Future.delayed(const Duration(milliseconds: 700));

    // CRITICAL: Verify mounted status before touching BuildContext after an await!
    if (!mounted) return;

    setState(() => _isManualRefreshing = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Calculated live quote for ${rate.pair}: ${(1000 * rate.rate).toStringAsFixed(2)}'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Global FX Live Rates'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reload Rates',
            onPressed: _reloadRates,
          ),
        ],
      ),
      body: FutureBuilder<List<CurrencyRate>>(
        future: _ratesFuture,
        builder: (context, snapshot) {
          // State 1: Connection pending / waiting
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Connecting to FX market feeds...', style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          // State 2: Error state
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
                    const SizedBox(height: 16),
                    Text(
                      'Market Feed Error',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      snapshot.error.toString(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.black54, fontSize: 13),
                    ),
                    const SizedBox(height: 20),
                    FilledButton.icon(
                      onPressed: _reloadRates,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry Connection'),
                    ),
                  ],
                ),
              ),
            );
          }

          // State 3: Successful data resolution
          if (snapshot.hasData) {
            final rates = snapshot.data!;
            if (rates.isEmpty) {
              return const Center(child: Text('No active currency pairs available.'));
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: rates.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = rates[index];
                final isPositive = item.change24h >= 0;

                return Card(
                  elevation: 1.5,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isPositive ? Colors.green.shade50 : Colors.red.shade50,
                      child: Icon(
                        isPositive ? Icons.trending_up : Icons.trending_down,
                        color: isPositive ? Colors.green : Colors.red,
                      ),
                    ),
                    title: Text(item.pair, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Last updated: ${item.timestamp.second}s ago'),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          item.rate.toStringAsFixed(4),
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                        ),
                        Text(
                          '${isPositive ? '+' : ''}${item.change24h.toStringAsFixed(2)}%',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isPositive ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                    onTap: () => _handleQuickConvert(item),
                  ),
                );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
```

## 💡 Deep-Dive Materials Included

* **8 Interview Prep Scenarios** included
* **Technology Comparisons:** Future vs Stream, Microtask Queue vs Event Queue, async / await vs .then() Chaining, Future.wait() vs Sequential Await
* **Common Pitfalls & Optimizations** included
* **Architecture & Production Patterns** included

---

## 🧭 Navigation

[📂 Module Index](../README.md) | [Day 24: Streams, Sinks & Reactive Programming ➡️](../Day-24/README.md)

> [!TIP]
> **Interactive Experience:** To run code interactively, view full theoretical breakdowns, test interview questions, and chat with the AI Tutor, launch the **Flutter AI Tutor App**!

