import 'package:injectable/injectable.dart';

import '../../data/local/sources/curriculum_local_data_source.dart';
import '../../domain/models/curriculum/phase.dart';

/// In-memory cache for curriculum structure and pre-built roadmap skeleton.
///
/// Parsing `curriculum_index.json` and generating the roadmap skeleton on every
/// chat turn causes unnecessary I/O, JSON decoding, and string allocations.
/// This singleton loads the index once at startup and preserves both the
/// structured [Phase] models and a compact text skeleton for AI prompt injection.
@singleton
class CurriculumCacheService {
  final CurriculumLocalDataSource _dataSource;

  List<Phase>? _cachedPhases;
  String? _cachedRoadmapSkeleton;

  CurriculumCacheService(this._dataSource);

  /// Initializes the cache by loading the curriculum index from the data source
  /// and generating the token-efficient roadmap skeleton.
  Future<void> initialize() async {
    _cachedPhases = await _dataSource.getCurriculumIndex();
    _cachedRoadmapSkeleton = formatRoadmapSkeleton(_cachedPhases!);
  }

  /// Whether the cache has been populated.
  bool get isInitialized => _cachedPhases != null;

  /// Returns the cached phases, or an empty list if not yet initialized.
  List<Phase> get phases => _cachedPhases ?? const [];

  /// Returns the pre-built compact text roadmap skeleton for AI prompt injection.
  String get roadmapSkeleton => _cachedRoadmapSkeleton ?? '';

  /// Asynchronously returns the cached phases, initializing the cache if necessary.
  Future<List<Phase>> getOrLoadPhases() async {
    if (_cachedPhases == null) {
      await initialize();
    }
    return _cachedPhases!;
  }

  /// Asynchronously returns the compact roadmap skeleton, initializing if necessary.
  Future<String> getOrLoadRoadmapSkeleton() async {
    if (_cachedRoadmapSkeleton == null) {
      await initialize();
    }
    return _cachedRoadmapSkeleton!;
  }

  /// Formats a list of [Phase] objects into a compact, token-efficient text representation.
  ///
  /// Incorporates phase, module, day titles and notes any sub-lessons defined via custom routes.
  ///
  /// Example:
  /// ```text
  /// Phase 1: Dart Programming Foundation
  ///   Module 1: Getting Started with Dart
  ///     Day 1: Introduction to Programming, Dart & Flutter Ecosystem
  ///     Day 2: Variables, Data Types, Type Inference & Null Safety
  /// ...
  ///     Day 29: Modern Reactive State Management: Riverpod & GetX (Sub-lessons: riverpod, getx)
  /// ```
  static String formatRoadmapSkeleton(List<Phase> phases) {
    final buffer = StringBuffer();
    for (final phase in phases) {
      buffer.writeln('Phase ${phase.id}: ${phase.title}');
      for (final module in phase.modules) {
        buffer.writeln('  Module ${module.id}: ${module.title}');
        for (final day in module.days) {
          if (day.customRoute != null && day.customRoute!.isNotEmpty) {
            final subLessons = day.customRoute!
                .map((path) => path.split('/').last.replaceAll('.json', ''))
                .join(', ');
            buffer.writeln(
              '    Day ${day.day}: ${day.title} (Sub-lessons: $subLessons)',
            );
          } else {
            buffer.writeln('    Day ${day.day}: ${day.title}');
          }
        }
      }
    }
    return buffer.toString().trimRight();
  }
}
