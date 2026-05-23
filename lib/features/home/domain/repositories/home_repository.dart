import '../../../../core/errors/result.dart';
import 'package:phones_store_flutter/features/home/domain/entities/home_feed.dart';

abstract class HomeRepository {
  Future<Result<HomeFeed>> getHomeFeed();
}
