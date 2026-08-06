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
        
        String dayReadme = '# Day ${formatNum(day['day'])}: ${day['title']}\n\n';
        dayReadme += '${day['description']}\n\n';
        
        final tags = (day['tags'] as List).map((t) => '`$t`').join(' ');
        dayReadme += '**Tags:** $tags\n\n';

        if (await dayFile.exists()) {
          final dayData = json.decode(await dayFile.readAsString());
          
          if (dayData['last_updated'] != null) {
            dayReadme += '*Last Updated: ${dayData['last_updated']}*\n\n';
          }
          if (dayData['prerequisites'] != null) {
            dayReadme += '## Prerequisites\n${dayData['prerequisites']}\n\n';
          }
          if (dayData['theory'] != null) {
            dayReadme += '${dayData['theory']}\n\n';
          }
          if (dayData['implementation'] != null) {
            dayReadme += '## Implementation\n${dayData['implementation']}\n\n';
          }
          if (dayData['architecture'] != null) {
            dayReadme += '## Architecture\n${dayData['architecture']}\n\n';
          }
          if (dayData['comparisons'] != null) {
            dayReadme += '## Comparisons\n${dayData['comparisons']}\n\n';
          }
          if (dayData['optimization'] != null) {
            dayReadme += '## Optimization\n${dayData['optimization']}\n\n';
          }
          if (dayData['interview_questions'] != null) {
            dayReadme += '## Interview Questions\n${dayData['interview_questions']}\n\n';
          }
          if (dayData['common_mistakes'] != null) {
            dayReadme += '## Common Mistakes\n${dayData['common_mistakes']}\n\n';
          }
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
