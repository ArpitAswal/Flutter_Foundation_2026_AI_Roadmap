# 📘 Day 38: Offline-First Repository Pattern, Caching & Data Sync

**Module 02:** [Local Persistence & Offline-First Architecture](../README.md) • **Phase 04:** [Networking, REST APIs & Data Persistence](../../README.md)

> [!NOTE]
> **Lesson Objective:** Master the Single Source of Truth (SSOT) offline-first architectural pattern. Learn how the repository coordinates local database caching with background remote network synchronization, how to persist offline mutation queues, how to handle network recovery with exponential backoff, and how to execute optimistic UI updates with automated rollback.

**Tags:** `Flutter` `Offline-First` `Repository Pattern` `Caching` `Data Sync` `Optimistic UI` `Architecture` `Clean Architecture`

---

## 🚦 Prerequisites
HTTP Networking Fundamentals & Dio Architecture; Local Persistence & NoSQL/SQL Engines; Clean Architecture & Dependency Injection.
You should understand remote data sources, local database caching, and repository pattern separation of concerns.

## 📖 Overview
In the early days of mobile development, apps followed a **Network-First (Online-Dependent)** model: when a screen opened, the app displayed a spinner, fired an HTTP request, waited for the server to reply, and rendered the UI. If the user was in an elevator, subway, or rural area with spotty coverage, the app displayed an error screen and became unusable.

Modern mobile applications adopt the **Offline-First (Single Source of Truth - SSOT)** philosophy:
- **The Local Database is the Primary Reality**: The UI never directly waits for remote network calls. The UI observes the local database (Hive, Drift, SQLite).
- **The Network is an Asynchronous Sync Engine**: Remote APIs exist to synchronize local state with cloud state in the background.
- **Zero-Latency Interactions**: Reading data and creating/updating records occurs immediately on the local database in < 5ms. The user experiences an instantaneous, butter-smooth app regardless of network conditions.

```text
┌────────────────────────────────────────────────────────────────────────┐
│                   OFFLINE-FIRST CLEAN ARCHITECTURE (SSOT)              │
├────────────────────────────────────────────────────────────────────────┤
│  Flutter Presentation Layer (UI / BLoC)                                │
│       │                                                                │
│       ├── Read Stream: Listens to Local Database (Instant!)            │
│       │                                                                │
│       ▼ Write Action: 'Create Task'                                    │
│  [ TaskRepository ]                                                    │
│       │                                                                │
│       ├── 1. Writes Task to Local Database (Immediate local render!)   │
│       │                                                                │
│       ├── 2. Enqueues Action into Local 'Mutation Sync Queue'          │
│       │                                                                │
│       ▼ (Background Sync Routine)                                      │
│  [ Sync Coordinator ] ──▶ Checks Network Connectivity                  │
│       │                                                                │
│       ├── (ONLINE) ──▶ Dispatches POST to Remote API (Dio)             │
│       │                • On Success: Clears queue entry                │
│       │                • On 409 Conflict: Resolves conflict            │
│       │                                                                │
│       └── (OFFLINE) ─▶ Suspends queue; schedules reconnect listener    │
└────────────────────────────────────────────────────────────────────────┘
```

## 📚 Topics Covered
* **1. The Offline-First Engineering Philosophy**: In the early days of mobile development, apps followed a **Network-First (Online-Dependent)** model: when a screen opened, the app displa...
* **2. Caching Strategies & Taxonomy**: 1. Read from local cache and emit immediately to UI (0ms latency).
* **3. The Offline Mutation Queue & Conflict Resolution**: If a user edits a task while in airplane mode and terminates the app, the pending update must **not be lost**. The mutation queue must be...
* **4. Optimistic UI Updates with Automated Rollback**: 1. Update local database with a temporary `syncStatus = SyncStatus.pending`.

## 🎯 Implementation Objective
Build a production-grade Offline-First Task & Project Synchronization manager in Flutter. Demonstrate the Single Source of Truth (SSOT) repository pattern, persistent local caching via Hive, an offline mutation sync queue with automated retry upon network reconnection, and optimistic UI updates with rollback mechanics.

```dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  // 1. Initialize local cache boxes
  final taskBox = await Hive.openBox<Map>('tasks_cache');
  final queueBox = await Hive.openBox<Map>('sync_queue');

  // 2. Wire repository with simulated remote API
  final remoteApi = MockTaskRemoteApi();
  final repository = OfflineFirstTaskRepository(
    taskBox: taskBox,
    queueBox: queueBox,
    remoteApi: remoteApi,
  );

  runApp(OfflineFirstApp(repository: repository, remoteApi: remoteApi));
}

// ─────────────────────────────────────────────────────────────────────────────
// 1. DOMAIN MODELS & ENUMS
// ─────────────────────────────────────────────────────────────────────────────

enum SyncStatus { synced, pending, failed }

class TaskItem {
  final String id;
  final String title;
  final bool isCompleted;
  final SyncStatus syncStatus;
  final DateTime updatedAt;

  const TaskItem({
    required this.id,
    required this.title,
    required this.isCompleted,
    required this.syncStatus,
    required this.updatedAt,
  });

  TaskItem copyWith({
    String? title,
    bool? isCompleted,
    SyncStatus? syncStatus,
    DateTime? updatedAt,
  }) {
    return TaskItem(
      id: id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      syncStatus: syncStatus ?? this.syncStatus,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'isCompleted': isCompleted,
    'syncStatus': syncStatus.name,
    'updatedAt': updatedAt.millisecondsSinceEpoch,
  };

  factory TaskItem.fromMap(Map map) => TaskItem(
    id: map['id'] as String,
    title: map['title'] as String,
    isCompleted: map['isCompleted'] as bool? ?? false,
    syncStatus: SyncStatus.values.firstWhere(
      (e) => e.name == map['syncStatus'],
      orElse: () => SyncStatus.synced,
    ),
    updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] as int),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// 2. SIMULATED REMOTE API WITH NETWORK TOGGLE
// ─────────────────────────────────────────────────────────────────────────────

class MockTaskRemoteApi {
  bool isOnline = true;

  Future<void> syncTask(TaskItem task) async {
    await Future.delayed(const Duration(milliseconds: 600)); // Network latency
    if (!isOnline) {
      throw const SocketException('Simulated offline network state');
    }
  }
}

class SocketException implements Exception {
  final String message;
  const SocketException(this.message);
  @override
  String toString() => message;
}

// ─────────────────────────────────────────────────────────────────────────────
// 3. OFFLINE-FIRST REPOSITORY (SSOT)
// ─────────────────────────────────────────────────────────────────────────────

class OfflineFirstTaskRepository {
  final Box<Map> _taskBox;
  final Box<Map> _queueBox;
  final MockTaskRemoteApi _remoteApi;

  final _tasksStreamController = StreamController<List<TaskItem>>.broadcast();
  Stream<List<TaskItem>> get tasksStream => _tasksStreamController.stream;

  OfflineFirstTaskRepository({
    required Box<Map> taskBox,
    required Box<Map> queueBox,
    required MockTaskRemoteApi remoteApi,
  })  : _taskBox = taskBox,
        _queueBox = queueBox,
        _remoteApi = remoteApi {
    _emitCurrentLocalState();
    // Seed sample task if empty
    if (_taskBox.isEmpty) {
      final initial = TaskItem(
        id: 'task_01',
        title: 'Architect Offline-First Data Pipeline',
        isCompleted: false,
        syncStatus: SyncStatus.synced,
        updatedAt: DateTime.now(),
      );
      _taskBox.put(initial.id, initial.toMap());
      _emitCurrentLocalState();
    }
  }

  void _emitCurrentLocalState() {
    final tasks = _taskBox.values.map((m) => TaskItem.fromMap(m)).toList();
    tasks.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    _tasksStreamController.add(tasks);
  }

  /// Optimistic mutation: Updates local database immediately, then enqueues background sync
  Future<void> toggleTaskStatus(TaskItem task) async {
    final previousState = task;
    final updatedTask = task.copyWith(
      isCompleted: !task.isCompleted,
      syncStatus: SyncStatus.pending,
      updatedAt: DateTime.now(),
    );

    // 1. Write immediately to local database (

## 💡 Deep-Dive Materials Included

* **3 Interview Prep Scenarios** included
* **Technology Comparisons:** Caching Strategy Architectural Matrix, Optimistic UI vs Pessimistic UI
* **Common Pitfalls & Optimizations** included
* **Architecture & Production Patterns** included

---

## 🧭 Navigation

[⬅️ Day 37: Relational SQL Persistence with SQLite & Drift](../Day-37/README.md) | [📂 Module Index](../README.md)

> [!TIP]
> **Interactive Experience:** To run code interactively, view full theoretical breakdowns, test interview questions, and chat with the AI Tutor, launch the **Flutter AI Tutor App**!

