import '../../../../core/errors/result.dart';
import '../entities/ai_advisor_result.dart';

abstract class AiAdvisorRepository {
  Future<Result<AiAdvisorResult>> askAdvisor({required String query});
}
