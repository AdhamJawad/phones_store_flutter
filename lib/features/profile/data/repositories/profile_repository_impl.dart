import '../../../../core/errors/result.dart';
import '../../../../core/network/handlers/network_handler.dart';
import '../../../../core/utils/unit.dart';
import '../../../../data/repositories/base_repository_impl.dart';
import '../../../auth/data/datasources/auth_local_data_source.dart';
import '../../domain/entities/profile_user.dart';
import '../../domain/entities/update_profile_input.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_data_source.dart';

class ProfileRepositoryImpl extends BaseRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl({
    required NetworkHandler networkHandler,
    required ProfileRemoteDataSource remoteDataSource,
    required AuthLocalDataSource authLocalDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _authLocalDataSource = authLocalDataSource,
        super(networkHandler);

  final ProfileRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _authLocalDataSource;

  @override
  Future<Result<Unit>> deleteAccount() {
    return guard(() async {
      await _remoteDataSource.deleteAccount();
      await _authLocalDataSource.clear();
      return Unit.value;
    });
  }

  @override
  Future<Result<ProfileUser>> getProfile() {
    return guard(_remoteDataSource.getProfile);
  }

  @override
  Future<Result<ProfileUser>> updateProfile(UpdateProfileInput input) {
    return guard(() async {
      final profile = await _remoteDataSource.updateProfile(
        name: input.name,
        email: input.email,
      );
      await _authLocalDataSource.updateUser(profile.toAuthUserModel());
      return profile;
    });
  }
}
