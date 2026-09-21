import 'dart:convert';
import 'dart:io';

/// Formats a number with a leading zero if needed (e.g., 1 -> 01)
String formatNum(int n) => n.toString().padLeft(2, '0');

/// Formats a title into a directory-friendly string (e.g., "Getting Started" -> "Getting-Started")
String formatDirName(String prefix, int id, String title) {
  final cleanTitle = title
      .replaceAll(RegExp(r'[^a-zA-Z0-9\s-]'), '')
      .replaceAll(RegExp(r'\s+'), '-')
      .replaceAll(RegExp(r'-+'), '-');
  return '$prefix-${formatNum(id)}-$cleanTitle';
}

/// Extracts a clean introductory overview from raw theory markdown.
String extractOverview(String? theory) {
  if (theory == null || theory.isEmpty) return '';
  final cleanTheory =
      theory.replaceAll(RegExp(r'^#+.*$', multiLine: true), '').trim();
  final paragraphs = cleanTheory
      .split('\n\n')
      .where((p) => p.trim().isNotEmpty && !p.trim().startsWith('|'))
      .toList();

  if (paragraphs.isNotEmpty) {
    final overviewText = paragraphs.take(3).map((p) => p.trim()).join('\n\n');
    return '## 📖 Overview\n$overviewText\n\n';
  }
  return '';
}

/// Extracts topic headings with clean, meaningful descriptions from theory markdown.
String extractTopics(String? theory) {
  if (theory == null || theory.isEmpty) return '';
  final chunks = theory.split(RegExp(r'^## ', multiLine: true));

  List<String> topicLines = [];
  for (int i = 1; i < chunks.length; i++) {
    final chunk = chunks[i].trim();
    if (chunk.isEmpty) continue;

    final lines = chunk.split('\n');
    final title = lines.first.trim();

    String description = '';
    bool inCodeBlock = false;

    for (int j = 1; j < lines.length; j++) {
      final line = lines[j].trim();
      if (line.startsWith('```')) {
        inCodeBlock = !inCodeBlock;
        continue;
      }
      if (inCodeBlock) continue;
      if (line.startsWith('#')) continue;

      // Skip lines that are just rhetorical leads or end with colons
      if (line.endsWith(':') ||
          line.startsWith('Imagine') ||
          line.startsWith('Many beginners') ||
          line.startsWith('For example:')) {
        continue;
      }

      // Check for explicit definition
      if (line.contains('**Definition:**')) {
        description = line.replaceAll('**Definition:**', '').trim();
        break;
      }

      // Skip markdown tables and images
      if (line.startsWith('|') || line.startsWith('![')) {
        continue;
      }

      if (line.startsWith('*') || line.startsWith('-')) {
        final cleaned = line.replaceFirst(RegExp(r'^[\*\-]\s+'), '');
        if (cleaned.length > 20 && !cleaned.endsWith(':')) {
          description = cleaned.replaceAll(RegExp(r'^\*\*(.*?)\*\*:\s*'), '').trim();
          break;
        }
        continue;
      }

      if (line.length > 20) {
        description = line.replaceAll(RegExp(r'^\*\*(.*?)\*\*:\s*'), '').trim();
        break;
      }
    }

    if (description.isNotEmpty) {
      if (description.length > 140) {
        description = '${description.substring(0, 137)}...';
      }
      topicLines.add('* **$title**: $description');
    } else {
      topicLines.add('* **$title**');
    }
  }

  if (topicLines.isNotEmpty) {
    return '## 📚 Topics Covered\n${topicLines.join('\n')}\n\n';
  }
  return '';
}

/// Extracts the objective string from implementation markdown.
String extractObjective(String? implementation) {
  if (implementation == null || implementation.isEmpty) return '';
  final match = RegExp(r'### Objective\n(.*?)(?=\n###|\Z)', dotAll: true)
      .firstMatch(implementation);
  if (match != null && match.group(1) != null) {
    return match.group(1)!.trim();
  }
  return '';
}

