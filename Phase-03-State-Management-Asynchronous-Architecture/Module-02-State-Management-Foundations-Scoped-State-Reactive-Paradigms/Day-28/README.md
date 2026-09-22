# 📘 Day 28: Scoped State & Dependency Injection with Provider

**Module 02:** [State Management Foundations, Scoped State & Reactive Paradigms](../README.md) • **Phase 03:** [State Management & Asynchronous Architecture](../../README.md)

> [!NOTE]
> **Lesson Objective:** Master scoped state management and dependency injection using Provider. Understand how InheritedNotifier powers ChangeNotifierProvider under the hood, how to consume state with context.watch, context.read, and context.select, how Consumer and Selector widgets surgically isolate widget tree rebuilds, and how MultiProvider organizes scalable enterprise dependency trees.

**Tags:** `Flutter` `State Management` `Provider` `ChangeNotifierProvider` `Consumer` `Selector` `InheritedNotifier` `Dependency Injection`

---

## 🚦 Prerequisites
InheritedWidget & InheritedModel; ChangeNotifier & ListenableBuilder; ValueNotifier & Surgical Rebuilds.
You should understand how InheritedElement maintains a map of dependent elements, how notifyListeners dispatches invalidations, and why passing controllers down constructor hierarchies is an anti-pattern.

## 📖 Overview
While Flutter's native `InheritedWidget` is fast and built into the engine, writing raw `InheritedWidget` implementations by hand presents several architectural hurdles in production:

1. **High Boilerplate**: Every shared state model requires creating an `InheritedWidget` subclass, implementing `updateShouldNotify`, and wrapping it in a `StatefulWidget` to manage mutations.
2. **Manual Disposal & Lifecycle Management**: Developers must manually remember to call `.dispose()` on underlying streams, controllers, and notifiers when the widget tree unmounts.
3. **Nested Pyramid of Doom**: Exposing five different ambient services requires nesting five layers of widgets in the root tree.
4. **No Fine-Grained Value Selection**: Out of the box, `InheritedWidget` invalidates every dependent indiscriminately unless complex `InheritedModel` aspect logic is handwritten.

To solve these challenges, Remi Rousselet created **`package:provider`**, which was subsequently adopted by the official Flutter team as the community-standard recommendation for tree-scoped state management and dependency injection.

