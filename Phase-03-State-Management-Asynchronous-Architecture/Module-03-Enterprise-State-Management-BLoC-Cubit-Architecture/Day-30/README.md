# 📘 Day 30: Predictable State Mutation with Cubit & Flutter Bloc Widgets

**Module 03:** [Enterprise State Management: BLoC & Cubit Architecture](../README.md) • **Phase 03:** [State Management & Asynchronous Architecture](../../README.md)

> [!NOTE]
> **Lesson Objective:** Master Cubit as a lightweight, streamlined subset of the BLoC pattern. Learn how Cubit eliminates event boilerplate by exposing direct functions that emit immutable states, how to inject Cubits using BlocProvider, how to handle UI rendering with BlocBuilder and BlocSelector, and how to execute side effects like dialogs and snackbars with BlocListener and BlocConsumer.

**Tags:** `Flutter` `State Management` `Cubit` `flutter_bloc` `BlocProvider` `BlocBuilder` `BlocListener` `BlocConsumer` `BlocSelector`

---

## 🚦 Prerequisites
Streams & Reactive Programming; Scoped State & Provider Pattern; Clean Architecture & Separation of Concerns.
You should understand Dart stream subscriptions, asynchronous event broadcasting, and the fundamentals of UI/business logic separation.

## 📖 Overview
While the original BLoC pattern provided exceptional predictability and strict separation of concerns, early Flutter teams often complained about the overhead of writing events, event handlers, and streams for straightforward state mutations. In response, Felix Angelov and the BLoC team introduced **Cubit** as a lightweight, streamlined subset of BLoC.

Cubit replaces formal event classes with public methods. Instead of dispatching an event to an internal stream sink, the UI simply calls a method on the Cubit. The method executes logic and calls `emit(newState)` to update the active state.

```text
┌────────────────────────┐         ┌────────────────────────┐
│         Cubit          │         │          BLoC          │
├────────────────────────┤         ├────────────────────────┤
│ UI calls functions:    │         │ UI dispatches events:  │
│ cubit.increment()      │         │ bloc.add(Increment())  │
│                        │         │                        │
│ Direct execution       │         │ Event queue + stream   │
│ emit(newState)         │         │ on<Event>((e, emit)...)│
└────────────────────────┘         └────────────────────────┘
```

## 📚 Topics Covered
* **1. The Genesis of Cubit: Streamlined State Mutation**: While the original BLoC pattern provided exceptional predictability and strict separation of concerns, early Flutter teams often complain...
* **2. Anatomy of a Cubit**: 1. Updates the Cubit's current `state` getter synchronously.
* **3. The flutter_bloc Presentation Widget Ecosystem**: `BlocConsumer` unifies `BlocBuilder` and `BlocListener` into a single widget, eliminating nested boilerplate when a widget needs to both ...
* **4. State Immutability and Equatable**: By subclassing `Equatable` or using Dart 3 sealed class records, equality comparison is evaluated by property values rather than memory a...
* **5. Global Auditing with BlocObserver**: One of the most powerful features of the BLoC library is `BlocObserver`. By setting `Bloc.observer = MyBlocObserver()`, developers can in...

## 🎯 Implementation Objective
Build a production-grade FinTech Digital Wallet & Transfer Application demonstrating Cubit state management, immutable state architectures with Equatable, BlocProvider, BlocConsumer, BlocSelector, and centralized lifecycle auditing with BlocObserver.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

void main() {
  // 1. Centralized State Auditing
  Bloc.observer = WalletBlocObserver();
  runApp(const DigitalWalletApp());
}

/// Custom BlocObserver tracking global state transitions.
class WalletBlocObserver extends BlocObserver {
  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    debugPrint('🔄 [${bloc.runtimeType}] Changed from ${change.currentState.runtimeType} to ${change.nextState.runtimeType}');
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    debugPrint('🚨 [${bloc.runtimeType}] Error: $error');
    super.onError(bloc, error, stackTrace);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 1. DOMAIN MODELS & IMMUTABLE STATES
// ─────────────────────────────────────────────────────────────────────────────

enum Currency { usd, eur, gbp }

class WalletTransaction extends Equatable {
  final String id;
  final String recipient;
  final double amount;
  final Currency currency;
  final DateTime timestamp;

