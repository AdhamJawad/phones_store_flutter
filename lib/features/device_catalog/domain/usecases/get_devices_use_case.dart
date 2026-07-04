import '../../../../core/errors/result.dart';
import '../entities/device_page.dart';
import '../repositories/device_catalog_repository.dart';

class GetDevicesUseCase {
  const GetDevicesUseCase(this._repository);

  final DeviceCatalogRepository _repository;

  Future<Result<DevicePage>> call({
    int page = 1,
    int perPage = 15,
    String? query,
    String? brand,
  }) {
    return _repository.getDevices(
      page: page,
      perPage: perPage,
      query: query,
      brand: brand,
    );
  }
}
