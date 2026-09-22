# 📘 Day 24: Streams, Sinks & Reactive Programming

**Module 01:** [Asynchronous Dart & Concurrency](../README.md) • **Phase 03:** [State Management & Asynchronous Architecture](../../README.md)

> [!NOTE]
> **Lesson Objective:** Master reactive data pipelines in Dart using Streams and StreamControllers. Learn the difference between single-subscription and broadcast streams, how to transform streams using map/where/distinct, build asynchronous generator sequences with async* and yield, and bind dynamic streams to Flutter UI via StreamBuilder without memory leaks.

**Tags:** `Dart` `Flutter` `Streams` `StreamController` `Sink` `async*` `yield` `StreamBuilder` `Reactive Programming` `Broadcast Stream`

---

## 🚦 Prerequisites
Futures, Async/Await & The Event Loop; StatefulWidget, State & setState; BuildContext & The Three Trees. 
 You should understand how the single-threaded Event Loop processes asynchronous completions and how StatefulWidget manages its lifecycle.

## 📖 Overview
A `Stream<T>` is a sequence of asynchronous events emitted over time. While a `Future<T>` provides a single result (or error) and then immediately terminates, a `Stream` acts as an asynchronous pipeline that can deliver zero, one, or hundreds of data values over its lifetime before eventually closing.

In reactive programming, streams represent a **push-based** model: instead of the consumer polling or actively querying for new data, the data producer pushes new events into the stream as they occur, and subscribed listeners react immediately.

A Dart stream pipeline consists of four essential components:

## 📚 Topics Covered
* **1. What is a Stream in Dart?**: A `Stream<T>` is a sequence of asynchronous events emitted over time. While a `Future<T>` provides a single result (or error) and then im...
* **2. The Core Anatomy of a Stream**: 1. **`StreamController<T>`**: The orchestrator that creates and controls a stream.
* **3. Single-Subscription Streams vs Broadcast Streams**: Allows **exactly ONE listener** over its entire lifecycle.
* **4. Asynchronous Generators: async* and yield**: An `async*` function always returns a `Stream<T>`.
* **5. Declarative Stream Transformations**: Transforms each event from type `T` to type `R`.
* **6. Integrating Streams in Flutter: StreamBuilder**: 1. **`ConnectionState.none`**: Stream is null.
* **7. Mandatory Lifecycle & Memory Management**: Every instantiated `StreamController` **must be closed** via `controller.close()` when its parent `State` is disposed.

## 🎯 Implementation Objective
Build a production-grade real-time cryptocurrency telemetry monitor demonstrating async* generators, broadcast StreamControllers, declarative transformations (distinct, where, map), StreamBuilder connection states, and manual StreamSubscription lifecycle with pause/resume controls.

