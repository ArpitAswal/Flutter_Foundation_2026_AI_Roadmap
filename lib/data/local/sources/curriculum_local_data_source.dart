import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';

import '../../../domain/models/curriculum/lesson_content.dart';
import '../../../domain/models/curriculum/phase.dart';

/// Local data source responsible for loading curriculum content from bundled assets.
///
/// - [getCurriculumIndex]: loads the lightweight skeleton index (phase → module → day titles).
/// - [getDayContent]: lazily loads heavy lesson content from an individual day JSON file.
@singleton
class CurriculumLocalDataSource {
  List<Phase>? _cachedPhases;

  /// Loads and parses `curriculum_index.json`, returning the list of [Phase] objects.
  /// The skeleton does NOT include lesson content — only titles, tags, and asset paths.
  /// Results are cached in memory after the initial read.
  Future<List<Phase>> getCurriculumIndex() async {
    if (_cachedPhases != null) {
      return _cachedPhases!;
    }
    final jsonString = await rootBundle.loadString(
      'assets/curriculum/curriculum_index.json',
    );
    final data = json.decode(jsonString) as Map<String, dynamic>;
    final phaseList = (data['phases'] as List)
        .map((p) => Phase.fromJson(p as Map<String, dynamic>))
        .toList();
    _cachedPhases = phaseList;
    return phaseList;
  }

  /// Lazily loads the full [LessonContent] for a specific day from its
  /// individual JSON file at [assetPath], e.g.
  /// `assets/curriculum/phase1/module1/day1.json`.
  Future<LessonContent> getDayContent(String assetPath) async {
    final jsonString = await rootBundle.loadString(assetPath);
    final data = json.decode(jsonString) as Map<String, dynamic>;
    return LessonContent.fromJson(data);
  }
}