## 📚 Topics Covered
* **1. Why Provider? Moving Beyond Raw InheritedWidget**: 1. **High Boilerplate**: Every shared state model requires creating an `InheritedWidget` subclass, implementing `updateShouldNotify`, and...
* **2. Core Provider Primitives**
* **3. The BuildContext Consumption APIs**: Locates the nearest ancestor provider of type `T` and **registers the calling widget as a dependent**. Whenever `T` calls `notifyListener...
* **4. Consumer and Selector Widgets**: Wraps a subtree and provides access to `T` through its `builder: (context, value, child) => ...` function. Only the widget returned by `b...
* **5. Under the Hood: InheritedNotifier & InheritedProvider**: How does `ChangeNotifierProvider` work internally? It bridges `ChangeNotifier` to the framework by wrapping it inside an **`InheritedNoti...

## 🎯 Implementation Objective
Build a production-grade Workspace & Task Management Application demonstrating Scoped State and Dependency Injection using MultiProvider, ChangeNotifierProvider, context.watch, context.read, context.select, and the Selector surgical rebuild widget.

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const WorkspaceApp());
}

/// Root application configuring MultiProvider dependency tree.
class WorkspaceApp extends StatelessWidget {
  const WorkspaceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // 1. Pure Dependency Injection (Repository)
        Provider<TaskRepository>(
          create: (_) => TaskRepository(),
        ),
        // 2. Scoped Observable State (ChangeNotifierProvider)
        ChangeNotifierProvider<WorkspaceController>(
          create: (context) => WorkspaceController(
            repository: context.read<TaskRepository>(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Provider Scoped Workspace',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorSchemeSeed: Colors.indigo,
          useMaterial3: true,
        ),
        home: const WorkspaceDashboardScreen(),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 1. DOMAIN LAYER & SERVICE REPOSITORY
// ─────────────────────────────────────────────────────────────────────────────

enum TaskPriority { low, medium, high }

class TaskItem {
  final String id;
  final String title;
  final TaskPriority priority;
  bool isCompleted;

  TaskItem({
    required this.id,
    required this.title,
    this.priority = TaskPriority.medium,
    this.isCompleted = false,
  });
}

/// Data repository injected via Provider<TaskRepository>
class TaskRepository {
  List<TaskItem> getInitialTasks() {
    return [
      TaskItem(id: 't1', title: 'Review Flutter 3.24 Release Notes', priority: TaskPriority.high),
      TaskItem(id: 't2', title: 'Refactor Auth Tree to MultiProvider', priority: TaskPriority.medium),
      TaskItem(id: 't3', title: 'Audit Widget Build Profiles in DevTools', priority: TaskPriority.high),
      TaskItem(id: 't4', title: 'Update CI/CD Integration Test Pipeline', priority: TaskPriority.low),
    ];
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 2. APPLICATION STATE (ChangeNotifier)
// ─────────────────────────────────────────────────────────────────────────────

class WorkspaceController extends ChangeNotifier {
  final TaskRepository _repository;
  final List<TaskItem> _tasks = [];
  String _searchQuery = '';

  WorkspaceController({required TaskRepository repository}) : _repository = repository {
    _tasks.addAll(_repository.getInitialTasks());
  }

  List<TaskItem> get tasks => List.unmodifiable(
        _searchQuery.isEmpty
            ? _tasks
            : _tasks.where((t) => t.title.toLowerCase().contains(_searchQuery.toLowerCase())),
      );

  int get totalCount => _tasks.length;
  int get completedCount => _tasks.where((t) => t.isCompleted).length;
  double get completionPercentage => _tasks.isEmpty ? 0.0 : completedCount / totalCount;

  void toggleTask(String id) {
    final taskIndex = _tasks.indexWhere((t) => t.id == id);
    if (taskIndex != -1) {
      _tasks[taskIndex].isCompleted = !_tasks[taskIndex].isCompleted;
      notifyListeners();
    }
  }

  void addTask(String title, TaskPriority priority) {
    if (title.trim().isEmpty) return;
    _tasks.insert(
      0,
      TaskItem(
        id: 'task_${DateTime.now().millisecondsSinceEpoch}',
        title: title.trim(),
        priority: priority,
      ),
    );
    notifyListeners();
  }

  void deleteTask(String id) {
    _tasks.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 3. PRESENTATION LAYER (Screens & Surgical Consumers)
// ─────────────────────────────────────────────────────────────────────────────

class WorkspaceDashboardScreen extends StatelessWidget {
  const WorkspaceDashboardScreen({super.key});

  void _showAddTaskDialog(BuildContext context) {
    final textController = TextEditingController();
    TaskPriority selectedPriority = TaskPriority.medium;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('New Workspace Task'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: textController,
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: 'Task Title',
                    hintText: 'e.g. Implement Riverpod Notifiers',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<TaskPriority>(
                  value: selectedPriority,
                  decoration: const InputDecoration(labelText: 'Priority', border: OutlineInputBorder()),
                  items: TaskPriority.values.map((p) {
                    return DropdownMenuItem(value: p, child: Text(p.name.toUpperCase()));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setDialogState(() => selectedPriority = val);
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  // READ PATTERN: Call method without subscribing to rebuilds
                  context.read<WorkspaceController>().addTask(
                        textController.text,
                        selectedPriority,
                      );
                  Navigator.of(dialogContext).pop();
                },
                child: const Text('Create'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sprint Workspace'),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(60),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: _WorkspaceSearchInput(),
          ),
        ),
      ),
      body: const Column(
        children: [
          // SURGICAL REBUILD: Only rebuilds when completion ratio changes!
          _WorkspaceProgressHeader(),
          Divider(height: 1),
          Expanded(child: _TaskListSection()),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        // context.read prevents this FAB from ever rebuilding
        onPressed: () => _showAddTaskDialog(context),
        icon: const Icon(Icons.add_task),
        label: const Text('New Task'),
      ),
    );
  }
}

/// Search bar demonstrating context.read in callbacks
class _WorkspaceSearchInput extends StatelessWidget {
  const _WorkspaceSearchInput();

  @override
  Widget build(BuildContext context) {
    return SearchBar(
      hintText: 'Filter workspace tasks...',
      leading: const Icon(Icons.search),
      onChanged: (query) {
        // Uses context.read to dispatch query without triggering rebuild here
        context.read<WorkspaceController>().updateSearchQuery(query);
      },
    );
  }
}

/// Header displaying progress using Selector for selective rebuild isolation
class _WorkspaceProgressHeader extends StatelessWidget {
  const _WorkspaceProgressHeader();

  @override
  Widget build(BuildContext context) {
    // SELECTOR: Projects completion percentage double.
    // Rebuilds ONLY if completionPercentage value differs!
    return Selector<WorkspaceController, double>(
      selector: (_, controller) => controller.completionPercentage,
      builder: (context, percentage, child) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Sprint Completion Progress', style: TextStyle(fontWeight: FontWeight.w600)),
                  Text(
                    '${(percentage * 100).toInt()}%',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              LinearProgressIndicator(
                value: percentage,
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// List section using Consumer for granular UI binding
class _TaskListSection extends StatelessWidget {
  const _TaskListSection();

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkspaceController>(
      builder: (context, controller, child) {
        final tasks = controller.tasks;

        if (tasks.isEmpty) {
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 12),
                Text('No matching tasks found.', style: TextStyle(color: Colors.grey)),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: tasks.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final task = tasks[index];
            return _TaskTile(task: task);
          },
        );
      },
    );
  }
}

class _TaskTile extends StatelessWidget {
  final TaskItem task;

  const _TaskTile({required this.task});

  Color _priorityColor(TaskPriority p) {
    switch (p) {
      case TaskPriority.high:
        return Colors.red.shade600;
      case TaskPriority.medium:
        return Colors.amber.shade700;
      case TaskPriority.low:
        return Colors.blue.shade600;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Checkbox(
          value: task.isCompleted,
          onChanged: (_) {
            // Dispatches toggle without subscribing tile wrapper
            context.read<WorkspaceController>().toggleTask(task.id);
          },
        ),
        title: Text(
          task.title,
          style: TextStyle(
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
            color: task.isCompleted ? Colors.grey : Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _priorityColor(task.priority).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                task.priority.name.toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: _priorityColor(task.priority),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 20, color: Colors.grey),
              onPressed: () {
                context.read<WorkspaceController>().deleteTask(task.id);
              },
            ),
          ],
        ),
      ),
    );
  }
}
```

## 💡 Deep-Dive Materials Included

* **7 Interview Prep Scenarios** included
* **Technology Comparisons:** context.watch vs context.read vs context.select, Consumer vs Selector, Raw InheritedWidget vs Provider
* **Common Pitfalls & Optimizations** included
* **Architecture & Production Patterns** included

---

## 🧭 Navigation

[⬅️ Day 27: Surgical Rebuilds with ValueNotifier & ValueListenableBuilder](../Day-27/README.md) | [📂 Module Index](../README.md) | [Day 29: Modern Declarative & Micro-Framework Reactive State ➡️](../Day-29/README.md)

> [!TIP]
> **Interactive Experience:** To run code interactively, view full theoretical breakdowns, test interview questions, and chat with the AI Tutor, launch the **Flutter AI Tutor App**!

