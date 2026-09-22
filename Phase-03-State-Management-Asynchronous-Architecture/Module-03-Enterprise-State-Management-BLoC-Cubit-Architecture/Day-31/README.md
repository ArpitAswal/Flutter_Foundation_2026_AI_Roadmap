# 📘 Day 31: Enterprise Event-Driven Architecture with BLoC & Concurrency Transformers

**Module 03:** [Enterprise State Management: BLoC & Cubit Architecture](../README.md) • **Phase 03:** [State Management & Asynchronous Architecture](../../README.md)

> [!NOTE]
> **Lesson Objective:** Master the full BLoC pattern for mission-critical enterprise applications. Learn how BLoC decouples UI events from state transitions through strict event-driven architecture, how the event queue processes incoming actions, how to use bloc_concurrency transformers (droppable, restartable, sequential, concurrent) to handle race conditions and rapid user interactions, and how to build deterministic state machines with Equatable.

**Tags:** `Flutter` `State Management` `BLoC` `flutter_bloc` `bloc_concurrency` `Event-Driven` `State Machine` `Equatable` `Transformers`

---

## 🚦 Prerequisites
Asynchronous Dart & Reactive Streams; Dart Isolates & Concurrency; Cubit & Flutter Bloc Widgets.
You should understand Dart StreamControllers, event loop queues, async generators, and the core flutter_bloc presentation widgets (BlocProvider, BlocBuilder, BlocListener).

## 📖 Overview
While Cubit provides a direct, function-based interface for state mutation, the full BLoC (Business Logic Component) pattern enforces a formal Event-Driven Architecture (EDA). In BLoC, the UI is completely decoupled from state mutation logic:

1. The UI has zero direct access to methods that emit states.
2. The UI communicates its intent exclusively by dispatching typed Events into the BLoC's event sink: `bloc.add(SubmitOrderEvent(order))`.
3. The BLoC processes events through an internal asynchronous Event Queue.
4. The BLoC emits typed States into an output stream consumed by the UI.

```text
┌──────────────┐             ┌──────────────┐             ┌──────────────┐
│  Flutter UI  │ ──Event───▶ │  Event Queue │ ──Stream──▶ │     BLoC     │
│ Presentation │             │  Transformer │             │ Event Handler│
└──────────────┘             └──────────────┘             └──────┬───────┘
       ▲                                                         │
       │                                                         │
       └─────────────────────────State Stream────────────────────┘
```

## 📚 Topics Covered
* **1. The BLoC Paradigm: Strict Event-Driven Architecture**: 1. The UI has zero direct access to methods that emit states.
* **2. Anatomy of an Enterprise BLoC**
* **3. Event Queuing & Concurrency Transformers**: By default, BLoC processes incoming events sequentially: if three `SubmitTradeOrder` events arrive while the first is awaiting an HTTP re...
* **4. State Transitions and the BlocObserver Audit Pipeline**: `currentState`: The state before the transition.
* **5. Equatable vs Freezed for Event and State Models**: `package:equatable`: Pure Dart class inheritance with `props` list. Requires zero code generation (`build_runner`) and offers immediate c...

## 🎯 Implementation Objective
Build a production-grade Real-Time Stock Market & Trading Terminal demonstrating strict Event-Driven BLoC architecture, custom concurrency transformers (droppable for order executions and restartable for debounced stock lookups), immutable state unions with Equatable, and comprehensive transition auditing.

```dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';

void main() {
  Bloc.observer = TerminalBlocObserver();
  runApp(const TradingTerminalApp());
}

/// Global Telemetry and Audit Observer
class TerminalBlocObserver extends BlocObserver {
  @override
  void onEvent(BlocBase bloc, Object? event) {
    super.onEvent(bloc, event);
    debugPrint('📥 [${bloc.runtimeType}] Event Added: ${event.runtimeType}');
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    debugPrint('🔀 [${bloc.runtimeType}] Transition: Event ${transition.event.runtimeType} | Current: ${transition.currentState.runtimeType} -> Next: ${transition.nextState.runtimeType}');
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    debugPrint('🚨 [${bloc.runtimeType}] Fatal Error: $error');
    super.onError(bloc, error, stackTrace);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 1. DOMAIN MODELS & IMMUTABLE DATA
// ─────────────────────────────────────────────────────────────────────────────

class StockAsset extends Equatable {
  final String symbol;
  final String companyName;
  final double currentPrice;
  final double changePercent;

  const StockAsset({
    required this.symbol,
    required this.companyName,
    required this.currentPrice,
    required this.changePercent,
  });

  @override
  List<Object?> get props => [symbol, companyName, currentPrice, changePercent];
}

// ─────────────────────────────────────────────────────────────────────────────
// 2. FORMAL BLOC EVENTS
// ─────────────────────────────────────────────────────────────────────────────

sealed class TradingEvent extends Equatable {
  const TradingEvent();
  @override
  List<Object?> get props => [];
}

/// Dispatched when user types in the search query (uses restartable transformer)
class SearchStockQueryChanged extends TradingEvent {
  final String query;
  const SearchStockQueryChanged(this.query);
  @override
  List<Object?> get props => [query];
}

/// Dispatched when user clicks to buy stock (uses droppable transformer)
class ExecuteOrderRequested extends TradingEvent {
  final String symbol;
  final int shares;
  final double price;

  const ExecuteOrderRequested({
    required this.symbol,
    required this.shares,
    required this.price,
  });

  @override
  List<Object?> get props => [symbol, shares, price];
}

/// Resets terminal notification banner
class ClearOrderNotification extends TradingEvent {}

// ─────────────────────────────────────────────────────────────────────────────
// 3. FORMAL BLOC STATES
// ─────────────────────────────────────────────────────────────────────────────

sealed class TradingState extends Equatable {
  const TradingState();
  @override
  List<Object?> get props => [];
}

class TradingInitial extends TradingState {}

class TradingSearching extends TradingState {}

class TradingLoaded extends TradingState {
  final List<StockAsset> searchResults;
  final double userPortfolioBalance;
  final bool isOrderProcessing;
  final String? notificationBanner;

  const TradingLoaded({
    required this.searchResults,
    required this.userPortfolioBalance,
    this.isOrderProcessing = false,
    this.notificationBanner,
  });

  TradingLoaded copyWith({
    List<StockAsset>? searchResults,
    double? userPortfolioBalance,
    bool? isOrderProcessing,
    String? notificationBanner,
    bool clearBanner = false,
  }) {
    return TradingLoaded(
      searchResults: searchResults ?? this.searchResults,
      userPortfolioBalance: userPortfolioBalance ?? this.userPortfolioBalance,
      isOrderProcessing: isOrderProcessing ?? this.isOrderProcessing,
      notificationBanner: clearBanner ? null : (notificationBanner ?? this.notificationBanner),
    );
  }

  @override
  List<Object?> get props => [searchResults, userPortfolioBalance, isOrderProcessing, notificationBanner];
}

class TradingFailure extends TradingState {
  final String message;
  const TradingFailure(this.message);
  @override
  List<Object?> get props => [message];
}

// ─────────────────────────────────────────────────────────────────────────────
// 4. ENTERPRISE BLOC WITH CONCURRENCY TRANSFORMERS
// ─────────────────────────────────────────────────────────────────────────────

class TradingBloc extends Bloc<TradingEvent, TradingState> {
  // Mock In-Memory Stock Catalog
  static const List<StockAsset> _allStocks = [
    StockAsset(symbol: 'GOOGL', companyName: 'Alphabet Inc.', currentPrice: 182.40, changePercent: 1.85),
    StockAsset(symbol: 'AAPL', companyName: 'Apple Inc.', currentPrice: 228.15, changePercent: -0.42),
    StockAsset(symbol: 'MSFT', companyName: 'Microsoft Corporation', currentPrice: 425.80, changePercent: 0.95),
    StockAsset(symbol: 'NVDA', companyName: 'NVIDIA Corporation', currentPrice: 119.50, changePercent: 3.40),
    StockAsset(symbol: 'AM

## 💡 Deep-Dive Materials Included

* **6 Interview Prep Scenarios** included
* **Technology Comparisons:** BLoC vs Cubit Architectural Comparison, bloc_concurrency Transformers Matrix, Equatable vs Freezed for BLoC States and Events
* **Common Pitfalls & Optimizations** included
* **Architecture & Production Patterns** included

---

## 🧭 Navigation

[⬅️ Day 30: Predictable State Mutation with Cubit & Flutter Bloc Widgets](../Day-30/README.md) | [📂 Module Index](../README.md) | [Day 32: State Management Architectural Synthesis & Multi-Engine Decision Matrix ➡️](../Day-32/README.md)

> [!TIP]
> **Interactive Experience:** To run code interactively, view full theoretical breakdowns, test interview questions, and chat with the AI Tutor, launch the **Flutter AI Tutor App**!

