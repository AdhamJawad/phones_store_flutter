import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/app_back_button.dart';
import '../../../../core/errors/result.dart';
import '../../../products/domain/entities/product.dart';
import '../../../products/presentation/providers/products_providers.dart';
import '../../domain/entities/create_listing_input.dart';
import '../../domain/entities/update_listing_input.dart';
import '../providers/seller_marketplace_providers.dart';
import '../widgets/listing_condition_selector.dart';
import '../widgets/listing_image_upload_grid.dart';

class ListingFormPage extends ConsumerStatefulWidget {
  const ListingFormPage.create({super.key}) : product = null, isEdit = false;

  const ListingFormPage.edit({required this.product, super.key})
    : isEdit = true;

  final Product? product;
  final bool isEdit;

  @override
  ConsumerState<ListingFormPage> createState() => _ListingFormPageState();
}

class _ListingFormPageState extends ConsumerState<ListingFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _conditionNotesController = TextEditingController();
  final _accessoriesController = TextEditingController();
  final _defectsController = TextEditingController();
  final _locationController = TextEditingController();
  final _colorController = TextEditingController();

  int? _categoryId;
  String _condition = 'used';
  bool _disassembled = false;
  bool _seeded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = ref.read(listingFormControllerProvider.notifier);
      if (widget.isEdit && widget.product != null) {
        controller.seedForEdit(widget.product!);
      } else {
        controller.seedForCreate();
      }
    });
  }

  @override
  void dispose() {
    _brandController.dispose();
    _modelController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _conditionNotesController.dispose();
    _accessoriesController.dispose();
    _defectsController.dispose();
    _locationController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(listingFormControllerProvider);
    final categories = ref.watch(catalogCategoriesProvider);
    final listingsController = ref.read(
      sellerListingsControllerProvider.notifier,
    );

    if (!_seeded && widget.product != null) {
      final product = widget.product!;
      _seeded = true;
      _brandController.text = product.brand;
      _modelController.text = product.model;
      _priceController.text = product.price.toStringAsFixed(0);
      _descriptionController.text = product.description ?? '';
      _conditionNotesController.text = product.conditionNotes ?? '';
      _accessoriesController.text = product.accessories ?? '';
      _defectsController.text = product.defects ?? '';
      _locationController.text = product.location ?? '';
      _colorController.text = product.color ?? '';
      _categoryId = product.category?.id;
      _condition = product.condition;
      _disassembled = product.disassembledIs;
    }

    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: Text(
          widget.isEdit
              ? 'seller.edit_listing_title'.tr()
              : 'seller.create_listing_title'.tr(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            MediaQuery.viewInsetsOf(context).bottom + 24,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 22,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.isEdit
                              ? 'seller.edit_listing_subtitle'.tr()
                              : 'seller.create_listing_subtitle'.tr(),
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                        const SizedBox(height: 18),
                        _TextField(
                          controller: _brandController,
                          label: 'seller.brand_label'.tr(),
                          validator: _required,
                        ),
                        const SizedBox(height: 14),
                        _TextField(
                          controller: _modelController,
                          label: 'seller.model_label'.tr(),
                          validator: _required,
                        ),
                        const SizedBox(height: 14),
                        categories.when(
                          data: (items) => DropdownButtonFormField<int>(
                            initialValue: _categoryId,
                            decoration: InputDecoration(
                              labelText: 'seller.category_label'.tr(),
                            ),
                            items: items
                                .map(
                                  (item) => DropdownMenuItem<int>(
                                    value: item.id,
                                    child: Text(item.name),
                                  ),
                                )
                                .toList(growable: false),
                            onChanged: (value) {
                              setState(() {
                                _categoryId = value;
                              });
                            },
                            validator: (value) => value == null
                                ? 'seller.category_required'.tr()
                                : null,
                          ),
                          loading: () => const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: CircularProgressIndicator(),
                            ),
                          ),
                          error: (_, error) =>
                              Text('seller.categories_error'.tr()),
                        ),
                        const SizedBox(height: 14),
                        _TextField(
                          controller: _priceController,
                          label: 'seller.price_label'.tr(),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          validator: _priceValidator,
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'seller.condition_label'.tr(),
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 10),
                        ListingConditionSelector(
                          value: _condition,
                          onChanged: (value) {
                            setState(() {
                              _condition = value;
                            });
                          },
                        ),
                        const SizedBox(height: 14),
                        _TextField(
                          controller: _colorController,
                          label: 'seller.color_label'.tr(),
                          validator: _required,
                        ),
                        if (!widget.isEdit) ...[
                          const SizedBox(height: 14),
                          _TextField(
                            controller: _locationController,
                            label: 'seller.location_label'.tr(),
                            validator: _required,
                          ),
                        ],
                        const SizedBox(height: 14),
                        _TextField(
                          controller: _descriptionController,
                          label: 'seller.description_label'.tr(),
                          maxLines: 4,
                        ),
                        if (!widget.isEdit) ...[
                          const SizedBox(height: 14),
                          _TextField(
                            controller: _conditionNotesController,
                            label: 'seller.condition_notes_label'.tr(),
                            maxLines: 3,
                          ),
                        ],
                        if (widget.isEdit) ...[
                          const SizedBox(height: 14),
                          _TextField(
                            controller: _defectsController,
                            label: 'seller.defects_label'.tr(),
                            maxLines: 3,
                          ),
                        ],
                        const SizedBox(height: 14),
                        _TextField(
                          controller: _accessoriesController,
                          label: 'seller.accessories_label'.tr(),
                          maxLines: 3,
                        ),
                        const SizedBox(height: 10),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text('seller.disassembled_label'.tr()),
                          value: _disassembled,
                          onChanged: (value) {
                            setState(() {
                              _disassembled = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 22,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: ListingImageUploadGrid(
                      existingImages: formState.visibleExistingImages,
                      newImagePaths: formState.newImagePaths,
                      isPicking: formState.isPickingImages,
                      onAddImages: () => ref
                          .read(listingFormControllerProvider.notifier)
                          .pickImages(),
                      onRemoveExisting: (imageId) => ref
                          .read(listingFormControllerProvider.notifier)
                          .markExistingImageDeleted(imageId),
                      onRemoveNew: (path) => ref
                          .read(listingFormControllerProvider.notifier)
                          .removeNewImage(path),
                    ),
                  ),
                ),
                if (formState.hasError) ...[
                  const SizedBox(height: 14),
                  Text(
                    formState.errorMessage!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: formState.isSubmitting
                        ? null
                        : () => _submit(listingsController),
                    child: formState.isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2.2),
                          )
                        : Text(
                            widget.isEdit
                                ? 'seller.save_listing_changes'.tr()
                                : 'seller.submit_listing'.tr(),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String? _required(String? value) {
    if ((value ?? '').trim().isEmpty) {
      return 'seller.field_required'.tr();
    }
    return null;
  }

  String? _priceValidator(String? value) {
    final parsed = double.tryParse((value ?? '').trim());
    if (parsed == null || parsed < 0) {
      return 'seller.price_invalid'.tr();
    }
    return null;
  }

  Future<void> _submit(SellerListingsController listingsController) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final formController = ref.read(listingFormControllerProvider.notifier);
    final formState = ref.read(listingFormControllerProvider);

    final price = double.parse(_priceController.text.trim());
    late final Result<Product> result;

    if (widget.isEdit && widget.product != null) {
      result = await formController.submitUpdate(
        productId: widget.product!.id,
        input: UpdateListingInput(
          brand: _brandController.text.trim(),
          model: _modelController.text.trim(),
          categoryId: _categoryId!,
          price: price,
          condition: _condition,
          color: _colorController.text.trim(),
          description: _descriptionController.text.trim(),
          defects: _defectsController.text.trim(),
          accessories: _accessoriesController.text.trim(),
          disassembledIs: _disassembled,
          newImagePaths: formState.newImagePaths,
          deleteImageIds: formState.deletedImageIds.toList(growable: false),
        ),
      );
    } else {
      result = await formController.submitCreate(
        CreateListingInput(
          brand: _brandController.text.trim(),
          model: _modelController.text.trim(),
          categoryId: _categoryId!,
          price: price,
          condition: _condition,
          description: _descriptionController.text.trim(),
          conditionNotes: _conditionNotesController.text.trim(),
          accessories: _accessoriesController.text.trim(),
          disassembledIs: _disassembled,
          location: _locationController.text.trim(),
          color: _colorController.text.trim(),
          imagePaths: formState.newImagePaths,
        ),
      );
    }

    if (!mounted) {
      return;
    }

    switch (result) {
      case Success<Product>(:final data):
        listingsController.upsertListing(data);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.isEdit
                  ? 'seller.update_success'.tr()
                  : 'seller.create_success'.tr(),
            ),
          ),
        );
        Navigator.of(context).pop();
      case Error<Product>():
        break;
    }
  }
}

class _TextField extends StatelessWidget {
  const _TextField({
    required this.controller,
    required this.label,
    this.validator,
    this.keyboardType,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String label;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(labelText: label),
    );
  }
}
