import 'package:injectable/injectable.dart';

import '../models/curriculum/phase.dart';
import '../repositories/curriculum_repository.dart';

/// Use case for loading all curriculum phases from the manifest.
///
/// Used by [CurriculumBloc] to populate the Phases and Modules screens.
@injectable
class GetPhasesUseCase {
  final CurriculumRepository _repository;

  const GetPhasesUseCase(this._repository);

  Future<List<Phase>> call() {
    return _repository.getPhases();
  }
}
