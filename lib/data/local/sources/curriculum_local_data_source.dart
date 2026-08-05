import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';

import '../../../domain/models/curriculum/phase.dart';

/// Local data source responsible for loading curriculum content from bundled assets.
///
/// All data is read from `assets/curriculum/curriculum_index.json` at runtime via [rootBundle].
@singleton
class CurriculumLocalDataSource {
  /// Loads and parses `curriculum_index.json`, returning the list of [Phase] objects.
  Future<List<Phase>> getCurriculumIndex() async {
    final jsonString = await rootBundle.loadString(
      'assets/curriculum/curriculum_index.json',
    );
    final data = json.decode(jsonString) as Map<String, dynamic>;
    final phaseList = (data['phases'] as List)
        .map((p) => Phase.fromJson(p as Map<String, dynamic>))
        .toList();
    return phaseList;
  }
}
