import '../../../../core/errors/result.dart';
import '../../../../core/network/handlers/network_handler.dart';
import '../../../../data/repositories/base_repository_impl.dart';
import '../../domain/entities/home_feed.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_remote_data_source.dart';

class HomeRepositoryImpl extends BaseRepositoryImpl implements HomeRepository {
  HomeRepositoryImpl({
    required NetworkHandler networkHandler,
    required HomeRemoteDataSource remoteDataSource,
  })  : _remoteDataSource = remoteDataSource,
        super(networkHandler);

  final HomeRemoteDataSource _remoteDataSource;

  @override
  Future<Result<HomeFeed>> getHomeFeed() {
    return guard(() => _remoteDataSource.getHomeFeed());
  }
}
