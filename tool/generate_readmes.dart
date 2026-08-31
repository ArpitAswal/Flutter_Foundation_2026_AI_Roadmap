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
String extractOverview(String? theory) {
  if (theory == null || theory.isEmpty) return '';
  final cleanTheory = theory.replaceAll(RegExp(r'^#+.*$', multiLine: true), '').trim();
  final paragraphs = cleanTheory
      .split('\n\n')
      .where((p) => p.trim().isNotEmpty && !p.trim().startsWith('|'))
      .toList();
  
  if (paragraphs.isNotEmpty) {
    // Take up to 3 paragraphs for a richer overview
    final overviewText = paragraphs.take(3).map((p) => p.trim()).join('\n\n');
    return '## 📖 Overview\n$overviewText\n\n';
  }
  return '';
}

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
      
      // Skip markdown tables/lists/images for description text
      if (line.startsWith('|') || line.startsWith('*') || line.startsWith('-') || line.startsWith('![')) {
        if (description.isEmpty && line.length > 15) {
           description = line.replaceAll(RegExp(r'^\*\*(.*?)\*\*:\s*'), '').trim();
           break;
        }
      } else if (line.isNotEmpty) {
        description = line.replaceAll(RegExp(r'^\*\*(.*?)\*\*:\s*'), '').trim();
        break;
      }
    }
    
    if (description.isNotEmpty) {
      if (description.length > 150) {
        description = '${description.substring(0, 147)}...';
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

String extractObjective(String? implementation) {
  if (implementation == null || implementation.isEmpty) return '';
  final match = RegExp(r'### Objective\n(.*?)(?=\n###|\Z)', dotAll: true).firstMatch(implementation);
  if (match != null && match.group(1) != null) {
    return '## 🎯 Implementation Objective\n${match.group(1)!.trim()}\n\n';
  }
  return '';
}

int countInterviewQuestions(String? questions) {
  if (questions == null || questions.isEmpty) return 0;
  return RegExp(r'^## Scenario', multiLine: true).allMatches(questions).length;
}

String extractComparisons(String? comparisons) {
  if (comparisons == null || comparisons.isEmpty) return '';
  final headings = RegExp(r'^### (.*)$', multiLine: true).allMatches(comparisons);
  final comps = headings.map((m) => m.group(1)?.trim()).join(', ');
  return comps;
}

void main() async {
  final indexFile = File('assets/curriculum/curriculum_index.json');
  if (!await indexFile.exists()) {
    print('Error: Could not find curriculum_index.json');
    return;
  }

  final indexContent = await indexFile.readAsString();
  final indexData = json.decode(indexContent);
  final phases = indexData['phases'] as List;

  print('Generating Hybrid GitHub README Structure...');

  for (final phase in phases) {
    final phaseDirName = formatDirName('Phase', phase['id'], phase['title']);
    final phaseDir = Directory(phaseDirName);
    if (!await phaseDir.exists()) await phaseDir.create(recursive: true);

    String phaseReadme = '# Phase ${formatNum(phase['id'])}: ${phase['title']}\n\n';
    phaseReadme += '${phase['description']}\n\n## Modules\n\n';

    final modules = phase['modules'] as List;
    for (final module in modules) {
      final moduleDirName = formatDirName('Module', module['id'], module['title']);
      final moduleDirPath = '${phaseDir.path}/$moduleDirName';
      final moduleDir = Directory(moduleDirPath);
      if (!await moduleDir.exists()) await moduleDir.create(recursive: true);

      phaseReadme += '- [Module ${formatNum(module['id'])}: ${module['title']}]($moduleDirName/README.md)\n';

      String moduleReadme = '# Module ${formatNum(module['id'])}: ${module['title']}\n\n';
      moduleReadme += '${module['subtitle'] ?? ''}\n\n## Days\n\n';

      final days = module['days'] as List;
      for (final day in days) {
        final dayDirName = 'Day-${formatNum(day['day'])}';
        final dayDirPath = '${moduleDir.path}/$dayDirName';
        final dayDir = Directory(dayDirPath);
        if (!await dayDir.exists()) await dayDir.create(recursive: true);

        moduleReadme += '- [Day ${formatNum(day['day'])}: ${day['title']}]($dayDirName/README.md)\n';

        // Load specific day content
        final contentPath = day['content_path'] as String;
        final dayFile = File(contentPath);
        
        String dayReadme = '# 📘 Day ${day['day']}: ${day['title']}\n\n';
        
        dayReadme += '> [!NOTE]\n';
        dayReadme += '> **Summary:** ${day['description']}\n\n';

        final tags = (day['tags'] as List).map((t) => '`$t`').join(', ');
        dayReadme += '**Tags:** $tags\n\n';
        
        dayReadme += '---\n\n';

        if (await dayFile.exists()) {
          final dayData = json.decode(await dayFile.readAsString());
          
          if (dayData['prerequisites'] != null && dayData['prerequisites'].toString().trim().isNotEmpty) {
            dayReadme += '## 🚦 Prerequisites\n${dayData['prerequisites']}\n\n';
          }
          
          dayReadme += extractOverview(dayData['theory']);
          dayReadme += extractTopics(dayData['theory']);
          dayReadme += extractObjective(dayData['implementation']);
          
          // Additional Materials section
          List<String> materials = [];
          
          final iqCount = countInterviewQuestions(dayData['interview_questions']);
          if (iqCount > 0) {
            materials.add('**$iqCount Interview Questions** included');
          }
          
          final comps = extractComparisons(dayData['comparisons']);
          if (comps.isNotEmpty) {
            materials.add('**Comparisons:** $comps');
          }
          
          if (dayData['common_mistakes'] != null) {
            materials.add('**Common Mistakes & Optimizations** included');
          }
          
          if (dayData['architecture'] != null) {
            materials.add('**Architecture Implementation Notes** included');
          }
          
          if (materials.isNotEmpty) {
            dayReadme += '## 💡 Additional Materials Included\n';
            for (final m in materials) {
              dayReadme += '* $m\n';
            }
            dayReadme += '\n';
          }
          
          // Add the deep dive tip
          dayReadme += '> [!TIP]\n';
          dayReadme += '> **Deep Dive:** To read the full theory, view detailed code implementations, architectures, and common interview questions, open this lesson interactively inside the **Flutter AI Tutor App**!\n';
        } else {
          dayReadme += '> *Content coming soon...*\n';
        }

        // Write Day README
        await File('$dayDirPath/README.md').writeAsString(dayReadme);
        print('Created: $dayDirPath/README.md');
      }

      // Write Module README
      await File('$moduleDirPath/README.md').writeAsString(moduleReadme);
      print('Created: $moduleDirPath/README.md');
    }

    // Write Phase README
    await File('${phaseDir.path}/README.md').writeAsString(phaseReadme);
    print('Created: ${phaseDir.path}/README.md');
  }

  print('\nSuccess! All README files generated successfully.');
}