  const WalletTransaction({
    required this.id,
    required this.recipient,
    required this.amount,
    required this.currency,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [id, recipient, amount, currency, timestamp];
}

sealed class WalletState extends Equatable {
  const WalletState();
  @override
  List<Object?> get props => [];
}

class WalletInitial extends WalletState {}

class WalletLoading extends WalletState {}

class WalletLoaded extends WalletState {
  final double balance;
  final Currency selectedCurrency;
  final List<WalletTransaction> transactions;
  final String? notificationMessage;

  const WalletLoaded({
    required this.balance,
    required this.selectedCurrency,
    required this.transactions,
    this.notificationMessage,
  });

  WalletLoaded copyWith({
    double? balance,
    Currency? selectedCurrency,
    List<WalletTransaction>? transactions,
    String? notificationMessage,
    bool clearNotification = false,
  }) {
    return WalletLoaded(
      balance: balance ?? this.balance,
      selectedCurrency: selectedCurrency ?? this.selectedCurrency,
      transactions: transactions ?? this.transactions,
      notificationMessage:
          clearNotification ? null : (notificationMessage ?? this.notificationMessage),
    );
  }

  @override
  List<Object?> get props => [balance, selectedCurrency, transactions, notificationMessage];
}

class WalletError extends WalletState {
  final String errorMessage;
  const WalletError(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}

// ─────────────────────────────────────────────────────────────────────────────
// 2. CUBIT CONTROLLER
// ─────────────────────────────────────────────────────────────────────────────

class WalletCubit extends Cubit<WalletState> {
  WalletCubit() : super(WalletInitial());

  Future<void> initializeWallet() async {
    emit(WalletLoading());
    // Simulate secure backend fetch
    await Future.delayed(const Duration(milliseconds: 600));
    emit(WalletLoaded(
      balance: 12500.50,
      selectedCurrency: Currency.usd,
      transactions: [
        WalletTransaction(
          id: 'tx_01',
          recipient: 'Cloud Services Hosting',
          amount: 149.99,
          currency: Currency.usd,
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        WalletTransaction(
          id: 'tx_02',
          recipient: 'Design System Team',
          amount: 450.00,
          currency: Currency.usd,
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ],
    ));
  }

  void switchCurrency(Currency newCurrency) {
    if (state is! WalletLoaded) return;
    final current = state as WalletLoaded;
    emit(current.copyWith(selectedCurrency: newCurrency));
  }

  Future<void> sendTransfer({
    required String recipient,
    required double amount,
  }) async {
    if (state is! WalletLoaded) return;
    final current = state as WalletLoaded;

    if (recipient.trim().isEmpty) {
      emit(current.copyWith(notificationMessage: 'Recipient cannot be empty!'));
      return;
    }

    if (amount <= 0 || amount > current.balance) {
      emit(current.copyWith(notificationMessage: 'Insufficient wallet balance!'));
      return;
    }

    // Optimistic emission of updated balance
    final newTx = WalletTransaction(
      id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
      recipient: recipient.trim(),
      amount: amount,
      currency: current.selectedCurrency,
      timestamp: DateTime.now(),
    );

    emit(current.copyWith(
      balance: current.balance - amount,
      transactions: [newTx, ...current.transactions],
      notificationMessage: 'Successfully transferred $${amount.toStringAsFixed(2)} to $recipient',
    ));
  }

  void clearNotification() {
    if (state is! WalletLoaded) return;
    final current = state as WalletLoaded;
    emit(current.copyWith(clearNotification: true));
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 3. PRESENTATION LAYER (Flutter Widgets)
// ─────────────────────────────────────────────────────────────────────────────

class DigitalWalletApp extends StatelessWidget {
  const DigitalWalletApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cubit FinTech Wallet',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.teal,
        useMaterial3: true,
      ),
      home: BlocProvider(
        create: (context) => WalletCubit()..initializeWallet(),
        child: const WalletHomeScreen(),
      ),
    );
  }
}

class WalletHomeScreen extends StatelessWidget {
  const WalletHomeScreen({super.key});

  void _showTransferSheet(BuildContext context) {
    final recipientController = TextEditingController();
    final amountController = TextEditingController();
    final walletCubit = context.read<WalletCubit>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bottomSheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(bottomSheetContext).viewInsets.bottom + 24,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'New Outgoing Transfer',
                style: Theme.of(bottomSheetContext).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: recipientController,
                decoration: const InputDecoration(
                  labelText: 'Recipient Name / IBAN',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Transfer Amount',
                  prefixText: '$ ',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: () {
                  final parsed = double.tryParse(amountController.text) ?? 0.0;
                  walletCubit.sendTransfer(
                    recipient: recipientController.text,
                    amount: parsed,
                  );
                  Navigator.pop(bottomSheetContext);
                },
                icon: const Icon(Icons.send_rounded),
                label: const Text('Confirm Transfer'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enterprise Wallet'),
        centerTitle: true,
        actions: [
          // BlocSelector: Surgical Rebuild strictly when selected currency changes
          BlocSelector<WalletCubit, WalletState, Currency>(
            selector: (state) =>
                state is WalletLoaded ? state.selectedCurrency : Currency.usd,
            builder: (context, currency) {
              return Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: SegmentedButton<Currency>(
                  segments: const [
                    ButtonSegment(value: Currency.usd, label: Text('USD')),
                    ButtonSegment(value: Currency.eur, label: Text('EUR')),
                  ],
                  selected: {currency},
                  onSelectionChanged: (set) {
                    context.read<WalletCubit>().switchCurrency(set.first);
                  },
                ),
              );
            },
          ),
        ],
      ),
      // BlocConsumer: Combines UI rebuilding with one-off feedback notifications
      body: BlocConsumer<WalletCubit, WalletState>(
        listener: (context, state) {
          if (state is WalletLoaded && state.notificationMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.notificationMessage!),
                duration: const Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
              ),
            );
            context.read<WalletCubit>().clearNotification();
          }
        },
        builder: (context, state) {
          return switch (state) {
            WalletInitial() || WalletLoading() => const Center(
                child: CircularProgressIndicator(),
              ),
            WalletError(:final errorMessage) => Center(
                child: Text('Error: $errorMessage'),
              ),
            WalletLoaded(:final balance, :final transactions) => ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  _BalanceCard(balance: balance),
                  const SizedBox(height: 24),
                  Text(
                    'Recent Activity',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  ...transactions.map((tx) => _TransactionTile(transaction: tx)),
                ],
              ),
          };
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showTransferSheet(context),
        icon: const Icon(Icons.swap_horiz_rounded),
        label: const Text('Send Funds'),
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  final double balance;
  const _BalanceCard({required this.balance});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.teal.shade700, Colors.teal.shade900],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.teal.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Available Liquidity',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            '$${balance.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final WalletTransaction transaction;
  const _TransactionTile({required this.transaction});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.teal.shade50,
          child: Icon(Icons.arrow_upward_rounded, color: Colors.teal.shade700),
        ),
        title: Text(transaction.recipient, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(transaction.timestamp.toLocal().toString().split('.')[0]),
        trailing: Text(
          '-$${transaction.amount.toStringAsFixed(2)}',
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent),
        ),
      ),
    );
  }
}
```

## 💡 Deep-Dive Materials Included

* **6 Interview Prep Scenarios** included
* **Technology Comparisons:** Cubit vs ChangeNotifier, Cubit vs Full BLoC, flutter_bloc Consumer Widgets Matrix
* **Common Pitfalls & Optimizations** included
* **Architecture & Production Patterns** included

---

## 🧭 Navigation

[📂 Module Index](../README.md) | [Day 31: Enterprise Event-Driven Architecture with BLoC & Concurrency Transformers ➡️](../Day-31/README.md)

> [!TIP]
> **Interactive Experience:** To run code interactively, view full theoretical breakdowns, test interview questions, and chat with the AI Tutor, launch the **Flutter AI Tutor App**!