/// Counts interview scenarios in the day's interview questions section.
int countInterviewQuestions(String? questions) {
  if (questions == null || questions.isEmpty) return 0;
  return RegExp(r'^## Scenario', multiLine: true).allMatches(questions).length;
}

/// Extracts list of compared technologies.
String extractComparisons(String? comparisons) {
  if (comparisons == null || comparisons.isEmpty) return '';
  final headings =
      RegExp(r'^### (.*)$', multiLine: true).allMatches(comparisons);
  return headings.map((m) => m.group(1)?.trim()).where((s) => s != null && s.isNotEmpty).join(', ');
}

void main() async {
  final indexFile = File('assets/curriculum/curriculum_index.json');
  if (!await indexFile.exists()) {
    stdout.writeln('Error: Could not find curriculum_index.json');
    return;
  }

  final indexContent = await indexFile.readAsString();
  final indexData = json.decode(indexContent);
  final phases = indexData['phases'] as List;

  stdout.writeln('Generating Comprehensive, Educational GitHub README Structure...');

  for (final phase in phases) {
    final phaseNum = formatNum(phase['id']);
    final phaseTitle = phase['title'];
    final phaseDirName = formatDirName('Phase', phase['id'], phaseTitle);
    final phaseDir = Directory(phaseDirName);
    if (!await phaseDir.exists()) await phaseDir.create(recursive: true);

    final modules = phase['modules'] as List;
    int totalPhaseDays = 0;
    for (final m in modules) {
      totalPhaseDays += (m['days'] as List).length;
    }

    // ==========================================
    // 1. GENERATE PHASE README
    // ==========================================
    final phaseBuffer = StringBuffer();
    phaseBuffer.writeln('# 🎯 Phase $phaseNum: $phaseTitle\n');
    phaseBuffer.writeln('> [!NOTE]');
    phaseBuffer.writeln('> **Phase Goal:** ${phase['description']}\n');
    phaseBuffer.writeln('**Curriculum Scope:** ${modules.length} Modules • $totalPhaseDays Days of Practical Learning\n');
    phaseBuffer.writeln('---\n');

    phaseBuffer.writeln('## 🗺️ Phase Learning Roadmap\n');
    phaseBuffer.writeln('| Module | Title | Days | Core Focus |');
    phaseBuffer.writeln('| :---: | :--- | :---: | :--- |');

    for (final module in modules) {
      final modNum = formatNum(module['id']);
      final modTitle = module['title'];
      final modDays = (module['days'] as List).length;
      final modDirName = formatDirName('Module', module['id'], modTitle);
      final subtitle = module['subtitle'] ?? '';
      final shortFocus = subtitle.length > 80 ? '${subtitle.substring(0, 77)}...' : subtitle;
      phaseBuffer.writeln('| **$modNum** | [$modTitle]($modDirName/README.md) | **$modDays** | $shortFocus |');
    }
    phaseBuffer.writeln('\n---\n');

    phaseBuffer.writeln('## 📦 Detailed Module Breakdown\n');
    for (final module in modules) {
      final modNum = formatNum(module['id']);
      final modTitle = module['title'];
      final modDirName = formatDirName('Module', module['id'], modTitle);
      final days = module['days'] as List;

      phaseBuffer.writeln('### 📁 Module $modNum: [$modTitle]($modDirName/README.md)\n');
      phaseBuffer.writeln('${module['subtitle'] ?? ''}\n');
      phaseBuffer.writeln('**Curriculum Days:**\n');

      for (final day in days) {
        final dayNum = formatNum(day['day']);
        final dayTitle = day['title'];
        final dayDirName = 'Day-$dayNum';
        final tags = (day['tags'] as List).take(3).map((t) => '`$t`').join(' ');
        phaseBuffer.writeln('- **[Day $dayNum: $dayTitle]($modDirName/$dayDirName/README.md)** $tags');
      }
      phaseBuffer.writeln('\n[Explore Module $modNum Roadmap ➔]($modDirName/README.md)\n');
      phaseBuffer.writeln('---\n');
    }

    phaseBuffer.writeln('> [!TIP]');
    phaseBuffer.writeln('> **Interactive Learning:** All lessons, runnable code examples, progress tracking, and AI tutoring are available inside the **Flutter AI Tutor App**!\n');

    // ==========================================
    // 2. GENERATE MODULE & DAY READMEs
    // ==========================================
    for (final module in modules) {
      final modNum = formatNum(module['id']);
      final modTitle = module['title'];
      final modDirName = formatDirName('Module', module['id'], modTitle);
      final moduleDirPath = '${phaseDir.path}/$modDirName';
      final moduleDir = Directory(moduleDirPath);
      if (!await moduleDir.exists()) await moduleDir.create(recursive: true);

      final days = module['days'] as List;

      final moduleBuffer = StringBuffer();
      moduleBuffer.writeln('# 📦 Module $modNum: $modTitle\n');
      moduleBuffer.writeln('**Phase $phaseNum:** [$phaseTitle](../README.md)\n');
      moduleBuffer.writeln('> [!NOTE]');
      moduleBuffer.writeln('> **Overview:** ${module['subtitle'] ?? ''}\n');
      moduleBuffer.writeln('**Module Structure:** ${days.length} Days of Deep Dives & Practical Exercises\n');
      moduleBuffer.writeln('---\n');

      moduleBuffer.writeln('## 📅 Day-by-Day Learning Roadmap\n');
      moduleBuffer.writeln('| Day | Lesson Title | Key Skills & Tags | Hands-On Challenge |');
      moduleBuffer.writeln('| :---: | :--- | :--- | :--- |');

      for (final day in days) {
        final dayNum = formatNum(day['day']);
        final dayTitle = day['title'];
        final dayDirName = 'Day-$dayNum';
        final tags = (day['tags'] as List).take(3).map((t) => '`$t`').join(' ');

        // Read day objective
        final contentPath = day['content_path'] as String;
        final dayFile = File(contentPath);
        String objective = 'Build practical console program';
        if (await dayFile.exists()) {
          final dayData = json.decode(await dayFile.readAsString());
          final extracted = extractObjective(dayData['implementation']);
          if (extracted.isNotEmpty) {
            objective = extracted.length > 60 ? '${extracted.substring(0, 57)}...' : extracted;
          }
        }

        moduleBuffer.writeln('| **Day $dayNum** | [$dayTitle]($dayDirName/README.md) | $tags | $objective |');
      }
      moduleBuffer.writeln('\n---\n');

      moduleBuffer.writeln('## 📘 Detailed Lesson Overview\n');
      for (int dayIdx = 0; dayIdx < days.length; dayIdx++) {
        final day = days[dayIdx];
        final dayNum = formatNum(day['day']);
        final dayTitle = day['title'];
        final dayDirName = 'Day-$dayNum';
        final dayDirPath = '${moduleDir.path}/$dayDirName';
        final dayDir = Directory(dayDirPath);
        if (!await dayDir.exists()) await dayDir.create(recursive: true);

        final allTags = (day['tags'] as List).map((t) => '`$t`').join(' ');

        moduleBuffer.writeln('### [Day $dayNum: $dayTitle]($dayDirName/README.md)\n');
        moduleBuffer.writeln('${day['description']}\n');
        moduleBuffer.writeln('**Tags:** $allTags\n');
        moduleBuffer.writeln('[Start Day $dayNum Lesson ➔]($dayDirName/README.md)\n');
        moduleBuffer.writeln('---\n');

        // ==========================================
        // 3. GENERATE DAY README
        // ==========================================
        final dayBuffer = StringBuffer();
        dayBuffer.writeln('# 📘 Day $dayNum: $dayTitle\n');
        dayBuffer.writeln('**Module $modNum:** [$modTitle](../README.md) • **Phase $phaseNum:** [$phaseTitle](../../README.md)\n');

        dayBuffer.writeln('> [!NOTE]');
        dayBuffer.writeln('> **Lesson Objective:** ${day['description']}\n');
        dayBuffer.writeln('**Tags:** $allTags\n');
        dayBuffer.writeln('---\n');

        final contentPath = day['content_path'] as String;
        final dayFile = File(contentPath);

        if (await dayFile.exists()) {
          final dayData = json.decode(await dayFile.readAsString());

          if (dayData['prerequisites'] != null &&
              dayData['prerequisites'].toString().trim().isNotEmpty) {
            dayBuffer.writeln('## 🚦 Prerequisites\n${dayData['prerequisites']}\n');
          }

          dayBuffer.write(extractOverview(dayData['theory']));
          dayBuffer.write(extractTopics(dayData['theory']));

          final objective = extractObjective(dayData['implementation']);
          if (objective.isNotEmpty) {
            dayBuffer.writeln('## 🎯 Implementation Objective\n$objective\n');
          }

          // Additional Materials section
          List<String> materials = [];
          final iqCount = countInterviewQuestions(dayData['interview_questions']);
          if (iqCount > 0) {
            materials.add('**$iqCount Interview Prep Scenarios** included');
          }

          final comps = extractComparisons(dayData['comparisons']);
          if (comps.isNotEmpty) {
            materials.add('**Technology Comparisons:** $comps');
          }

          if (dayData['common_mistakes'] != null) {
            materials.add('**Common Pitfalls & Optimizations** included');
          }

          if (dayData['architecture'] != null) {
            materials.add('**Architecture & Production Patterns** included');
          }

          if (materials.isNotEmpty) {
            dayBuffer.writeln('## 💡 Deep-Dive Materials Included\n');
            for (final m in materials) {
              dayBuffer.writeln('* $m');
            }
            dayBuffer.writeln();
          }

          // Navigation bar
          dayBuffer.writeln('---\n');
          dayBuffer.writeln('## 🧭 Navigation\n');

          String navPrev = '';
          String navNext = '';

          if (dayIdx > 0) {
            final prevDay = days[dayIdx - 1];
            final prevNum = formatNum(prevDay['day']);
            navPrev = '[⬅️ Day $prevNum: ${prevDay['title']}](../Day-$prevNum/README.md)';
          }

          if (dayIdx < days.length - 1) {
            final nextDay = days[dayIdx + 1];
            final nextNum = formatNum(nextDay['day']);
            navNext = '[Day $nextNum: ${nextDay['title']} ➡️](../Day-$nextNum/README.md)';
          }

          final modLink = '[📂 Module Index](../README.md)';
          if (navPrev.isNotEmpty && navNext.isNotEmpty) {
            dayBuffer.writeln('$navPrev | $modLink | $navNext\n');
          } else if (navPrev.isNotEmpty) {
            dayBuffer.writeln('$navPrev | $modLink\n');
          } else if (navNext.isNotEmpty) {
            dayBuffer.writeln('$modLink | $navNext\n');
          } else {
            dayBuffer.writeln('$modLink\n');
          }

          dayBuffer.writeln('> [!TIP]');
          dayBuffer.writeln('> **Interactive Experience:** To run code interactively, view full theoretical breakdowns, test interview questions, and chat with the AI Tutor, launch the **Flutter AI Tutor App**!\n');
        } else {
          dayBuffer.writeln('> *Content coming soon...*\n');
        }

        // Write Day README
        await File('$dayDirPath/README.md').writeAsString(dayBuffer.toString());
      }

      moduleBuffer.writeln('[⬅️ Back to Phase $phaseNum: $phaseTitle](../README.md)\n');

      // Write Module README
      await File('$moduleDirPath/README.md').writeAsString(moduleBuffer.toString());
    }

    // Write Phase README
    await File('${phaseDir.path}/README.md').writeAsString(phaseBuffer.toString());
  }

  stdout.writeln('Success! All Phase, Module, and Day README files generated cleanly.');
}
