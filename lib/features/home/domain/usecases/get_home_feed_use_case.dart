import '../../../../core/errors/result.dart';
import '../entities/home_feed.dart';
import '../repositories/home_repository.dart';

class GetHomeFeedUseCase {
  const GetHomeFeedUseCase(this._repository);

  final HomeRepository _repository;

  Future<Result<HomeFeed>> call() => _repository.getHomeFeed();
}
