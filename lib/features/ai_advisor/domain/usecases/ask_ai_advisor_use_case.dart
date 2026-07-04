import '../../../../core/errors/result.dart';
import '../entities/ai_advisor_result.dart';
import '../repositories/ai_advisor_repository.dart';

class AskAiAdvisorUseCase {
  const AskAiAdvisorUseCase(this._repository);

  final AiAdvisorRepository _repository;

  Future<Result<AiAdvisorResult>> call({required String query}) {
    return _repository.askAdvisor(query: query);
  }
}
