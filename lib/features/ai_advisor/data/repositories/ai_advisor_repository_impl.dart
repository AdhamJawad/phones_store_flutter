import '../../../../core/errors/result.dart';
import '../../../../core/network/handlers/network_handler.dart';
import '../../../../data/repositories/base_repository_impl.dart';
import '../../domain/entities/ai_advisor_result.dart';
import '../../domain/repositories/ai_advisor_repository.dart';
import '../datasources/ai_advisor_remote_data_source.dart';

class AiAdvisorRepositoryImpl extends BaseRepositoryImpl
    implements AiAdvisorRepository {
  AiAdvisorRepositoryImpl({
    required NetworkHandler networkHandler,
    required AiAdvisorRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource,
       super(networkHandler);

  final AiAdvisorRemoteDataSource _remoteDataSource;

  @override
  Future<Result<AiAdvisorResult>> askAdvisor({required String query}) {
    return guard(() => _remoteDataSource.askAdvisor(query: query));
  }
}
