import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'injection.config.dart';

/// Global singleton instance of GetIt for dependency injection.
final getIt = GetIt.instance;

/// Configures all dependencies using get_it and injectable.
///
/// This method must be called during application initialization (e.g., in `main.dart`)
/// before attempting to resolve any dependencies.
@InjectableInit(
  initializerName: 'init',
  preferRelativeImports: true,
  asExtension: true,
)
Future<void> configureDependencies() async {
  getIt.init();
}
