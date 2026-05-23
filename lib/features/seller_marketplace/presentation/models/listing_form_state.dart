import '../../../../core/errors/failure.dart';
import '../../../products/domain/entities/product_image.dart';

class ListingFormState {
  const ListingFormState({
    required this.existingImages,
    required this.deletedImageIds,
    required this.newImagePaths,
    required this.isSubmitting,
    required this.isPickingImages,
    this.failure,
    this.errorMessage,
  });

  const ListingFormState.initial()
      : existingImages = const <ProductImage>[],
        deletedImageIds = const <int>{},
        newImagePaths = const <String>[],
        isSubmitting = false,
        isPickingImages = false,
        failure = null,
        errorMessage = null;

  final List<ProductImage> existingImages;
  final Set<int> deletedImageIds;
  final List<String> newImagePaths;
  final bool isSubmitting;
  final bool isPickingImages;
  final Failure? failure;
  final String? errorMessage;

  List<ProductImage> get visibleExistingImages => existingImages
      .where((image) => !deletedImageIds.contains(image.id))
      .toList(growable: false);

  int get totalImagesCount => visibleExistingImages.length + newImagePaths.length;
  bool get hasError => errorMessage != null && errorMessage!.trim().isNotEmpty;

  ListingFormState copyWith({
    List<ProductImage>? existingImages,
    Set<int>? deletedImageIds,
    List<String>? newImagePaths,
    bool? isSubmitting,
    bool? isPickingImages,
    Failure? failure,
    String? errorMessage,
    bool clearFailure = false,
    bool clearError = false,
  }) {
    return ListingFormState(
      existingImages: existingImages ?? this.existingImages,
      deletedImageIds: deletedImageIds ?? this.deletedImageIds,
      newImagePaths: newImagePaths ?? this.newImagePaths,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isPickingImages: isPickingImages ?? this.isPickingImages,
      failure: clearFailure ? null : failure ?? this.failure,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}