```dart
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const ReactiveStreamMasteryApp());
}

/// Root application entrypoint.
class ReactiveStreamMasteryApp extends StatelessWidget {
  const ReactiveStreamMasteryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Streams & Reactive Programming Mastery',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.deepPurple,
        useMaterial3: true,
      ),
      home: const CryptoLiveMonitorScreen(),
    );
  }
}

/// Immutable domain model for a live ticker tick.
class CryptoTick {
  final String symbol;
  final double price;
  final double delta24h;
  final DateTime timestamp;

  const CryptoTick({
    required this.symbol,
    required this.price,
    required this.delta24h,
    required this.timestamp,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CryptoTick &&
          runtimeType == other.runtimeType &&
          symbol == other.symbol &&
          price == other.price;

  @override
  int get hashCode => symbol.hashCode ^ price.hashCode;
}

/// Production screen demonstrating both StreamBuilder and manual StreamSubscription.
class CryptoLiveMonitorScreen extends StatefulWidget {
  const CryptoLiveMonitorScreen({super.key});

  @override
  State<CryptoLiveMonitorScreen> createState() => _CryptoLiveMonitorScreenState();
}

class _CryptoLiveMonitorScreenState extends State<CryptoLiveMonitorScreen> {
  /// Broadcast controller allowing multiple UI components to listen
  late final StreamController<CryptoTick> _tickerController;

  /// Transformed stream filtered for significant price updates
  late final Stream<CryptoTick> _filteredStream;

  /// Manual subscription demonstrating lifecycle, pause, and resume controls
  StreamSubscription<CryptoTick>? _manualAlertSubscription;

  Timer? _generatorTimer;
  final List<String> _alerts = [];
  bool _isSubscriptionPaused = false;
  double _basePrice = 64250.0;

  @override
  void initState() {
    super.initState();
    // 1. Initialize Broadcast StreamController
    _tickerController = StreamController<CryptoTick>.broadcast();

    // 2. Declarative stream pipeline: filter out micro-fluctuations and duplicate ticks
    _filteredStream = _tickerController.stream
        .distinct() // Prevent consecutive identical price emissions
        .map((tick) => tick); // Demonstration of map operator

    // 3. Setup manual subscription for real-time volatility alerts
    _manualAlertSubscription = _filteredStream.listen(
      (tick) {
        if (tick.delta24h.abs() >= 1.5) {
          setState(() {
            _alerts.insert(
              0,
              '⚡ [${tick.timestamp.second}s] Volatility alert on ${tick.symbol}: ${tick.price.toStringAsFixed(2)} (${tick.delta24h.toStringAsFixed(2)}%)',
            );
            if (_alerts.length > 8) _alerts.removeLast();
          });
        }
      },
      onError: (err) => debugPrint('Stream error encountered: $err'),
      onDone: () => debugPrint('Ticker stream closed.'),
    );

    // 4. Start simulating real-time market ticks
    _startPriceGenerator();
  }

  @override
  void dispose() {
    // MANDATORY LIFECYCLE CLEANUP: Prevent memory leaks!
    _generatorTimer?.cancel();
    _manualAlertSubscription?.cancel();
    _tickerController.close();
    super.dispose();
  }

  /// Simulates continuous live market updates pushing into the Sink.
  void _startPriceGenerator() {
    final random = Random();
    _generatorTimer = Timer.periodic(const Duration(milliseconds: 900), (timer) {
      if (_tickerController.isClosed) return;

      final deltaPercentage = (random.nextDouble() * 4.0) - 2.0; // between -2% and +2%
      _basePrice += (_basePrice * (deltaPercentage / 100));

      final tick = CryptoTick(
        symbol: 'BTC / USDT',
        price: _basePrice,
        delta24h: deltaPercentage,
        timestamp: DateTime.now(),
      );

      // Push event into the controller sink
      _tickerController.sink.add(tick);
    });
  }

  void _toggleSubscriptionPause() {
    if (_manualAlertSubscription == null) return;

    setState(() {
      if (_isSubscriptionPaused) {
        _manualAlertSubscription!.resume();
        _isSubscriptionPaused = false;
      } else {
        _manualAlertSubscription!.pause();
        _isSubscriptionPaused = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Stream Telemetry'),
        actions: [
          IconButton(
            icon: Icon(_isSubscriptionPaused ? Icons.play_arrow : Icons.pause),
            tooltip: _isSubscriptionPaused ? 'Resume Alert Stream' : 'Pause Alert Stream',
            onPressed: _toggleSubscriptionPause,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // StreamBuilder Component: Real-time Price Card
            StreamBuilder<CryptoTick>(
              stream: _filteredStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Card(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Card(
                    color: Colors.red.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text('Stream Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)),
                    ),
                  );
                }

                if (snapshot.hasData) {
                  final tick = snapshot.data!;
                  final isUp = tick.delta24h >= 0;

                  return Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children:
                        [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                tick.symbol,
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade100,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(Icons.circle, color: Colors.green, size: 8),
                                    SizedBox(width: 4),
                                    Text('LIVE (active)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '\$${tick.price.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.w900,
                              color: isUp ? Colors.green.shade700 : Colors.red.shade700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(isUp ? Icons.arrow_drop_up : Icons.arrow_drop_down, color: isUp ? Colors.green : Colors.red),
                              Text(
                                '${isUp ? '+' : ''}${tick.delta24h.toStringAsFixed(2)}% (tick delta)',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isUp ? Colors.green : Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Volatility Log (${_alerts.length})',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  _isSubscriptionPaused ? 'PAUSED' : 'LISTENING',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: _isSubscriptionPaused ? Colors.amber.shade800 : Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _alerts.isEmpty
                  ? Center(
                      child: Text(
                        'Listening for volatility spikes (> 1.5%)...',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _alerts.length,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _alerts[index],
                            style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
```

## 💡 Deep-Dive Materials Included

* **8 Interview Prep Scenarios** included
* **Technology Comparisons:** Single-Subscription Stream vs Broadcast Stream, StreamBuilder vs FutureBuilder, yield vs return, Stream vs Iterable
* **Common Pitfalls & Optimizations** included
* **Architecture & Production Patterns** included

---

## 🧭 Navigation

[⬅️ Day 23: Futures, Async/Await & The Event Loop](../Day-23/README.md) | [📂 Module Index](../README.md) | [Day 25: Concurrency, Multithreading & Dart Isolates ➡️](../Day-25/README.md)

> [!TIP]
> **Interactive Experience:** To run code interactively, view full theoretical breakdowns, test interview questions, and chat with the AI Tutor, launch the **Flutter AI Tutor App**!

