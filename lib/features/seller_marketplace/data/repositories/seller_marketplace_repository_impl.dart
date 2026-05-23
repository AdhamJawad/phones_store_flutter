import 'package:dio/dio.dart';

import '../../../../core/errors/result.dart';
import '../../../../core/network/handlers/network_handler.dart';
import '../../../../core/utils/unit.dart';
import '../../../../data/repositories/base_repository_impl.dart';
import '../../../products/domain/entities/product.dart';
import '../../domain/entities/create_listing_input.dart';
import '../../domain/entities/seller_dashboard.dart';
import '../../domain/entities/seller_dashboard_stats.dart';
import '../../domain/entities/seller_listings_page.dart';
import '../../domain/entities/update_listing_input.dart';
import '../../domain/repositories/seller_marketplace_repository.dart';
import '../datasources/seller_marketplace_remote_data_source.dart';

class SellerMarketplaceRepositoryImpl extends BaseRepositoryImpl
    implements SellerMarketplaceRepository {
  SellerMarketplaceRepositoryImpl({
    required NetworkHandler networkHandler,
    required SellerMarketplaceRemoteDataSource remoteDataSource,
  })  : _remoteDataSource = remoteDataSource,
        super(networkHandler);

  final SellerMarketplaceRemoteDataSource _remoteDataSource;

  @override
  Future<Result<Product>> createListing(CreateListingInput input) {
    return guard(() async {
      final formData = FormData();
      formData.fields.addAll([
        MapEntry('brand', input.brand),
        MapEntry('model', input.model),
        MapEntry('category_id', '${input.categoryId}'),
        MapEntry('price', '${input.price}'),
        MapEntry('condition', input.condition),
        MapEntry('location', input.location),
        MapEntry('color', input.color),
        MapEntry('disassembled_is', input.disassembledIs ? '1' : '0'),
        if ((input.description ?? '').trim().isNotEmpty)
          MapEntry('description', input.description!.trim()),
        if ((input.conditionNotes ?? '').trim().isNotEmpty)
          MapEntry('condition_notes', input.conditionNotes!.trim()),
        if ((input.accessories ?? '').trim().isNotEmpty)
          MapEntry('accessories', input.accessories!.trim()),
      ]);
      for (final path in input.imagePaths) {
        formData.files.add(
          MapEntry(
            'images[]',
            await MultipartFile.fromFile(path),
          ),
        );
      }
      return _remoteDataSource.createListing(formData);
    });
  }

  @override
  Future<Result<Unit>> deleteListing(int productId) {
    return guard(() async {
      await _remoteDataSource.deleteListing(productId);
      return Unit.value;
    });
  }

  @override
  Future<Result<SellerDashboard>> getDashboard() {
    return guard(() async {
      final stats = await _remoteDataSource.getDashboardStats();
      final listings = await _remoteDataSource.getListings();
      return SellerDashboard(
        stats: stats,
        recentListings: listings.items.take(4).toList(growable: false),
      );
    });
  }

  @override
  Future<Result<SellerDashboardStats>> getDashboardStats() {
    return guard(_remoteDataSource.getDashboardStats);
  }

  @override
  Future<Result<SellerListingsPage>> getListings({int page = 1}) {
    return guard(() => _remoteDataSource.getListings(page: page));
  }

  @override
  Future<Result<Product>> updateListing(int productId, UpdateListingInput input) {
    return guard(() async {
      final formData = FormData();
      formData.fields.addAll([
        MapEntry('brand', input.brand),
        MapEntry('model', input.model),
        MapEntry('category_id', '${input.categoryId}'),
        MapEntry('price', '${input.price}'),
        MapEntry('condition', input.condition),
        MapEntry('color', input.color),
        MapEntry('disassembled_is', input.disassembledIs ? '1' : '0'),
        if ((input.description ?? '').trim().isNotEmpty)
          MapEntry('description', input.description!.trim()),
        if ((input.defects ?? '').trim().isNotEmpty)
          MapEntry('defects', input.defects!.trim()),
        if ((input.accessories ?? '').trim().isNotEmpty)
          MapEntry('accessories', input.accessories!.trim()),
        if ((input.status ?? '').trim().isNotEmpty)
          MapEntry('status', input.status!.trim()),
      ]);
      for (final imageId in input.deleteImageIds) {
        formData.fields.add(MapEntry('delete_images[]', '$imageId'));
      }
      for (final path in input.newImagePaths) {
        formData.files.add(
          MapEntry(
            'images[]',
            await MultipartFile.fromFile(path),
          ),
        );
      }
      return _remoteDataSource.updateListing(productId, formData);
    });
  }
}
